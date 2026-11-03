using System.Security.Claims;
using Gway.SharedKernel;
using Gway.SharedKernel.Auditing;
using Gway.SharedKernel.Database;
using Gway.SharedKernel.Http;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Npgsql;

namespace Gway.Modules.Live;

/// <summary>Can this chat call now; when not, why (a code the app shows as a sentence).</summary>
public sealed record CallEligibility(bool Allowed, string? Code, string? Message);

/// <summary>What the app needs to join the call's room.</summary>
public sealed record CallJoin(Guid CallId, string Url, string Token);

/// <summary>A group manager opens (<c>Active</c>) or closes a member's voice calls; closing needs a reason.</summary>
public sealed record GroupCallPermissionRequest(bool Active, string? Reason);

public static class CallEndpoints
{
    /// <summary>One-to-one voice calls between matched people (docs/ARCHITECTURE.md §8c).</summary>
    public static IEndpointRouteBuilder MapCallEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapGet("/conversations/{id:guid}/calls/eligibility", async (Guid id, ClaimsPrincipal user, CallService calls, CancellationToken ct) =>
            TypedResults.Ok(await calls.EligibilityAsync(user.GetUserId(), id, ct)));

        app.MapPost("/conversations/{id:guid}/calls", async (Guid id, ClaimsPrincipal user, CallService calls, CancellationToken ct) =>
            (await calls.StartAsync(user.GetUserId(), id, ct)).ToHttpResult());

        app.MapPost("/calls/{id:guid}/accept", async (Guid id, ClaimsPrincipal user, CallService calls, CancellationToken ct) =>
            (await calls.AcceptAsync(user.GetUserId(), id, ct)).ToHttpResult());

        app.MapPost("/calls/{id:guid}/token", async (Guid id, ClaimsPrincipal user, CallService calls, CancellationToken ct) =>
            (await calls.RejoinAsync(user.GetUserId(), id, ct)).ToHttpResult());

        app.MapPost("/calls/{id:guid}/decline", async (Guid id, ClaimsPrincipal user, CallService calls, CancellationToken ct) =>
            (await calls.DeclineAsync(user.GetUserId(), id, ct)).ToHttpResult());

        app.MapPost("/calls/{id:guid}/end", async (Guid id, ClaimsPrincipal user, CallService calls, CancellationToken ct) =>
            (await calls.EndAsync(user.GetUserId(), id, ct)).ToHttpResult());

        app.MapPut("/groups/{id:guid}/call-permissions/{userId:guid}", async (
                Guid id, Guid userId, GroupCallPermissionRequest body, ClaimsPrincipal user, CallService calls, CancellationToken ct) =>
            (await calls.SetPermissionAsync(user.GetUserId(), id, userId, body.Active, body.Reason, ct)).ToHttpResult());

        return app;
    }
}

