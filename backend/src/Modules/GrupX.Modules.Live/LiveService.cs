using System.Collections.Concurrent;
using System.Security.Claims;
using GrupX.Modules.Billing.Contracts;
using GrupX.Modules.Live.Contracts;
using GrupX.SharedKernel;
using GrupX.SharedKernel.Auditing;
using GrupX.SharedKernel.Database;
using GrupX.SharedKernel.Http;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Npgsql;

namespace GrupX.Modules.Live;

public sealed record StartLiveRequest(string? Title, DateTimeOffset? ScheduledAt);

public sealed record LiveCreated(Guid Id, string Status);

public sealed record LiveJoin(string Url, string Token, string Role);

public static class LiveModule
{
    public static IServiceCollection AddLiveModule(this IServiceCollection services)
    {
        services.AddOptions<LiveKitOptions>().BindConfiguration(LiveKitOptions.Section);
        services.TryAddSingleton(TimeProvider.System);
        services.AddHttpClient<ILiveKit, LiveKitClient>(http => http.Timeout = TimeSpan.FromSeconds(10));
        services.AddSingleton<LiveService>();
        services.AddSingleton<ILiveAdministration>(sp => sp.GetRequiredService<LiveService>());
        services.AddSingleton<ILiveModeration>(sp => sp.GetRequiredService<LiveService>());
        services.AddHostedService<LiveMonitor>();
        return services;
    }

    /// <summary>Live audio rooms (docs/ARCHITECTURE.md §8). Comments and reminders go through Supabase.</summary>
    public static IEndpointRouteBuilder MapLiveEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapPost("/groups/{id:guid}/live", async (Guid id, StartLiveRequest body, ClaimsPrincipal user, LiveService live, CancellationToken ct) =>
            (await live.CreateAsync(user.GetUserId(), id, body, ct)).ToHttpResult());

        var room = app.MapGroup("/live/{id:guid}");

        room.MapPost("/start", async (Guid id, ClaimsPrincipal user, LiveService live, CancellationToken ct) =>
            (await live.StartScheduledAsync(user.GetUserId(), id, ct)).ToHttpResult());

        room.MapDelete("", async (Guid id, ClaimsPrincipal user, LiveService live, CancellationToken ct) =>
            (await live.CancelAsync(user.GetUserId(), id, ct)).ToHttpResult());

        room.MapPost("/end", async (Guid id, ClaimsPrincipal user, LiveService live, CancellationToken ct) =>
            (await live.EndAsync(user.GetUserId(), id, ct)).ToHttpResult());

        room.MapPost("/token", async (Guid id, ClaimsPrincipal user, LiveService live, CancellationToken ct) =>
            (await live.JoinAsync(user.GetUserId(), id, ct)).ToHttpResult());

        room.MapPut("/hand", async (Guid id, ClaimsPrincipal user, LiveService live, CancellationToken ct) =>
            (await live.SetHandAsync(user.GetUserId(), id, raised: true, ct)).ToHttpResult());

        room.MapDelete("/hand", async (Guid id, ClaimsPrincipal user, LiveService live, CancellationToken ct) =>
            (await live.SetHandAsync(user.GetUserId(), id, raised: false, ct)).ToHttpResult());

        room.MapPut("/speakers/{userId:guid}", async (Guid id, Guid userId, ClaimsPrincipal user, LiveService live, CancellationToken ct) =>
            (await live.InviteToStageAsync(user.GetUserId(), id, userId, ct)).ToHttpResult());

        room.MapDelete("/speakers/{userId:guid}", async (Guid id, Guid userId, ClaimsPrincipal user, LiveService live, CancellationToken ct) =>
            (await live.RemoveFromStageAsync(user.GetUserId(), id, userId, ct)).ToHttpResult());

        room.MapPut("/muted/{userId:guid}", async (Guid id, Guid userId, ClaimsPrincipal user, LiveService live, CancellationToken ct) =>
            (await live.SetMutedAsync(user.GetUserId(), id, userId, muted: true, ct)).ToHttpResult());

        room.MapDelete("/muted/{userId:guid}", async (Guid id, Guid userId, ClaimsPrincipal user, LiveService live, CancellationToken ct) =>
            (await live.SetMutedAsync(user.GetUserId(), id, userId, muted: false, ct)).ToHttpResult());

