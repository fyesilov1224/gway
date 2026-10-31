using System.Security.Claims;
using Gway.SharedKernel;
using Gway.SharedKernel.Database;
using Gway.SharedKernel.Http;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Routing;
using Npgsql;

namespace Gway.Modules.Events;

public sealed record WelcomeRequest(string? Note);

public sealed record WelcomeTakeRequest(string? Note);

public static class WelcomeEndpoints
{
    /// <summary>Welcome at a first event (docs/ARCHITECTURE.md §3d, Karşılama). Becoming a greeter goes through Supabase.</summary>
    public static IEndpointRouteBuilder MapWelcomeEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapPost("/events/{id:guid}/welcome", async (Guid id, WelcomeRequest body, ClaimsPrincipal user, WelcomeService welcome, CancellationToken ct) =>
            (await welcome.RequestAsync(user.GetUserId(), id, body.Note, ct)).ToHttpResult());

        app.MapDelete("/events/{id:guid}/welcome", async (Guid id, ClaimsPrincipal user, WelcomeService welcome, CancellationToken ct) =>
            (await welcome.WithdrawAsync(user.GetUserId(), id, ct)).ToHttpResult());

        app.MapPut("/events/{id:guid}/welcome/{newcomerId:guid}/greeter", async (
                Guid id, Guid newcomerId, WelcomeTakeRequest body, ClaimsPrincipal user, WelcomeService welcome, CancellationToken ct) =>
            (await welcome.TakeAsync(user.GetUserId(), id, newcomerId, body.Note, ct)).ToHttpResult());

        app.MapDelete("/events/{id:guid}/welcome/{newcomerId:guid}/greeter", async (
                Guid id, Guid newcomerId, ClaimsPrincipal user, WelcomeService welcome, CancellationToken ct) =>
            (await welcome.ReleaseAsync(user.GetUserId(), id, newcomerId, ct)).ToHttpResult());

        app.MapPost("/events/{id:guid}/welcome/thanks", async (Guid id, ClaimsPrincipal user, WelcomeService welcome, CancellationToken ct) =>
            (await welcome.ThankAsync(user.GetUserId(), id, ct)).ToHttpResult());

        return app;
    }
}

/// <summary>Welcome writes; who may ask, take and thank is checked here and again by the database triggers.</summary>
internal sealed class WelcomeService(NpgsqlDataSource db, TimeProvider time)
{
    public const int MaxPerGreeter = 3;

    private static readonly Error NotFound = Error.NotFound("event.not_found", "Organizasyon bulunamadı.");
    private static readonly Error NoRequest = Error.NotFound("welcome.not_found", "Karşılama isteği bulunamadı.");
    private static readonly Error Closed = Error.RuleViolation("welcome.closed", "Organizasyon başladı ya da iptal edildi; karşılama değiştirilemez.");

    private static Error RuleError(string code) => code switch
    {
        "welcome_not_allowed" => Error.RuleViolation("welcome.not_going", "Karşılanmak için önce organizasyona katılmalısın."),
        "welcome_not_first_time" => Error.RuleViolation("welcome.not_first_time",
            "Bu grubun bir organizasyonuna daha önce katıldığın için karşılama isteği açamazsın."),
        "welcome_already_requested" => Error.Conflict("welcome.already_requested", "Bu grupta zaten açık bir karşılama isteğin var."),
        "welcome_take_not_allowed" => Error.Forbidden("welcome.take_not_allowed",
            "Karşılamak için grubun karşılayıcısı olmalı ve organizasyona katılıyor olmalısın."),
        "welcome_greeter_full" => Error.RuleViolation("welcome.greeter_full", $"Bir organizasyonda en fazla {MaxPerGreeter} kişiyi karşılayabilirsin."),
        "welcome_thanks_not_allowed" => Error.RuleViolation("welcome.thanks_not_allowed",
            "Teşekkür, organizasyon bittikten sonraki 30 gün içinde ve ikiniz de katıldıysanız gönderilebilir."),
        "welcome_closed" => Closed,
        _ => Error.RuleViolation($"welcome.{code}", "Bu işlem şu anda yapılamıyor. Sayfayı yenileyip tekrar dene."),
    };

    private sealed record EventRow(Guid GroupId, DateTimeOffset StartsAt, bool Canceled);