/// <summary>
/// Calls: the database decides who may call (<c>private.call_blocker</c>, <c>private.start_call</c>); LiveKit carries the audio.
/// No audio is recorded.
/// </summary>
internal sealed partial class CallService(
    NpgsqlDataSource db,
    ILiveKit liveKit,
    IOptions<LiveKitOptions> options,
    ILogger<CallService> log)
{
    public static readonly TimeSpan RingFor = TimeSpan.FromSeconds(30);
    public static readonly TimeSpan MaxLength = TimeSpan.FromMinutes(60);

    private static readonly Error NotFound = Error.NotFound("call.not_found", "Görüşme bulunamadı.");
    private static readonly Error Over = Error.Conflict("call.over", "Bu görüşme sona erdi.");
    private static readonly Error Unavailable = Error.Unavailable("call.unavailable", "Sesli görüşme şu anda kullanılamıyor. Biraz sonra tekrar dene.");

    internal static Error RuleError(string code) => code switch
    {
        "call_no_permission" => Error.RuleViolation("call.no_permission",
            "Sesli görüşme yetkin yok. Profilindeki Sesli görüşme bölümünden talep edebilirsin."),
        "call_peer_no_permission" => Error.RuleViolation("call.peer_no_permission", "Bu kişinin sesli görüşme yetkisi yok."),
        "call_not_matched" => Error.RuleViolation("call.not_matched", "Sesli görüşme yalnızca eşleştiğin kişilerle ve ekip arkadaşlarınla yapılabilir."),
        "call_chat_locked" => Error.RuleViolation("call.chat_locked", "Sesli görüşme için Eşleşme Sohbeti paketi gerekir."),
        "call_peer_chat_locked" => Error.RuleViolation("call.peer_chat_locked", "Bu kişinin Eşleşme Sohbeti paketi olmadığı için aranamıyor."),
        "call_teammate_locked" => Error.RuleViolation("call.teammate_locked", "Ekip arkadaşını sesli aramak için Ekip Arkadaşı paketi gerekir."),
        "call_peer_teammate_locked" => Error.RuleViolation("call.peer_teammate_locked",
            "Bu kişinin Ekip Arkadaşı paketi olmadığı için aranamıyor."),
        "call_blocked" => Error.RuleViolation("call.blocked", "Engel olduğu için arama yapılamıyor."),
        "call_busy" => Error.Conflict("call.busy", "Sen ya da aradığın kişi şu anda başka bir görüşmede."),
        "call_rate_limited" => Error.RuleViolation("call.rate_limited", "Çok sık arama yapıyorsun. Biraz bekleyip tekrar dene."),
        "call_forbidden" => Error.Forbidden("call.forbidden", "Bu sohbetten arama yapılamaz."),
        "call_rank_violation" => PermissionRank,
        _ => Error.RuleViolation($"call.{code}", "Arama şu anda yapılamıyor. Sayfayı yenileyip tekrar dene."),
    };

    private static string Room(Guid callId) => $"call-{callId}";

    // People ------------------------------------------------------------------------------------

    public async Task<CallEligibility> EligibilityAsync(Guid actor, Guid conversation, CancellationToken ct)
    {
        await using var cmd = db.CreateCommand(
            """
            select case
              when not exists (select 1 from public.conversations c where c.id = @c and c.kind = 'direct' and @me in (c.user_a, c.user_b))
                then 'call_forbidden'
              else coalesce(
                private.call_blocker(@me, private.conversation_peer(@c, @me)),
                case when private.in_open_call(@me) or private.in_open_call(private.conversation_peer(@c, @me)) then 'call_busy' end)
            end
            """);
        cmd.Parameters.AddWithValue("c", conversation);
        cmd.Parameters.AddWithValue("me", actor);
        if (await cmd.ExecuteScalarAsync(ct) is not string code) return new CallEligibility(true, null, null);
        var error = RuleError(code);
        return new CallEligibility(false, error.Code, error.Message);
    }

    public async Task<Result<CallJoin>> StartAsync(Guid actor, Guid conversation, CancellationToken ct)
    {
        if (!options.Value.IsConfigured) return Unavailable;
        var started = await ActingTransaction.RunAsync<Guid>(db, actor, async (conn, tx) =>
            (Guid)(await ActingTransaction.ScalarAsync(conn, tx, "select private.start_call(@c)", ct, ("c", conversation)))!, RuleError, ct);
        if (!started.IsSuccess) return started.Error;
        try
        {
            await liveKit.CreateRoomAsync(Room(started.Value), ct);
        }
        catch (HttpRequestException ex)
        {
            LogLiveKitFailed(log, ex, Room(started.Value));
            await FinishAsync(started.Value, "canceled", "canceled", actor, ct);
            return Unavailable;
        }
        return await JoinAsync(started.Value, actor, ct);
    }

    public async Task<Result<CallJoin>> AcceptAsync(Guid actor, Guid callId, CancellationToken ct)
    {
        if (!options.Value.IsConfigured) return Unavailable;
        await using var cmd = db.CreateCommand(
            """
            update public.calls set status = 'active', answered_at = now()
            where id = @id and callee_id = @me and status = 'ringing'
            returning id
            """);
        cmd.Parameters.AddWithValue("id", callId);
        cmd.Parameters.AddWithValue("me", actor);
        if (await cmd.ExecuteScalarAsync(ct) is null) return await StateErrorAsync(actor, callId, ct);
        return await JoinAsync(callId, actor, ct);
    }

    /// <summary>A new token for a participant who lost the connection; the caller also needs it while ringing.</summary>
    public async Task<Result<CallJoin>> RejoinAsync(Guid actor, Guid callId, CancellationToken ct)
    {
        if (!options.Value.IsConfigured) return Unavailable;
        await using var cmd = db.CreateCommand(
            """
            select 1 from public.calls
            where id = @id and (status = 'active' and @me in (caller_id, callee_id) or status = 'ringing' and caller_id = @me)
            """);
        cmd.Parameters.AddWithValue("id", callId);
        cmd.Parameters.AddWithValue("me", actor);
        if (await cmd.ExecuteScalarAsync(ct) is null) return await StateErrorAsync(actor, callId, ct);
        return await JoinAsync(callId, actor, ct);
    }

    public async Task<Result> DeclineAsync(Guid actor, Guid callId, CancellationToken ct)
    {
        await using var cmd = db.CreateCommand("select 1 from public.calls where id = @id and callee_id = @me and status = 'ringing'");
        cmd.Parameters.AddWithValue("id", callId);
        cmd.Parameters.AddWithValue("me", actor);
        if (await cmd.ExecuteScalarAsync(ct) is null) return (await StateErrorAsync(actor, callId, ct)).Error!;
        await FinishAsync(callId, "declined", "declined", actor, ct);
        return Result.Success();
    }

    /// <summary>Hanging up: before an answer the caller cancels and the callee declines; afterwards either ends it.</summary>
    public async Task<Result> EndAsync(Guid actor, Guid callId, CancellationToken ct)
    {
        await using var cmd = db.CreateCommand(
            "select status, caller_id = @me from public.calls where id = @id and @me in (caller_id, callee_id)");
        cmd.Parameters.AddWithValue("id", callId);
        cmd.Parameters.AddWithValue("me", actor);
        string? status = null;
        var caller = false;
        await using (var r = await cmd.ExecuteReaderAsync(ct))
        {
            if (await r.ReadAsync(ct))
            {
                status = r.GetString(0);
                caller = r.GetBoolean(1);
            }
        }
        switch (status)
        {
            case null: return NotFound;
            case "ringing":
                await FinishAsync(callId, caller ? "canceled" : "declined", caller ? "canceled" : "declined", actor, ct);
                return Result.Success();
            case "active":
                await FinishAsync(callId, "ended", "hangup", actor, ct);
                return Result.Success();
            default:
                return Result.Success(); // already over: hanging up twice is fine
        }
    }

    private async Task<Result<CallJoin>> JoinAsync(Guid callId, Guid actor, CancellationToken ct)
    {
        await using var cmd = db.CreateCommand("select display_name from public.profiles where id = @me");
        cmd.Parameters.AddWithValue("me", actor);
        var name = await cmd.ExecuteScalarAsync(ct) as string ?? "";
        var token = liveKit.CreateJoinToken(Room(callId), actor, name, canPublish: true, new Dictionary<string, string>());
        return new CallJoin(callId, options.Value.Url, token);
    }

    private async Task<Result<CallJoin>> StateErrorAsync(Guid actor, Guid callId, CancellationToken ct)
    {
        await using var cmd = db.CreateCommand("select 1 from public.calls where id = @id and @me in (caller_id, callee_id)");
        cmd.Parameters.AddWithValue("id", callId);
        cmd.Parameters.AddWithValue("me", actor);
        return await cmd.ExecuteScalarAsync(ct) is null ? NotFound : Over;
    }

    /// <summary>Ends an open call (ringing or active) and closes its room. False when it was already over.</summary>
    private async Task<bool> FinishAsync(Guid callId, string status, string reason, Guid? by, CancellationToken ct)
    {
        await using var cmd = db.CreateCommand(
            """
            update public.calls set status = @status, end_reason = @reason, ended_at = now(), ended_by = @by
            where id = @id and status in ('ringing', 'active')
            """);
        cmd.Parameters.AddWithValue("id", callId);
        cmd.Parameters.AddWithValue("status", status);
        cmd.Parameters.AddWithValue("reason", reason);
        cmd.Parameters.Add(new NpgsqlParameter<Guid?>("by", by));
        var changed = await cmd.ExecuteNonQueryAsync(ct) == 1;
        await CloseRoomAsync(callId);
        return changed;
    }

    private async Task CloseRoomAsync(Guid callId)
    {
        if (!options.Value.IsConfigured) return;
        try
        {
            await liveKit.DeleteRoomAsync(Room(callId), CancellationToken.None);
        }
        catch (HttpRequestException ex)
        {
            LogLiveKitFailed(log, ex, Room(callId));
        }
    }

    /// <summary>
    /// Unanswered calls become missed after <see cref="RingFor"/>, calls end at <see cref="MaxLength"/>, and a call whose
    /// people may no longer call (permission closed, match ended, block) ends at once.
    /// </summary>
    public async Task SuperviseAsync(CancellationToken ct)
    {
        var due = new List<(Guid Id, string Status, string Reason)>();
        await using (var cmd = db.CreateCommand(
            """
            select id,
                   case when private.call_blocker(caller_id, callee_id) is not null then
                          case status when 'ringing' then 'canceled' else 'ended' end
                        when status = 'ringing' then 'missed' else 'ended' end,
                   case when private.call_blocker(caller_id, callee_id) is not null then 'not_allowed'
                        when status = 'ringing' then 'missed' else 'time_limit' end
            from public.calls
            where status in ('ringing', 'active')
              and (status = 'ringing' and created_at < now() - @ring
                   or status = 'active' and answered_at < now() - @max
                   or private.call_blocker(caller_id, callee_id) is not null)
            """))
        {
            cmd.Parameters.AddWithValue("ring", RingFor);
            cmd.Parameters.AddWithValue("max", MaxLength);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            while (await r.ReadAsync(ct)) due.Add((r.GetGuid(0), r.GetString(1), r.GetString(2)));
        }
        foreach (var (id, status, reason) in due) await FinishAsync(id, status, reason, null, ct);
    }

    // Group managers ----------------------------------------------------------------------------

    private static readonly Error PermissionRank = Error.RuleViolation(
        "call.rank_violation", "Kendinle eşit ya da senden yüksek rütbeli birinin sesli görüşme yetkisini kapatamazsın.");

    /// <summary>
    /// The owner or a calls.manage holder of the group the request went to opens it, declines it or closes the permission
    /// (docs/ARCHITECTURE.md §8c). Declining and closing follow the rank rule; the trigger checks it all again.
    /// </summary>
    public async Task<Result> SetPermissionAsync(Guid actorId, Guid groupId, Guid userId, bool active, string? reason, CancellationToken ct)
    {
        reason = reason?.Trim();
        if (!active && reason is not { Length: >= 3 and <= 500 })
            return Error.Validation("call.invalid_reason", "Gerekçe 3–500 karakter olmalı.");
        if (actorId == userId) return Error.Forbidden("call.self", "Kendi sesli görüşme talebine karar veremezsin.");

        var result = await ActingTransaction.RunAsync(db, actorId, async (conn, tx) =>
        {
            if (await ActingTransaction.ScalarAsync(conn, tx, "select private.user_has_group_permission(@a, @g, 'calls.manage')", ct,
                    ("a", actorId), ("g", groupId)) is not true)
                return Error.Forbidden("call.manage_forbidden", "Bu grupta sesli görüşme taleplerine karar verme yetkin yok.");

            var current = await ActingTransaction.ScalarAsync(conn, tx,
                "select status from public.call_permissions where user_id = @u and group_id = @g for update", ct,
                ("u", userId), ("g", groupId)) as string;
            if (current is not ("requested" or "active"))
                return Error.NotFound("call.permission_not_found", "Bu grupta bu kişinin bekleyen talebi ya da açık yetkisi yok.");

            var next = active ? "active" : current == "requested" ? "declined" : "revoked";
            if (current == next) return Result.Success();
            if (next != "active" && (int)(await ActingTransaction.ScalarAsync(conn, tx, "select private.group_rank(@g, @a)", ct,
                    ("g", groupId), ("a", actorId)))! <= (int)(await ActingTransaction.ScalarAsync(conn, tx,
                    "select private.group_rank(@g, @u)", ct, ("g", groupId), ("u", userId)))!)
                return PermissionRank;

            await ActingTransaction.ExecuteAsync(conn, tx,
                "update public.call_permissions set status = @status, reason = @reason, updated_at = now() where user_id = @u",
                ct, ("u", userId), ("status", next), ("reason", active ? null : reason));
            var action = next switch { "active" => "call_permission.granted", "declined" => "call_permission.declined", _ => "call_permission.revoked" };
            await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.User, action, "user", userId.ToString(),
                new { reason = active ? null : reason }, groupId), ct);
            return Result.Success();
        }, RuleError, ct);

        // A closed permission ends the person's call at once (the monitor would within seconds anyway).
        if (result.IsSuccess && !active) await SuperviseAsync(ct);
        return result;
    }


    [LoggerMessage(Level = LogLevel.Warning, Message = "LiveKit call failed for call room {Room}")]
    private static partial void LogLiveKitFailed(ILogger logger, Exception ex, string room);
}

/// <summary>Runs <see cref="CallService.SuperviseAsync"/> every <c>Calls:MonitorInterval</c> (default 5 seconds; zero turns it off).</summary>
internal sealed partial class CallMonitor(CallService calls, IConfiguration configuration, ILogger<CallMonitor> logger) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var interval = configuration.GetValue("Calls:MonitorInterval", TimeSpan.FromSeconds(5));
        if (interval <= TimeSpan.Zero) return;

        using var timer = new PeriodicTimer(interval);
        while (await timer.WaitForNextTickAsync(stoppingToken))
        {
            // A database or LiveKit outage must not stop the API; the next run retries.
            try
            {
                await calls.SuperviseAsync(stoppingToken);
            }
            catch (Exception ex) when (ex is not OperationCanceledException)
            {
                LogRunFailed(logger, ex);
            }
        }
    }

    [LoggerMessage(Level = LogLevel.Error, Message = "Call monitor run failed; will retry on the next run")]
    private static partial void LogRunFailed(ILogger logger, Exception ex);
}