        room.MapPost("/kicks/{userId:guid}", async (Guid id, Guid userId, ClaimsPrincipal user, LiveService live, CancellationToken ct) =>
            (await live.KickAsync(user.GetUserId(), id, userId, ct)).ToHttpResult());

        room.MapDelete("/comments/{commentId:long}", async (Guid id, long commentId, ClaimsPrincipal user, LiveService live, CancellationToken ct) =>
            (await live.DeleteCommentAsync(user.GetUserId(), id, commentId, ct)).ToHttpResult());

        return app;
    }
}

/// <summary>Starting, joining and moderating broadcasts; LiveKit is the source of truth for who is in a room.</summary>
internal sealed partial class LiveService(
    NpgsqlDataSource db,
    ILiveKit liveKit,
    IOptions<LiveKitOptions> options,
    IGroupPlanLimits planLimits,
    TimeProvider time,
    ILogger<LiveService> log) : ILiveAdministration, ILiveModeration
{
    public const int MaxStage = 10;
    public const int MaxScheduled = 5;
    public static readonly TimeSpan HostGrace = TimeSpan.FromMinutes(2);

    private static readonly Error NotFound = Error.NotFound("live.not_found", "Yayın bulunamadı.");
    private static readonly Error Forbidden = Error.Forbidden("live.forbidden", "Bu işlem için yetkin yok.");
    private static readonly Error NotLive = Error.Conflict("live.not_live", "Yayın şu anda canlı değil.");
    private static readonly Error AlreadyLive = Error.Conflict("live.already_live", "Grupta şu anda bir canlı yayın var.");
    private static readonly Error NotInRoom = Error.RuleViolation("live.not_in_room", "Kişi şu anda yayında değil.");
    private static readonly Error Unavailable = Error.Unavailable("live.unavailable", "Canlı yayın şu anda kullanılamıyor. Biraz sonra tekrar dene.");

    private static Error RuleError(string code) => code switch
    {
        "minutes_exhausted" => Error.RuleViolation("live.minutes_exhausted", "Grubun bu ayki canlı yayın dakikası doldu."),
        "too_many_scheduled" => Error.RuleViolation("live.too_many_scheduled", "Bir grupta en fazla 5 planlı yayın olabilir."),
        "schedule_invalid" => Error.Validation("live.schedule_invalid", "Planlı yayın en az 5 dakika, en fazla 30 gün sonraya olmalı."),
        "too_early" => Error.RuleViolation("live.too_early", "Planlı yayın, zamanından en çok 15 dakika önce başlatılabilir."),
        "live_forbidden" => Forbidden,
        _ => Error.RuleViolation($"live.{code}", "Bu işlem şu anda yapılamıyor. Sayfayı yenileyip tekrar dene."),
    };

    /// <summary>When each live broadcast's host was first seen missing from the room (one API instance).</summary>
    private readonly ConcurrentDictionary<Guid, DateTimeOffset> _hostAbsentSince = new();

    private sealed record Broadcast(Guid Id, Guid GroupId, Guid? HostId, string Status, DateTimeOffset? ScheduledAt)
    {
        public string Room => Id.ToString();
    }

    private static async Task<Broadcast?> LoadAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid id, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand(
            "select id, group_id, host_id, status, scheduled_at from public.live_broadcasts where id = @id for update", conn, tx);
        cmd.Parameters.AddWithValue("id", id);
        await using var r = await cmd.ExecuteReaderAsync(ct);
        if (!await r.ReadAsync(ct)) return null;
        return new Broadcast(r.GetGuid(0), r.GetGuid(1), r.IsDBNull(2) ? null : r.GetGuid(2), r.GetString(3),
            r.IsDBNull(4) ? null : r.GetFieldValue<DateTimeOffset>(4));
    }

    /// <summary>The broadcast for a group member; others learn nothing about it.</summary>
    private static async Task<Result<Broadcast>> LoadForMemberAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid actor, Guid id, CancellationToken ct)
    {
        var b = await LoadAsync(conn, tx, id, ct);
        if (b is null) return NotFound;
        var member = await ActingTransaction.ScalarAsync(conn, tx,
            "select exists (select 1 from public.group_members where group_id = @g and user_id = @u)", ct, ("g", b.GroupId), ("u", actor));
        return member is true ? b : NotFound;
    }

    private static async Task<bool> CanModerateAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Broadcast b, Guid actor, Guid target, CancellationToken ct) =>
        await ActingTransaction.ScalarAsync(conn, tx, "select private.can_moderate_live(@b, @actor, @target)", ct,
            ("b", b.Id), ("actor", actor), ("target", target)) is true;

    /// <summary>The host, or a live.moderate holder of the group.</summary>
    /// <summary>A group mute (docs/ARCHITECTURE.md §3e): the person only listens.</summary>
    private static async Task<bool> IsMutedAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid groupId, Guid userId, CancellationToken ct) =>
        await ActingTransaction.ScalarAsync(conn, tx, "select private.is_group_muted(@g, @u)", ct, ("g", groupId), ("u", userId)) is true;

    private static async Task<bool> IsManagerAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Broadcast b, Guid actor, CancellationToken ct) =>
        b.HostId == actor || await ActingTransaction.ScalarAsync(conn, tx,
            "select private.user_has_group_permission(@actor, @g, 'live.moderate')", ct, ("actor", actor), ("g", b.GroupId)) is true;

    private static Task AuditAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid? actor, string action, Broadcast b, object? data,
        CancellationToken ct, string actorKind = AuditActor.User) =>
        AuditLog.AppendAsync(conn, tx, new AuditEntry(actor, actorKind, action, "live_broadcast", b.Id.ToString(), data, b.GroupId), ct);

    /// <summary>Minutes left in the month; the live_broadcasts trigger checks the same.</summary>
    private async Task<int> MinutesLeftAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid groupId, CancellationToken ct)
    {
        var limits = await planLimits.GetAsync(conn, tx, groupId, ct);
        var used = (int)(await ActingTransaction.ScalarAsync(conn, tx, "select private.live_minutes_used(@g)", ct, ("g", groupId)))!;
        return limits.MonthlyLiveMinutes - used;
    }

    /// <summary>Locks the group so two starts cannot both pass the one-live check.</summary>
    private async Task<Error?> CheckCanGoLiveAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid groupId, CancellationToken ct)
    {
        await ActingTransaction.ExecuteAsync(conn, tx, "select 1 from public.groups where id = @g for update", ct, ("g", groupId));
        if (await ActingTransaction.ScalarAsync(conn, tx,
                "select exists (select 1 from public.live_broadcasts where group_id = @g and status = 'live')", ct, ("g", groupId)) is true)
            return AlreadyLive;
        return await MinutesLeftAsync(conn, tx, groupId, ct) <= 0 ? RuleError("minutes_exhausted") : null;
    }

    /// <summary>Opens the room inside the transaction: without a room the start rolls back.</summary>
    private async Task<Error?> OpenRoomAsync(string room, CancellationToken ct)
    {
        try
        {
            await liveKit.CreateRoomAsync(room, ct);
            return null;
        }
        catch (HttpRequestException ex)
        {
            LogLiveKitFailed(log, ex, room);
            return Unavailable;
        }
    }

    /// <summary>Closes the room after the database change committed; a failure only leaves a room the monitor can see.</summary>
    private async Task CloseRoomAsync(Guid id)
    {
        try
        {
            await liveKit.DeleteRoomAsync(id.ToString(), CancellationToken.None);
        }
        catch (HttpRequestException ex)
        {
            LogLiveKitFailed(log, ex, id.ToString());
        }
    }

    // Lifecycle --------------------------------------------------------------------------------

    public async Task<Result<LiveCreated>> CreateAsync(Guid actor, Guid groupId, StartLiveRequest request, CancellationToken ct)
    {
        ArgumentNullException.ThrowIfNull(request);
        if (!options.Value.IsConfigured) return Unavailable;
        var title = request.Title?.Trim() ?? "";
        if (title.Length is < 3 or > 80) return Error.Validation("live.invalid_title", "Başlık 3–80 karakter olmalı.");
        var now = time.GetUtcNow();
        if (request.ScheduledAt is { } at && (at < now.AddMinutes(5) || at > now.AddDays(30))) return RuleError("schedule_invalid");

        return await ActingTransaction.RunAsync<LiveCreated>(db, actor, async (conn, tx) =>
        {
            if (await ActingTransaction.ScalarAsync(conn, tx, "select private.user_has_group_permission(@a, @g, 'live.start')", ct,
                    ("a", actor), ("g", groupId)) is not true)
                return Error.Forbidden("live.start_forbidden", "Bu grupta yayın başlatma yetkin yok.");

            if (request.ScheduledAt is { } scheduledAt)
            {
                var scheduled = (long)(await ActingTransaction.ScalarAsync(conn, tx,
                    "select count(*) from public.live_broadcasts where group_id = @g and status = 'scheduled'", ct, ("g", groupId)))!;
                if (scheduled >= MaxScheduled) return RuleError("too_many_scheduled");
                var planned = (Guid)(await ActingTransaction.ScalarAsync(conn, tx,
                    """
                    insert into public.live_broadcasts (group_id, host_id, title, status, scheduled_at)
                    values (@g, @host, @title, 'scheduled', @at) returning id
                    """, ct, ("g", groupId), ("host", actor), ("title", title), ("at", scheduledAt)))!;
                return new LiveCreated(planned, "scheduled");
            }

            if (await CheckCanGoLiveAsync(conn, tx, groupId, ct) is { } blocked) return blocked;
            var id = (Guid)(await ActingTransaction.ScalarAsync(conn, tx,
                "insert into public.live_broadcasts (group_id, host_id, title, status) values (@g, @host, @title, 'live') returning id",
                ct, ("g", groupId), ("host", actor), ("title", title)))!;
            var b = new Broadcast(id, groupId, actor, "live", null);
            await AuditAsync(conn, tx, actor, "live.started", b, new { title }, ct);
            return await OpenRoomAsync(b.Room, ct) is { } failed ? failed : new LiveCreated(id, "live");
        }, RuleError, ct);
    }

    public async Task<Result<LiveCreated>> StartScheduledAsync(Guid actor, Guid id, CancellationToken ct)
    {
        if (!options.Value.IsConfigured) return Unavailable;
        return await ActingTransaction.RunAsync<LiveCreated>(db, actor, async (conn, tx) =>
        {
            var loaded = await LoadForMemberAsync(conn, tx, actor, id, ct);
            if (!loaded.IsSuccess) return loaded.Error;
            var b = loaded.Value;
            if (b.Status != "scheduled") return Error.Conflict("live.not_scheduled", "Bu yayın artık planlı değil.");
            if (b.HostId != actor) return Forbidden;
            if (time.GetUtcNow() < b.ScheduledAt!.Value.AddMinutes(-15)) return RuleError("too_early");
            if (await CheckCanGoLiveAsync(conn, tx, b.GroupId, ct) is { } blocked) return blocked;

            await ActingTransaction.ExecuteAsync(conn, tx, "update public.live_broadcasts set status = 'live' where id = @id", ct, ("id", id));
            await AuditAsync(conn, tx, actor, "live.started", b, null, ct);
            return await OpenRoomAsync(b.Room, ct) is { } failed ? failed : new LiveCreated(id, "live");
        }, RuleError, ct);
    }

    public Task<Result> CancelAsync(Guid actor, Guid id, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            var loaded = await LoadForMemberAsync(conn, tx, actor, id, ct);
            if (!loaded.IsSuccess) return loaded.Error;
            var b = loaded.Value;
            if (b.Status != "scheduled") return Error.Conflict("live.not_scheduled", "Bu yayın artık planlı değil.");
            if (b.HostId != actor && !await CanModerateAsync(conn, tx, b, actor, b.HostId ?? Guid.Empty, ct)) return Forbidden;

            await ActingTransaction.ExecuteAsync(conn, tx, "update public.live_broadcasts set status = 'canceled' where id = @id", ct, ("id", id));
            await AuditAsync(conn, tx, actor, "live.canceled", b, null, ct);
            return Result.Success();
        }, RuleError, ct);

    public async Task<Result> EndAsync(Guid actor, Guid id, CancellationToken ct)
    {
        var ended = await ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            var loaded = await LoadForMemberAsync(conn, tx, actor, id, ct);
            if (!loaded.IsSuccess) return loaded.Error;
            var b = loaded.Value;
            if (b.Status != "live") return NotLive;
            string reason;
            if (b.HostId == actor) reason = "host";
            else if (await CanModerateAsync(conn, tx, b, actor, b.HostId ?? Guid.Empty, ct)) reason = "moderator";
            else return Forbidden;

            await ActingTransaction.ExecuteAsync(conn, tx,
                "update public.live_broadcasts set status = 'ended', end_reason = @reason where id = @id", ct, ("id", id), ("reason", reason));
            await AuditAsync(conn, tx, actor, "live.ended", b, new { reason }, ct);
            return Result.Success();
        }, RuleError, ct);

        if (ended.IsSuccess) await CloseRoomAsync(id);
        return ended;
    }

    // In the room ------------------------------------------------------------------------------

    public async Task<Result<LiveJoin>> JoinAsync(Guid actor, Guid id, CancellationToken ct)
    {
        if (!options.Value.IsConfigured) return Unavailable;
        return await ActingTransaction.RunAsync<LiveJoin>(db, actor, async (conn, tx) =>
        {
            var loaded = await LoadForMemberAsync(conn, tx, actor, id, ct);
            if (!loaded.IsSuccess) return loaded.Error;
            var b = loaded.Value;
            if (b.Status != "live") return NotLive;
            if (await ActingTransaction.ScalarAsync(conn, tx, "select private.can_join_live(@b, @u)", ct, ("b", id), ("u", actor)) is not true)
            {
                var kicked = await ActingTransaction.ScalarAsync(conn, tx,
                    "select exists (select 1 from public.live_kicks where broadcast_id = @b and user_id = @u)", ct, ("b", id), ("u", actor));
                return kicked is true
                    ? Error.RuleViolation("live.kicked", "Bu yayından çıkarıldın.")
                    : Error.RuleViolation("live.cannot_join", "Bu yayına şu anda katılamazsın.");
            }

            string name = "", avatar = "";
            await using (var profile = new NpgsqlCommand("select display_name, coalesce(avatar_path, '') from public.profiles where id = @u", conn, tx))
            {
                profile.Parameters.AddWithValue("u", actor);
                await using var r = await profile.ExecuteReaderAsync(ct);
                if (await r.ReadAsync(ct)) (name, avatar) = (r.GetString(0), r.GetString(1));
            }
            var rank = (int)(await ActingTransaction.ScalarAsync(conn, tx, "select private.group_rank(@g, @u)", ct, ("g", b.GroupId), ("u", actor)))!;
            var role = b.HostId == actor ? LiveRoles.Host : LiveRoles.Listener;
            var muted = await IsMutedAsync(conn, tx, b.GroupId, actor, ct);
            var token = liveKit.CreateJoinToken(b.Room, actor, name, canPublish: role == LiveRoles.Host && !muted, new Dictionary<string, string>
            {
                [LiveRoles.Attribute] = role,
                ["muted"] = muted ? "1" : "",
                ["rank"] = rank.ToString(System.Globalization.CultureInfo.InvariantCulture),
                ["avatar"] = avatar,
            });
            return new LiveJoin(options.Value.Url, token, role);
        }, RuleError, ct);
    }

    /// <summary>Runs a room action on a live broadcast the actor may be in; LiveKit failures become 503.</summary>
    private async Task<Result> InRoomAsync(Guid actor, Guid id, Func<NpgsqlConnection, NpgsqlTransaction, Broadcast, Task<Result>> action, CancellationToken ct)
    {
        try
        {
            return await ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
            {
                var loaded = await LoadForMemberAsync(conn, tx, actor, id, ct);
                if (!loaded.IsSuccess) return loaded.Error;
                return loaded.Value.Status == "live" ? await action(conn, tx, loaded.Value) : NotLive;
            }, RuleError, ct);
        }
        catch (HttpRequestException ex)
        {
            LogLiveKitFailed(log, ex, id.ToString());
            return Unavailable;
        }
    }

    private async Task<LiveParticipant?> ParticipantAsync(Broadcast b, Guid userId, CancellationToken ct) =>
        (await liveKit.ListParticipantsAsync(b.Room, ct)).FirstOrDefault(p => p.Identity == userId.ToString());

    public Task<Result> SetHandAsync(Guid actor, Guid id, bool raised, CancellationToken ct) =>
        InRoomAsync(actor, id, async (conn, tx, b) =>
        {
            if (raised && await IsMutedAsync(conn, tx, b.GroupId, actor, ct))
                return Error.RuleViolation("live.muted", "Bu grupta susturulduğun için el kaldıramazsın.");
            var hand = raised ? time.GetUtcNow().ToUnixTimeMilliseconds().ToString(System.Globalization.CultureInfo.InvariantCulture) : "";
            return await liveKit.UpdateParticipantAsync(b.Room, actor, null, new Dictionary<string, string> { ["hand"] = hand }, ct)
                ? Result.Success()
                : Error.RuleViolation("live.not_joined", "Önce yayına katılmalısın.");
        }, ct);

    public Task<Result> InviteToStageAsync(Guid actor, Guid id, Guid target, CancellationToken ct) =>
        InRoomAsync(actor, id, async (conn, tx, b) =>
        {
            if (!await IsManagerAsync(conn, tx, b, actor, ct)) return Forbidden;
            var participants = await liveKit.ListParticipantsAsync(b.Room, ct);
            var person = participants.FirstOrDefault(p => p.Identity == target.ToString());
            if (person is null) return NotInRoom;
            if (person.OnStage) return Result.Success();
            if (await IsMutedAsync(conn, tx, b.GroupId, target, ct))
                return Error.RuleViolation("live.target_muted", "Bu kişi grupta susturulduğu için sahneye alınamaz.");
            if (participants.Count(p => p.OnStage) >= MaxStage)
                return Error.RuleViolation("live.stage_full", "Sahne dolu. Aynı anda en fazla 10 kişi konuşabilir.");

            await liveKit.UpdateParticipantAsync(b.Room, target, canPublish: true, new Dictionary<string, string>
            {
                [LiveRoles.Attribute] = LiveRoles.Speaker,
                ["hand"] = "",
                ["muted"] = "",
            }, ct);
            return Result.Success();
        }, ct);

    public Task<Result> RemoveFromStageAsync(Guid actor, Guid id, Guid target, CancellationToken ct) =>
        InRoomAsync(actor, id, async (conn, tx, b) =>
        {
            if (target == b.HostId) return Error.RuleViolation("live.host_stays", "Sunucu sahneden indirilemez.");
            if (target != actor && !await CanModerateAsync(conn, tx, b, actor, target, ct)) return Forbidden;
            if (!await liveKit.UpdateParticipantAsync(b.Room, target, canPublish: false, new Dictionary<string, string>
                {
                    [LiveRoles.Attribute] = LiveRoles.Listener,
                    ["muted"] = "",
                }, ct))
                return NotInRoom;
            if (target != actor) await AuditAsync(conn, tx, actor, "live.speaker_removed", b, new { userId = target }, ct);
            return Result.Success();
        }, ct);

    public Task<Result> SetMutedAsync(Guid actor, Guid id, Guid target, bool muted, CancellationToken ct) =>
        InRoomAsync(actor, id, async (conn, tx, b) =>
        {
            if (!await CanModerateAsync(conn, tx, b, actor, target, ct)) return Forbidden;
            var person = await ParticipantAsync(b, target, ct);
            if (person is null) return NotInRoom;
            if (!person.OnStage) return Error.RuleViolation("live.not_on_stage", "Kişi sahnede değil.");

            await liveKit.UpdateParticipantAsync(b.Room, target, canPublish: !muted,
                new Dictionary<string, string> { ["muted"] = muted ? "1" : "" }, ct);
            await AuditAsync(conn, tx, actor, muted ? "live.muted" : "live.unmuted", b, new { userId = target }, ct);
            return Result.Success();
        }, ct);

    public Task<Result> KickAsync(Guid actor, Guid id, Guid target, CancellationToken ct) =>
        InRoomAsync(actor, id, async (conn, tx, b) =>
        {
            if (target == actor) return Error.Validation("live.kick_self", "Kendini yayından atamazsın.");
            if (!await CanModerateAsync(conn, tx, b, actor, target, ct)) return Forbidden;

            await ActingTransaction.ExecuteAsync(conn, tx,
                "insert into public.live_kicks (broadcast_id, user_id) values (@b, @u) on conflict do nothing", ct, ("b", id), ("u", target));
            await AuditAsync(conn, tx, actor, "live.kicked", b, new { userId = target }, ct);
            await liveKit.RemoveParticipantAsync(b.Room, target, ct);
            return Result.Success();
        }, ct);

    public Task<Result> DeleteCommentAsync(Guid actor, Guid id, long commentId, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            var loaded = await LoadForMemberAsync(conn, tx, actor, id, ct);
            if (!loaded.IsSuccess) return loaded.Error;
            var b = loaded.Value;
            var author = await ActingTransaction.ScalarAsync(conn, tx,
                "select user_id from public.live_comments where id = @c and broadcast_id = @b", ct, ("c", commentId), ("b", id));
            if (author is not Guid authorId) return Error.NotFound("live.comment_not_found", "Yorum bulunamadı.");
            if (authorId != actor && !await CanModerateAsync(conn, tx, b, actor, authorId, ct)) return Forbidden;

            await ActingTransaction.ExecuteAsync(conn, tx, "delete from public.live_comments where id = @c", ct, ("c", commentId));
            if (authorId != actor) await AuditAsync(conn, tx, actor, "live.comment_removed", b, new { userId = authorId }, ct);
            return Result.Success();
        }, RuleError, ct);

    // Group sanctions (docs/ARCHITECTURE.md §3e) ------------------------------------------------

    public async Task<bool> RemoveCommentAsync(NpgsqlConnection connection, NpgsqlTransaction transaction, long commentId, CancellationToken ct) =>
        await ActingTransaction.ExecuteAsync(connection, transaction, "delete from public.live_comments where id = @c", ct, ("c", commentId)) > 0;

    public async Task EnforceSanctionAsync(Guid groupId, Guid userId, CancellationToken ct)
    {
        if (!options.Value.IsConfigured) return;
        Guid? broadcast;
        bool member, muted;
        await using (var cmd = db.CreateCommand(
            """
            select (select id from public.live_broadcasts where group_id = @g and status = 'live'),
                   exists (select 1 from public.group_members where group_id = @g and user_id = @u),
                   private.is_group_muted(@g, @u)
            """))
        {
            cmd.Parameters.AddWithValue("g", groupId);
            cmd.Parameters.AddWithValue("u", userId);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            await r.ReadAsync(ct);
            (broadcast, member, muted) = (r.IsDBNull(0) ? null : r.GetGuid(0), r.GetBoolean(1), r.GetBoolean(2));
        }
        if (broadcast is not { } id || (member && !muted)) return;

        try
        {
            if (!member)
            {
                await liveKit.RemoveParticipantAsync(id.ToString(), userId, ct);
                return;
            }
            await liveKit.UpdateParticipantAsync(id.ToString(), userId, canPublish: false, new Dictionary<string, string>
            {
                [LiveRoles.Attribute] = LiveRoles.Listener,
                ["hand"] = "",
                ["muted"] = "1",
            }, ct);
        }
        catch (HttpRequestException ex)
        {
            LogLiveKitFailed(log, ex, id.ToString());
        }
    }

    // Platform team ----------------------------------------------------------------------------

    public async Task<Result> ForceEndAsync(Guid actorId, Guid broadcastId, string reason, CancellationToken ct)
    {
        reason = reason?.Trim() ?? "";
        if (reason.Length is < 3 or > 500) return Error.Validation("live.invalid_reason", "Gerekçe 3–500 karakter olmalı.");

        var ended = await ActingTransaction.RunAsync(db, actorId, async (conn, tx) =>
        {
            var b = await LoadAsync(conn, tx, broadcastId, ct);
            if (b is null) return NotFound;
            if (b.Status != "live") return NotLive;
            await ActingTransaction.ExecuteAsync(conn, tx,
                "update public.live_broadcasts set status = 'ended', end_reason = 'admin' where id = @id", ct, ("id", broadcastId));
            await AuditAsync(conn, tx, actorId, "live.force_ended", b, new { reason }, ct, AuditActor.Staff);
            return Result.Success();
        }, RuleError, ct);

        if (ended.IsSuccess) await CloseRoomAsync(broadcastId);
        return ended;
    }

    public async Task<IReadOnlyDictionary<Guid, int>> ParticipantCountsAsync(IReadOnlyCollection<Guid> broadcastIds, CancellationToken ct)
    {
        if (!options.Value.IsConfigured || broadcastIds.Count == 0) return new Dictionary<Guid, int>();
        try
        {
            var rooms = await liveKit.ListRoomsAsync([.. broadcastIds.Select(id => id.ToString())], ct);
            return rooms.ToDictionary(r => Guid.Parse(r.Key), r => r.Value);
        }
        catch (HttpRequestException ex)
        {
            LogLiveKitFailed(log, ex, "list");
            return new Dictionary<Guid, int>();
        }
    }

    // Monitor ----------------------------------------------------------------------------------

    /// <summary>
    /// Ends broadcasts whose room closed, whose host has been away too long or whose group ran out of minutes,
    /// and cancels scheduled ones an hour overdue (docs/ARCHITECTURE.md §8, Gözetim). These are system writes.
    /// </summary>
    public async Task SuperviseAsync(CancellationToken ct)
    {
        await using var conn = await db.OpenConnectionAsync(ct);
        await using (var cancel = new NpgsqlCommand(
            "update public.live_broadcasts set status = 'canceled' where status = 'scheduled' and scheduled_at < now() - interval '1 hour'", conn))
        {
            await cancel.ExecuteNonQueryAsync(ct);
        }
        if (!options.Value.IsConfigured) return;

        var live = new List<(Broadcast B, DateTimeOffset StartedAt, int MinutesLeft)>();
        await using (var cmd = new NpgsqlCommand(
            "select id, group_id, host_id, started_at, private.live_minutes_left(group_id) from public.live_broadcasts where status = 'live'", conn))
        {
            await using var r = await cmd.ExecuteReaderAsync(ct);
            while (await r.ReadAsync(ct))
            {
                live.Add((new Broadcast(r.GetGuid(0), r.GetGuid(1), r.IsDBNull(2) ? null : r.GetGuid(2), "live", null),
                    r.GetFieldValue<DateTimeOffset>(3), r.GetInt32(4)));
            }
        }
        foreach (var gone in _hostAbsentSince.Keys.Except(live.Select(l => l.B.Id))) _hostAbsentSince.TryRemove(gone, out _);
        if (live.Count == 0) return;

        var now = time.GetUtcNow();
        var rooms = await liveKit.ListRoomsAsync([.. live.Select(l => l.B.Room)], ct);
        foreach (var (b, startedAt, minutesLeft) in live)
        {
            string? reason = null;
            if (!rooms.ContainsKey(b.Room))
            {
                if (now - startedAt > TimeSpan.FromMinutes(1)) reason = "empty";
            }
            else if (minutesLeft <= 0)
            {
                reason = "limit";
            }
            else if (b.HostId is { } host && (await liveKit.ListParticipantsAsync(b.Room, ct)).Any(p => p.Identity == host.ToString()))
            {
                _hostAbsentSince.TryRemove(b.Id, out _);
            }
            else if (now - _hostAbsentSince.GetOrAdd(b.Id, now) >= HostGrace)
            {
                reason = "host_left";
            }

            if (reason is null) continue;
            await using (var tx = await conn.BeginTransactionAsync(ct))
            {
                await using var end = new NpgsqlCommand(
                    "update public.live_broadcasts set status = 'ended', end_reason = @reason where id = @id and status = 'live'", conn, tx);
                end.Parameters.AddWithValue("id", b.Id);
                end.Parameters.AddWithValue("reason", reason);
                if (await end.ExecuteNonQueryAsync(ct) == 1) await AuditAsync(conn, tx, null, "live.ended", b, new { reason }, ct, AuditActor.System);
                await tx.CommitAsync(ct);
            }
            _hostAbsentSince.TryRemove(b.Id, out _);
            await CloseRoomAsync(b.Id);
        }
    }

    [LoggerMessage(Level = LogLevel.Warning, Message = "LiveKit call failed for room {Room}")]
    private static partial void LogLiveKitFailed(ILogger logger, Exception ex, string room);
}

/// <summary>Runs <see cref="LiveService.SuperviseAsync"/> every <c>Live:MonitorInterval</c> (default 30 seconds; zero turns it off).</summary>
internal sealed partial class LiveMonitor(LiveService live, IConfiguration configuration, ILogger<LiveMonitor> logger) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var interval = configuration.GetValue("Live:MonitorInterval", TimeSpan.FromSeconds(30));
        if (interval <= TimeSpan.Zero) return;

        using var timer = new PeriodicTimer(interval);
        while (await timer.WaitForNextTickAsync(stoppingToken))
        {
            // A database or LiveKit outage must not stop the API; the next run retries.
            try
            {
                await live.SuperviseAsync(stoppingToken);
            }
            catch (Exception ex) when (ex is not OperationCanceledException)
            {
                LogRunFailed(logger, ex);
            }
        }
    }

    [LoggerMessage(Level = LogLevel.Error, Message = "Live monitor run failed; will retry on the next run")]
    private static partial void LogRunFailed(ILogger logger, Exception ex);
}