    private static async Task<EventRow?> LoadAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid id, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand("select group_id, starts_at, canceled_at is not null from public.events where id = @id", conn, tx);
        cmd.Parameters.AddWithValue("id", id);
        await using var r = await cmd.ExecuteReaderAsync(ct);
        return await r.ReadAsync(ct) ? new EventRow(r.GetGuid(0), r.GetFieldValue<DateTimeOffset>(1), r.GetBoolean(2)) : null;
    }

    private bool IsOpen(EventRow e) => !e.Canceled && e.StartsAt > time.GetUtcNow();

    private static async Task<bool> IsGoingAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid eventId, Guid user, CancellationToken ct) =>
        await ActingTransaction.ScalarAsync(conn, tx, "select private.is_going(@u, @e)", ct, ("u", user), ("e", eventId)) is true;

    public Task<Result> RequestAsync(Guid actor, Guid eventId, string? note, CancellationToken ct)
    {
        var text = string.IsNullOrWhiteSpace(note) ? null : note.Trim();
        if (text is { Length: > 200 }) return Task.FromResult<Result>(Error.Validation("welcome.invalid", "Not en fazla 200 karakter olabilir."));

        return ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            var e = await LoadAsync(conn, tx, eventId, ct);
            if (e is null) return NotFound;
            if (!IsOpen(e)) return Closed;
            if (!await IsGoingAsync(conn, tx, eventId, actor, ct)) return RuleError("welcome_not_allowed");
            if (await ActingTransaction.ScalarAsync(conn, tx, "select private.has_attended_in_group(@u, @g)", ct, ("u", actor), ("g", e.GroupId)) is true)
                return RuleError("welcome_not_first_time");

            await ActingTransaction.ExecuteAsync(conn, tx,
                "insert into public.event_welcomes (event_id, newcomer_id, group_id, newcomer_note) values (@e, @u, @g, @n)",
                ct, ("e", eventId), ("u", actor), ("g", e.GroupId), ("n", text));
            return Result.Success();
        }, RuleError, ct);
    }

    public Task<Result> WithdrawAsync(Guid actor, Guid eventId, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            var e = await LoadAsync(conn, tx, eventId, ct);
            if (e is null) return NotFound;
            if (!IsOpen(e)) return Closed;
            return await ActingTransaction.ExecuteAsync(conn, tx,
                "delete from public.event_welcomes where event_id = @e and newcomer_id = @u", ct, ("e", eventId), ("u", actor)) == 0
                ? NoRequest
                : Result.Success();
        }, RuleError, ct);

    public Task<Result> TakeAsync(Guid actor, Guid eventId, Guid newcomerId, string? note, CancellationToken ct)
    {
        var text = note?.Trim() ?? "";
        if (text.Length is < 3 or > 200)
            return Task.FromResult<Result>(Error.Validation("welcome.invalid", "Buluşma notu 3–200 karakter olmalı (ör. Girişteki kafenin önü, 08:45)."));

        return ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            var e = await LoadAsync(conn, tx, eventId, ct);
            if (e is null) return NotFound;
            if (!IsOpen(e)) return Closed;
            if (await ActingTransaction.ScalarAsync(conn, tx,
                    "select exists (select 1 from public.group_greeters where group_id = @g and user_id = @u)", ct, ("g", e.GroupId), ("u", actor)) is not true
                || !await IsGoingAsync(conn, tx, eventId, actor, ct))
                return RuleError("welcome_take_not_allowed");

            var current = await ActingTransaction.ScalarAsync(conn, tx,
                "select coalesce(greeter_id::text, '') from public.event_welcomes where event_id = @e and newcomer_id = @n for update",
                ct, ("e", eventId), ("n", newcomerId));
            if (current is not string greeter) return NoRequest;
            if (greeter.Length > 0 && greeter != actor.ToString())
                return Error.Conflict("welcome.taken", "Bu kişiyi başka bir karşılayıcı üstlendi.");

            await ActingTransaction.ExecuteAsync(conn, tx,
                "update public.event_welcomes set greeter_id = @a, greeter_note = @note where event_id = @e and newcomer_id = @n",
                ct, ("a", actor), ("note", text), ("e", eventId), ("n", newcomerId));
            return Result.Success();
        }, RuleError, ct);
    }

    public Task<Result> ReleaseAsync(Guid actor, Guid eventId, Guid newcomerId, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            var e = await LoadAsync(conn, tx, eventId, ct);
            if (e is null) return NotFound;
            if (!IsOpen(e)) return Closed;
            return await ActingTransaction.ExecuteAsync(conn, tx,
                """
                update public.event_welcomes set greeter_id = null, greeter_note = null, matched_at = null
                where event_id = @e and newcomer_id = @n and greeter_id = @a
                """, ct, ("e", eventId), ("n", newcomerId), ("a", actor)) == 0
                ? NoRequest
                : Result.Success();
        }, RuleError, ct);

    public Task<Result> ThankAsync(Guid actor, Guid eventId, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
            await ActingTransaction.ExecuteAsync(conn, tx,
                """
                update public.event_welcomes set thanked_at = now()
                where event_id = @e and newcomer_id = @u and greeter_id is not null and thanked_at is null
                """, ct, ("e", eventId), ("u", actor)) == 0
                ? NoRequest
                : Result.Success(), RuleError, ct);
}
