using System.Security.Claims;
using GrupX.Modules.Billing.Contracts;
using GrupX.Modules.Events.Contracts;
using GrupX.SharedKernel;
using GrupX.SharedKernel.Auditing;
using GrupX.SharedKernel.Database;
using GrupX.SharedKernel.Http;
using GrupX.SharedKernel.Supabase;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Npgsql;

namespace GrupX.Modules.Events;

/// <summary>The whole event form; an edit sends every field (docs/ARCHITECTURE.md §3d).</summary>
public sealed record EventRequest(
    string? Title,
    string? Description,
    DateTimeOffset StartsAt,
    DateTimeOffset? EndsAt,
    string? Location,
    string? LinkUrl,
    int? Capacity,
    int? FeeAmount,
    string? FeeCurrency,
    string? FeeNote,
    string? CoverPath,
    string? Requirements = null,
    IReadOnlyList<string>? Equipment = null,
    bool ApprovalRequired = false);

public sealed record CreatedEvent(Guid Id);

public sealed record CancelEventRequest(string Reason);

public sealed record Attendance(string Status, int? Place);

public sealed record CreatePollRequest(
    string? Question, IReadOnlyList<string>? Options, bool AllowsMultiple, bool IsAnonymous, DateTimeOffset? ClosesAt, Guid? EventId);

public sealed record CreatedPoll(Guid Id);

public static class EventsModule
{
    public static IServiceCollection AddEventsModule(this IServiceCollection services)
    {
        services.TryAddSingleton(TimeProvider.System);
        services.AddSingleton<EventService>();
        services.AddSingleton<IEventsAdministration>(sp => sp.GetRequiredService<EventService>());
        services.AddHostedService<EventReminderService>();
        return services;
    }

    /// <summary>Events, attendance and polls (docs/ARCHITECTURE.md §3d). Votes go through Supabase.</summary>
    public static IEndpointRouteBuilder MapEventsEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapPost("/groups/{id:guid}/events", async (Guid id, EventRequest body, ClaimsPrincipal user, EventService events, CancellationToken ct) =>
            (await events.CreateAsync(user.GetUserId(), id, body, ct)).ToHttpResult());

        app.MapPut("/events/{id:guid}", async (Guid id, EventRequest body, ClaimsPrincipal user, EventService events, CancellationToken ct) =>
            (await events.UpdateAsync(user.GetUserId(), id, body, ct)).ToHttpResult());

        app.MapPost("/events/{id:guid}/cancellation", async (Guid id, CancelEventRequest body, ClaimsPrincipal user, EventService events, CancellationToken ct) =>
            (await events.CancelByManagerAsync(user.GetUserId(), id, body.Reason, ct)).ToHttpResult());

        app.MapPost("/events/{id:guid}/attendance", async (Guid id, ClaimsPrincipal user, EventService events, CancellationToken ct) =>
            (await events.AttendAsync(user.GetUserId(), id, ct)).ToHttpResult());

        app.MapDelete("/events/{id:guid}/attendance", async (Guid id, ClaimsPrincipal user, EventService events, CancellationToken ct) =>
            (await events.LeaveAsync(user.GetUserId(), id, ct)).ToHttpResult());

        app.MapPost("/events/{id:guid}/requests/{userId:guid}/approval", async (
                Guid id, Guid userId, ClaimsPrincipal user, EventService events, CancellationToken ct) =>
            (await events.DecideRequestAsync(user.GetUserId(), id, userId, approve: true, ct)).ToHttpResult());

        app.MapDelete("/events/{id:guid}/requests/{userId:guid}", async (
                Guid id, Guid userId, ClaimsPrincipal user, EventService events, CancellationToken ct) =>
            (await events.DecideRequestAsync(user.GetUserId(), id, userId, approve: false, ct)).ToHttpResult());

        // "Takvime ekle": public like the event page itself.
        app.MapGet("/events/{id:guid}/calendar.ics", async (Guid id, EventService events, CancellationToken ct) =>
                await events.CalendarAsync(id, ct) is { } ics
                    ? Results.Text(ics, "text/calendar; charset=utf-8")
                    : Results.NotFound())
            .AllowAnonymous();

        app.MapPost("/groups/{id:guid}/polls", async (Guid id, CreatePollRequest body, ClaimsPrincipal user, EventService events, CancellationToken ct) =>
            (await events.CreatePollAsync(user.GetUserId(), id, body, ct)).ToHttpResult());

        app.MapPost("/polls/{id:guid}/close", async (Guid id, ClaimsPrincipal user, EventService events, CancellationToken ct) =>
            (await events.ClosePollAsync(user.GetUserId(), id, ct)).ToHttpResult());

        app.MapDelete("/polls/{id:guid}", async (Guid id, ClaimsPrincipal user, EventService events, CancellationToken ct) =>
            (await events.DeletePollAsync(user.GetUserId(), id, ct)).ToHttpResult());

        return app;
    }
}

/// <summary>Event and poll writes; attendance order and the waitlist are decided by the database triggers.</summary>
internal sealed partial class EventService(
    NpgsqlDataSource db, IGroupPlanLimits planLimits, ISupabaseStorage storage, TimeProvider time, IConfiguration configuration,
    ILogger<EventService> log)
    : IEventsAdministration
{
    public const string Bucket = "event-images";
    private static readonly string[] Currencies = ["TRY", "USD", "EUR"];
    private static readonly string[] ImageExtensions = [".jpg", ".jpeg", ".png", ".webp"];

    private static readonly Error NotFound = Error.NotFound("event.not_found", "Organizasyon bulunamadı.");
    private static readonly Error PollNotFound = Error.NotFound("poll.not_found", "Anket bulunamadı.");
    private static readonly Error Forbidden = Error.Forbidden("event.forbidden", "Bu grupta organizasyon ve anket yönetme yetkin yok.");

    private static Error Invalid(string message) => Error.Validation("event.invalid", message);

    private static Error RuleError(string code) => code switch
    {
        "monthly_limit_reached" => Error.RuleViolation("event.monthly_limit_reached",
            "Grubun bu ayki organizasyon hakkı doldu. Daha fazlası için paketi yükseltebilirsin."),
        "event_time_invalid" => Invalid("Organizasyon en az 15 dakika, en fazla 1 yıl sonra başlamalı."),
        "capacity_below_going" => Error.RuleViolation("event.capacity_below_going", "Kapasite, katılan kişi sayısının altına inemez."),
        "event_closed" => Error.RuleViolation("event.closed", "Bu organizasyon başladı ya da iptal edildi."),
        "event_already_canceled" => Error.Conflict("event.already_canceled", "Organizasyon zaten iptal edilmiş."),
        "attendance_forbidden" => Error.Forbidden("event.attendance_forbidden", "Katılmak için grubun üyesi olmalısın."),
        "poll_time_invalid" => Invalid("Anket en az 5 dakika, en fazla 90 gün sonra kapanmalı."),
        "equipment_invalid" => Invalid("Ekipman en fazla 10 madde olabilir; her madde 1–60 karakter olmalı."),
        "event_forbidden" or "poll_forbidden" => Forbidden,
        _ => Error.RuleViolation($"event.{code}", "Bu işlem şu anda yapılamıyor. Sayfayı yenileyip tekrar dene."),
    };

    private sealed record EventRow(Guid Id, Guid GroupId, string? CoverPath, DateTimeOffset StartsAt, bool Canceled);

    private static async Task<EventRow?> LoadAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid id, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand(
            "select id, group_id, cover_path, starts_at, canceled_at is not null from public.events where id = @id for update", conn, tx);
        cmd.Parameters.AddWithValue("id", id);
        await using var r = await cmd.ExecuteReaderAsync(ct);
        return await r.ReadAsync(ct)
            ? new EventRow(r.GetGuid(0), r.GetGuid(1), r.IsDBNull(2) ? null : r.GetString(2), r.GetFieldValue<DateTimeOffset>(3), r.GetBoolean(4))
            : null;
    }

    private static async Task<bool> CanManageAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid actor, Guid groupId, CancellationToken ct) =>
        await ActingTransaction.ScalarAsync(conn, tx, "select private.user_has_group_permission(@a, @g, 'events.manage')", ct,
            ("a", actor), ("g", groupId)) is true;

    private static Task AuditAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid actor, string action, string type, Guid target, Guid groupId,
        object? data, CancellationToken ct, string actorKind = AuditActor.User) =>
        AuditLog.AppendAsync(conn, tx, new AuditEntry(actor, actorKind, action, type, target.ToString(), data, groupId), ct);

    private sealed record EventFields(
        string Title, string Description, DateTimeOffset StartsAt, DateTimeOffset? EndsAt, string Location, string? LinkUrl,
        int? Capacity, int? FeeAmount, string? FeeCurrency, string? FeeNote, string? CoverPath,
        string Requirements, string[] Equipment, bool ApprovalRequired);

    /// <summary>Shape checks; the start window is checked when the start changes (an edit may keep a near start).</summary>
    private Result<EventFields> Validate(EventRequest r, Guid groupId, bool checkStart)
    {
        var title = r.Title?.Trim() ?? "";
        var description = r.Description?.Trim() ?? "";
        var location = r.Location?.Trim() ?? "";
        var link = string.IsNullOrWhiteSpace(r.LinkUrl) ? null : r.LinkUrl.Trim();
        var note = string.IsNullOrWhiteSpace(r.FeeNote) ? null : r.FeeNote.Trim();
        var requirements = r.Requirements?.Trim() ?? "";
        var equipment = (r.Equipment ?? []).Select(e => e?.Trim() ?? "").ToArray();
        var now = time.GetUtcNow();

        if (title.Length is < 3 or > 100) return Invalid("Başlık 3–100 karakter olmalı.");
        if (description.Length > 2000) return Invalid("Açıklama en fazla 2.000 karakter olabilir.");
        if (location.Length is < 2 or > 200) return Invalid("Yer 2–200 karakter olmalı.");
        if (link is not null && (link.Length > 300 || !Uri.TryCreate(link, UriKind.Absolute, out var uri) || uri.Scheme is not ("http" or "https")))
            return Invalid("Bağlantı http ya da https ile başlayan geçerli bir adres olmalı.");
        if (checkStart && (r.StartsAt < now.AddMinutes(15) || r.StartsAt > now.AddYears(1))) return RuleError("event_time_invalid");
        if (r.EndsAt is { } end && end <= r.StartsAt) return Invalid("Bitiş, başlangıçtan sonra olmalı.");
        if (r.Capacity is < 1 or > 10_000) return Invalid("Kapasite 1–10.000 arasında olmalı ya da boş bırakılmalı.");
        if (r.FeeAmount is { } fee && (fee <= 0 || r.FeeCurrency is null || !Currencies.Contains(r.FeeCurrency)))
            return Invalid("Ücret için tutar ve para birimi (TRY, USD, EUR) gerekli.");
        if (r.FeeAmount is null && r.FeeCurrency is not null) return Invalid("Para birimi seçildiyse tutar da girilmeli.");
        if (note is { Length: > 200 }) return Invalid("Ücret notu en fazla 200 karakter olabilir.");
        if (requirements.Length > 500) return Invalid("Katılım koşulları en fazla 500 karakter olabilir.");
        if (equipment.Length > 10 || equipment.Any(e => e.Length is < 1 or > 60)) return RuleError("equipment_invalid");
        if (r.CoverPath is { } cover && (!cover.StartsWith($"{groupId}/", StringComparison.Ordinal) || cover.Contains("..", StringComparison.Ordinal)
                || !ImageExtensions.Contains(Path.GetExtension(cover).ToLowerInvariant())))
            return Invalid("Kapak görseli bulunamadı. Yeniden yüklemeyi dene.");

        return new EventFields(title, description, r.StartsAt, r.EndsAt, location, link, r.Capacity, r.FeeAmount,
            r.FeeAmount is null ? null : r.FeeCurrency, note, r.CoverPath, requirements, equipment, r.ApprovalRequired);
    }

    private static async Task<bool> CoverStoredAsync(NpgsqlConnection conn, NpgsqlTransaction tx, string path, CancellationToken ct) =>
        await ActingTransaction.ScalarAsync(conn, tx,
            "select exists (select 1 from storage.objects where bucket_id = @b and name = @p and coalesce(metadata->>'mimetype', '') like 'image/%')",
            ct, ("b", Bucket), ("p", path)) is true;

    private static (string Name, object? Value)[] Parameters(EventFields f) =>
    [
        ("title", f.Title), ("description", f.Description), ("starts", f.StartsAt), ("ends", f.EndsAt), ("location", f.Location),
        ("link", f.LinkUrl), ("capacity", f.Capacity), ("fee", f.FeeAmount), ("currency", f.FeeCurrency), ("note", f.FeeNote),
        ("cover", f.CoverPath), ("requirements", f.Requirements), ("equipment", f.Equipment), ("approval", f.ApprovalRequired),
    ];

    // Events -----------------------------------------------------------------------------------

    public async Task<Result<CreatedEvent>> CreateAsync(Guid actor, Guid groupId, EventRequest request, CancellationToken ct)
    {
        ArgumentNullException.ThrowIfNull(request);
        var fields = Validate(request, groupId, checkStart: true);
        if (!fields.IsSuccess) return fields.Error;

        return await ActingTransaction.RunAsync<CreatedEvent>(db, actor, async (conn, tx) =>
        {
            if (!await CanManageAsync(conn, tx, actor, groupId, ct)) return Forbidden;
            if (fields.Value.CoverPath is { } cover && !await CoverStoredAsync(conn, tx, cover, ct)) return Invalid("Kapak görseli bulunamadı. Yeniden yüklemeyi dene.");

            // The trigger checks the same limit under a lock; this gives the friendly answer first.
            await ActingTransaction.ExecuteAsync(conn, tx, "select 1 from public.groups where id = @g for update", ct, ("g", groupId));
            var limits = await planLimits.GetAsync(conn, tx, groupId, ct);
            var thisMonth = (long)(await ActingTransaction.ScalarAsync(conn, tx,
                """
                select count(*) from public.events where group_id = @g
                  and created_at >= (date_trunc('month', now() at time zone 'Europe/Istanbul') at time zone 'Europe/Istanbul')
                """, ct, ("g", groupId)))!;
            if (thisMonth >= limits.MonthlyEvents) return RuleError("monthly_limit_reached");

            var id = (Guid)(await ActingTransaction.ScalarAsync(conn, tx,
                """
                insert into public.events (group_id, created_by, title, description, starts_at, ends_at, location, link_url, capacity,
                                           fee_amount, fee_currency, fee_note, cover_path, requirements, equipment, approval_required)
                values (@g, @actor, @title, @description, @starts, @ends, @location, @link, @capacity, @fee, @currency, @note, @cover,
                        @requirements, @equipment, @approval)
                returning id
                """, ct, [("g", groupId), ("actor", actor), .. Parameters(fields.Value)]))!;
            await AuditAsync(conn, tx, actor, "event.created", "event", id, groupId, new { fields.Value.Title, fields.Value.StartsAt }, ct);
            return new CreatedEvent(id);
        }, RuleError, ct);
    }

    public async Task<Result> UpdateAsync(Guid actor, Guid id, EventRequest request, CancellationToken ct)
    {
        ArgumentNullException.ThrowIfNull(request);
        string? replacedCover = null;
        var updated = await ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            var e = await LoadAsync(conn, tx, id, ct);
            if (e is null) return NotFound;
            if (!await CanManageAsync(conn, tx, actor, e.GroupId, ct)) return Forbidden;
            if (e.Canceled || e.StartsAt <= time.GetUtcNow()) return RuleError("event_closed");
            var fields = Validate(request, e.GroupId, checkStart: request.StartsAt != e.StartsAt);
            if (!fields.IsSuccess) return fields.Error;
            if (fields.Value.CoverPath is { } cover && cover != e.CoverPath && !await CoverStoredAsync(conn, tx, cover, ct))
                return Invalid("Kapak görseli bulunamadı. Yeniden yüklemeyi dene.");

            await ActingTransaction.ExecuteAsync(conn, tx,
                """
                update public.events set title = @title, description = @description, starts_at = @starts, ends_at = @ends,
                       location = @location, link_url = @link, capacity = @capacity, fee_amount = @fee, fee_currency = @currency,
                       fee_note = @note, cover_path = @cover, requirements = @requirements, equipment = @equipment,
                       approval_required = @approval
                where id = @id
                """, ct, [("id", id), .. Parameters(fields.Value)]);
            await AuditAsync(conn, tx, actor, "event.updated", "event", id, e.GroupId, null, ct);
            if (e.CoverPath is not null && e.CoverPath != fields.Value.CoverPath) replacedCover = e.CoverPath;
            return Result.Success();
        }, RuleError, ct);

        if (updated.IsSuccess && replacedCover is not null) await DeleteCoverAsync(replacedCover);
        return updated;
    }

    /// <summary>A replaced cover is deleted after the commit; a failure only leaves an unreachable object.</summary>
    private async Task DeleteCoverAsync(string path)
    {
        try
        {
            await storage.DeleteObjectsAsync(Bucket, [path], CancellationToken.None);
        }
        catch (HttpRequestException ex)
        {
            LogCoverCleanupFailed(log, ex, path);
        }
    }

    public Task<Result> CancelByManagerAsync(Guid actor, Guid id, string reason, CancellationToken ct) =>
        CancelCoreAsync(actor, id, reason, staff: false, ct);

    public Task<Result> CancelAsync(Guid actorId, Guid eventId, string reason, CancellationToken ct) =>
        CancelCoreAsync(actorId, eventId, reason, staff: true, ct);

    private Task<Result> CancelCoreAsync(Guid actor, Guid id, string reason, bool staff, CancellationToken ct)
    {
        reason = reason?.Trim() ?? "";
        if (reason.Length is < 3 or > 500) return Task.FromResult<Result>(Error.Validation("event.invalid_reason", "Gerekçe 3–500 karakter olmalı."));

        return ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            var e = await LoadAsync(conn, tx, id, ct);
            if (e is null) return NotFound;
            if (!staff && !await CanManageAsync(conn, tx, actor, e.GroupId, ct)) return Forbidden;
            if (e.Canceled) return RuleError("event_already_canceled");

            await ActingTransaction.ExecuteAsync(conn, tx,
                "update public.events set canceled_at = now(), cancel_reason = @reason where id = @id", ct, ("id", id), ("reason", reason));
            await AuditAsync(conn, tx, actor, staff ? "event.canceled_by_admin" : "event.canceled", "event", id, e.GroupId,
                new { reason }, ct, staff ? AuditActor.Staff : AuditActor.User);
            return Result.Success();
        }, RuleError, ct);
    }

    // Attendance -------------------------------------------------------------------------------

    public Task<Result<Attendance>> AttendAsync(Guid actor, Guid id, CancellationToken ct) =>
        ActingTransaction.RunAsync<Attendance>(db, actor, async (conn, tx) =>
        {
            var e = await LoadAsync(conn, tx, id, ct);
            if (e is null) return NotFound;
            if (e.Canceled || e.StartsAt <= time.GetUtcNow()) return RuleError("event_closed");
            if (await ActingTransaction.ScalarAsync(conn, tx,
                    "select exists (select 1 from public.group_members where group_id = @g and user_id = @u)", ct, ("g", e.GroupId), ("u", actor)) is not true)
                return RuleError("attendance_forbidden");

            await ActingTransaction.ExecuteAsync(conn, tx,
                "insert into public.event_attendees (event_id, user_id) values (@e, @u) on conflict do nothing", ct, ("e", id), ("u", actor));
            return await AttendanceOfAsync(conn, tx, id, actor, ct);
        }, RuleError, ct);

    private static async Task<Attendance> AttendanceOfAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid id, Guid user, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand(
            """
            select me.status,
                   case when me.status = 'waitlisted' then (
                     select count(*)::int + 1 from public.event_attendees w
                     where w.event_id = me.event_id and w.status = 'waitlisted' and (w.created_at, w.user_id) < (me.created_at, me.user_id))
                   end
            from public.event_attendees me where me.event_id = @e and me.user_id = @u
            """, conn, tx);
        cmd.Parameters.AddWithValue("e", id);
        cmd.Parameters.AddWithValue("u", user);
        await using var r = await cmd.ExecuteReaderAsync(ct);
        await r.ReadAsync(ct);
        return new Attendance(r.GetString(0), r.IsDBNull(1) ? null : r.GetInt32(1));
    }

    public Task<Result> LeaveAsync(Guid actor, Guid id, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            var e = await LoadAsync(conn, tx, id, ct);
            if (e is null) return NotFound;
            if (e.StartsAt <= time.GetUtcNow()) return RuleError("event_closed");
            await ActingTransaction.ExecuteAsync(conn, tx,
                "delete from public.event_attendees where event_id = @e and user_id = @u", ct, ("e", id), ("u", actor));
            return Result.Success();
        }, RuleError, ct);

    /// <summary>Approves (going or waitlisted by the free seats) or declines a join request (docs/ARCHITECTURE.md §3d, Faz 8).</summary>
    public Task<Result> DecideRequestAsync(Guid actor, Guid id, Guid userId, bool approve, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            var e = await LoadAsync(conn, tx, id, ct);
            if (e is null) return NotFound;
            if (!await CanManageAsync(conn, tx, actor, e.GroupId, ct)) return Forbidden;
            if (e.Canceled || e.StartsAt <= time.GetUtcNow()) return RuleError("event_closed");
            var changed = await ActingTransaction.ExecuteAsync(conn, tx,
                approve
                    ? "update public.event_attendees set status = 'going' where event_id = @e and user_id = @u and status = 'requested'"
                    : "delete from public.event_attendees where event_id = @e and user_id = @u and status = 'requested'",
                ct, ("e", id), ("u", userId));
            if (changed == 0) return Error.NotFound("event.request_not_found", "Bekleyen bir katılım isteği bulunamadı.");
            await AuditAsync(conn, tx, actor, approve ? "event.attendee_approved" : "event.attendee_declined", "event", id, e.GroupId,
                new { userId }, ct);
            return Result.Success();
        }, RuleError, ct);

    /// <summary>The event as an iCalendar file, or null when it is not public (docs/ARCHITECTURE.md §3d, Takvime ekle).</summary>
    public async Task<string?> CalendarAsync(Guid id, CancellationToken ct)
    {
        await using var cmd = db.CreateCommand(
            """
            select e.title, e.description, e.location, e.starts_at, e.ends_at, e.canceled_at is not null
            from public.events e join public.groups g on g.id = e.group_id
            where e.id = @id and g.status = 'active'
            """);
        cmd.Parameters.AddWithValue("id", id);
        await using var r = await cmd.ExecuteReaderAsync(ct);
        if (!await r.ReadAsync(ct)) return null;
        var appUrl = configuration["Events:AppUrl"]?.TrimEnd('/');
        return EventCalendar.Build(
            id, r.GetString(0), r.GetString(1), r.GetString(2), r.GetFieldValue<DateTimeOffset>(3),
            r.IsDBNull(4) ? null : r.GetFieldValue<DateTimeOffset>(4), r.GetBoolean(5),
            string.IsNullOrEmpty(appUrl) ? null : $"{appUrl}/#/e/{id}", time.GetUtcNow());
    }

    // Polls ------------------------------------------------------------------------------------

    public async Task<Result<CreatedPoll>> CreatePollAsync(Guid actor, Guid groupId, CreatePollRequest request, CancellationToken ct)
    {
        ArgumentNullException.ThrowIfNull(request);
        var question = request.Question?.Trim() ?? "";
        var options = (request.Options ?? []).Select(o => o?.Trim() ?? "").ToList();
        if (question.Length is < 3 or > 200) return Invalid("Soru 3–200 karakter olmalı.");
        if (options.Count is < 2 or > 10) return Invalid("Bir ankette 2–10 seçenek olabilir.");
        if (options.Any(o => o.Length is < 1 or > 80)) return Invalid("Seçenekler 1–80 karakter olmalı.");
        if (options.Distinct(StringComparer.OrdinalIgnoreCase).Count() != options.Count) return Invalid("Seçenekler birbirinden farklı olmalı.");
        var now = time.GetUtcNow();
        if (request.ClosesAt is { } at && (at < now.AddMinutes(5) || at > now.AddDays(90))) return RuleError("poll_time_invalid");

        return await ActingTransaction.RunAsync<CreatedPoll>(db, actor, async (conn, tx) =>
        {
            if (!await CanManageAsync(conn, tx, actor, groupId, ct)) return Forbidden;
            if (request.EventId is { } eventId && await ActingTransaction.ScalarAsync(conn, tx,
                    "select exists (select 1 from public.events where id = @e and group_id = @g)", ct, ("e", eventId), ("g", groupId)) is not true)
                return NotFound;

            var id = (Guid)(await ActingTransaction.ScalarAsync(conn, tx,
                """
                insert into public.polls (group_id, event_id, created_by, question, allows_multiple, is_anonymous, closes_at)
                values (@g, @e, @actor, @question, @multiple, @anonymous, @closes) returning id
                """, ct, ("g", groupId), ("e", request.EventId), ("actor", actor), ("question", question),
                ("multiple", request.AllowsMultiple), ("anonymous", request.IsAnonymous), ("closes", request.ClosesAt)))!;
            foreach (var (label, position) in options.Select((o, i) => (o, (short)i)))
            {
                await ActingTransaction.ExecuteAsync(conn, tx,
                    "insert into public.poll_options (poll_id, position, label) values (@p, @position, @label)", ct,
                    ("p", id), ("position", position), ("label", label));
            }
            await AuditAsync(conn, tx, actor, "poll.created", "poll", id, groupId, new { question }, ct);
            return new CreatedPoll(id);
        }, RuleError, ct);
    }

    private Task<Result> OnPollAsync(Guid actor, Guid id, string action, string sql, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            var group = await ActingTransaction.ScalarAsync(conn, tx, "select group_id from public.polls where id = @id for update", ct, ("id", id));
            if (group is not Guid groupId) return PollNotFound;
            if (!await CanManageAsync(conn, tx, actor, groupId, ct)) return Forbidden;
            await ActingTransaction.ExecuteAsync(conn, tx, sql, ct, ("id", id));
            await AuditAsync(conn, tx, actor, action, "poll", id, groupId, null, ct);
            return Result.Success();
        }, RuleError, ct);

    public Task<Result> ClosePollAsync(Guid actor, Guid id, CancellationToken ct) =>
        OnPollAsync(actor, id, "poll.closed", "update public.polls set closed_at = now() where id = @id and closed_at is null", ct);

    public Task<Result> DeletePollAsync(Guid actor, Guid id, CancellationToken ct) =>
        OnPollAsync(actor, id, "poll.deleted", "delete from public.polls where id = @id", ct);

    /// <summary>Writes due reminders (system job); returns how many went out.</summary>
    public async Task<int> SendRemindersAsync(CancellationToken ct)
    {
        await using var cmd = db.CreateCommand("select private.send_event_reminders()");
        return (int)(await cmd.ExecuteScalarAsync(ct))!;
    }

    [LoggerMessage(Level = LogLevel.Warning, Message = "Could not delete the replaced event cover {Path}")]
    private static partial void LogCoverCleanupFailed(ILogger logger, Exception ex, string path);
}

/// <summary>Runs the reminders every <c>Events:ReminderInterval</c> (default 5 minutes; zero turns it off).</summary>
internal sealed partial class EventReminderService(EventService events, IConfiguration configuration, ILogger<EventReminderService> logger)
    : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var interval = configuration.GetValue("Events:ReminderInterval", TimeSpan.FromMinutes(5));
        if (interval <= TimeSpan.Zero) return;

        using var timer = new PeriodicTimer(interval);
        do
        {
            // A database outage must not stop the API; the next run retries.
            try
            {
                await events.SendRemindersAsync(stoppingToken);
            }
            catch (Exception ex) when (ex is not OperationCanceledException)
            {
                LogRunFailed(logger, ex);
            }
        }
        while (await timer.WaitForNextTickAsync(stoppingToken));
    }

    [LoggerMessage(Level = LogLevel.Error, Message = "Event reminder run failed; will retry on the next run")]
    private static partial void LogRunFailed(ILogger logger, Exception ex);
}
