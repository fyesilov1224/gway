using System.Security.Claims;
using GrupX.SharedKernel;
using GrupX.SharedKernel.Auditing;
using GrupX.SharedKernel.Database;
using GrupX.SharedKernel.Http;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Npgsql;

namespace GrupX.Modules.Events;

public sealed record GoalRequest(
    string? Title, string? Description, string? Kind, string? Metric, int? Target, DateTimeOffset StartsAt, DateTimeOffset EndsAt);

public sealed record CreatedGoal(Guid Id);

public sealed record TeamRequest(string? Name, IReadOnlyList<Guid>? MemberIds);

public sealed record CreatedTeam(Guid Id);

public static class GoalEndpoints
{
    /// <summary>Goals, teams and task claims (docs/ARCHITECTURE.md §3d, Hedefler ve görevler). Claims are written through Supabase.</summary>
    public static IEndpointRouteBuilder MapGoalEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapPost("/groups/{id:guid}/goals", async (Guid id, GoalRequest body, ClaimsPrincipal user, GoalService goals, CancellationToken ct) =>
            (await goals.CreateAsync(user.GetUserId(), id, body, ct)).ToHttpResult());

        app.MapPost("/goals/{id:guid}/cancellation", async (Guid id, ClaimsPrincipal user, GoalService goals, CancellationToken ct) =>
            (await goals.CancelAsync(user.GetUserId(), id, staff: false, ct)).ToHttpResult());

        app.MapPost("/goals/{id:guid}/teams", async (Guid id, TeamRequest body, ClaimsPrincipal user, GoalService goals, CancellationToken ct) =>
            (await goals.CreateTeamAsync(user.GetUserId(), id, body, ct)).ToHttpResult());

        app.MapDelete("/goals/{id:guid}/teams/{teamId:guid}", async (Guid id, Guid teamId, ClaimsPrincipal user, GoalService goals, CancellationToken ct) =>
            (await goals.DeleteTeamAsync(user.GetUserId(), id, teamId, ct)).ToHttpResult());

        app.MapPost("/goals/{id:guid}/claims/{userId:guid}/approval", async (
                Guid id, Guid userId, ClaimsPrincipal user, GoalService goals, CancellationToken ct) =>
            (await goals.DecideClaimAsync(user.GetUserId(), id, userId, approve: true, ct)).ToHttpResult());

        app.MapDelete("/goals/{id:guid}/claims/{userId:guid}", async (
                Guid id, Guid userId, ClaimsPrincipal user, GoalService goals, CancellationToken ct) =>
            (await goals.DecideClaimAsync(user.GetUserId(), id, userId, approve: false, ct)).ToHttpResult());

        return app;
    }
}

/// <summary>Goal writes; progress is measured and completions are recorded by the database (docs/ARCHITECTURE.md §3d).</summary>
internal sealed class GoalService(NpgsqlDataSource db, TimeProvider time)
{
    /// <summary>Records reached goals (system job, docs/ARCHITECTURE.md §3d); returns how many.</summary>
    public async Task<int> RecordCompletionsAsync(CancellationToken ct)
    {
        await using var cmd = db.CreateCommand("select private.record_goal_completions()");
        return (int)(await cmd.ExecuteScalarAsync(ct))!;
    }

    public const int MaxRunning = 5;
    public static readonly string[] Kinds = ["personal", "group", "team", "task"];
    public static readonly string[] Metrics = ["attended", "organized", "memories"];

    private static readonly Error NotFound = Error.NotFound("goal.not_found", "Hedef bulunamadı.");
    private static readonly Error Forbidden = Error.Forbidden("goal.forbidden", "Bu grupta hedef yönetme yetkin yok.");

    private static Error Invalid(string message) => Error.Validation("goal.invalid", message);

    private static Error RuleError(string code) => code switch
    {
        "goal_limit_reached" => Error.RuleViolation("goal.limit_reached", $"Bir grupta aynı anda en fazla {MaxRunning} hedef olabilir."),
        "goal_period_invalid" => Invalid("Hedefin bitişi gelecekte olmalı."),
        "goal_team_invalid" => Invalid("Takıma yalnızca grubun üyeleri, her biri tek takıma eklenebilir."),
        "goal_forbidden" or "claim_forbidden" => Forbidden,
        _ => Error.RuleViolation($"goal.{code}", "Bu işlem şu anda yapılamıyor. Sayfayı yenileyip tekrar dene."),
    };

    private sealed record GoalRow(Guid Id, Guid GroupId, string Kind, DateTimeOffset EndsAt, bool Canceled);

    private static async Task<GoalRow?> LoadAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid id, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand(
            "select id, group_id, kind, ends_at, canceled_at is not null from public.goals where id = @id for update", conn, tx);
        cmd.Parameters.AddWithValue("id", id);
        await using var r = await cmd.ExecuteReaderAsync(ct);
        return await r.ReadAsync(ct) ? new GoalRow(r.GetGuid(0), r.GetGuid(1), r.GetString(2), r.GetFieldValue<DateTimeOffset>(3), r.GetBoolean(4)) : null;
    }

    private static async Task<bool> CanManageAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid actor, Guid groupId, CancellationToken ct) =>
        await ActingTransaction.ScalarAsync(conn, tx, "select private.user_has_group_permission(@a, @g, 'events.manage')", ct,
            ("a", actor), ("g", groupId)) is true;

    private static Task AuditAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid actor, string actorKind, string action, Guid goal, Guid groupId,
        object? data, CancellationToken ct) =>
        AuditLog.AppendAsync(conn, tx, new AuditEntry(actor, actorKind, action, "goal", goal.ToString(), data, groupId), ct);

    public async Task<Result<CreatedGoal>> CreateAsync(Guid actor, Guid groupId, GoalRequest r, CancellationToken ct)
    {
        ArgumentNullException.ThrowIfNull(r);
        var title = r.Title?.Trim() ?? "";
        var description = r.Description?.Trim() ?? "";
        if (title.Length is < 3 or > 80) return Invalid("Başlık 3–80 karakter olmalı.");
        if (description.Length > 500) return Invalid("Açıklama en fazla 500 karakter olabilir.");
        if (r.Kind is null || !Kinds.Contains(r.Kind)) return Invalid("Hedef türünü seç.");
        var task = r.Kind == "task";
        if (task ? r.Metric is not null || r.Target is not null : r.Metric is null || !Metrics.Contains(r.Metric) || r.Target is not (>= 1 and <= 1000))
            return Invalid("Ölçülen hedefte ölçüt (katılım, düzenleme, anı) ve 1–1000 arası bir sayı seç; görevde ikisi de olmaz.");
        if (r.EndsAt <= r.StartsAt || r.EndsAt - r.StartsAt > TimeSpan.FromDays(92)) return Invalid("Hedefin dönemi en fazla 92 gün olabilir.");
        if (r.EndsAt <= time.GetUtcNow()) return RuleError("goal_period_invalid");

        return await ActingTransaction.RunAsync<CreatedGoal>(db, actor, async (conn, tx) =>
        {
            if (!await CanManageAsync(conn, tx, actor, groupId, ct)) return Forbidden;
            await ActingTransaction.ExecuteAsync(conn, tx, "select 1 from public.groups where id = @g for update", ct, ("g", groupId));
            var running = (long)(await ActingTransaction.ScalarAsync(conn, tx,
                "select count(*) from public.goals where group_id = @g and canceled_at is null and ends_at > now()", ct, ("g", groupId)))!;
            if (running >= MaxRunning) return RuleError("goal_limit_reached");

            var id = (Guid)(await ActingTransaction.ScalarAsync(conn, tx,
                """
                insert into public.goals (group_id, created_by, title, description, kind, metric, target, starts_at, ends_at)
                values (@g, @actor, @title, @description, @kind, @metric, @target, @starts, @ends) returning id
                """, ct, ("g", groupId), ("actor", actor), ("title", title), ("description", description), ("kind", r.Kind),
                ("metric", r.Metric), ("target", r.Target), ("starts", r.StartsAt), ("ends", r.EndsAt)))!;
            await AuditAsync(conn, tx, actor, AuditActor.User, "goal.created", id, groupId, new { title, r.Kind, r.Metric, r.Target }, ct);
            return new CreatedGoal(id);
        }, RuleError, ct);
    }

    public Task<Result> CancelAsync(Guid actor, Guid id, bool staff, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            var g = await LoadAsync(conn, tx, id, ct);
            if (g is null) return NotFound;
            if (!staff && !await CanManageAsync(conn, tx, actor, g.GroupId, ct)) return Forbidden;
            if (g.Canceled) return Error.Conflict("goal.canceled", "Hedef zaten iptal edilmiş.");
            await ActingTransaction.ExecuteAsync(conn, tx, "update public.goals set canceled_at = now() where id = @id", ct, ("id", id));
            await AuditAsync(conn, tx, actor, staff ? AuditActor.Staff : AuditActor.User, staff ? "goal.canceled_by_admin" : "goal.canceled",
                id, g.GroupId, null, ct);
            return Result.Success();
        }, RuleError, ct);

    public async Task<Result<CreatedTeam>> CreateTeamAsync(Guid actor, Guid id, TeamRequest r, CancellationToken ct)
    {
        ArgumentNullException.ThrowIfNull(r);
        var name = r.Name?.Trim() ?? "";
        var members = (r.MemberIds ?? []).Distinct().ToArray();
        if (name.Length is < 2 or > 40) return Invalid("Takım adı 2–40 karakter olmalı.");
        if (members.Length is < 1 or > 200) return Invalid("Takıma en az bir üye seç.");

        return await ActingTransaction.RunAsync<CreatedTeam>(db, actor, async (conn, tx) =>
        {
            var g = await LoadAsync(conn, tx, id, ct);
            if (g is null) return NotFound;
            if (!await CanManageAsync(conn, tx, actor, g.GroupId, ct)) return Forbidden;
            if (g.Kind != "team") return Invalid("Takımlar yalnızca takım hedeflerinde kurulur.");
            if (g.Canceled || g.EndsAt <= time.GetUtcNow()) return Error.RuleViolation("goal.closed", "Bu hedef bitti ya da iptal edildi.");
            var free = (long)(await ActingTransaction.ScalarAsync(conn, tx,
                """
                select count(*) from public.group_members m
                where m.group_id = @group and m.user_id = any (@members)
                  and not exists (select 1 from public.goal_team_members t where t.goal_id = @g and t.user_id = m.user_id)
                """, ct, ("group", g.GroupId), ("members", members), ("g", id)))!;
            if (free != members.Length) return RuleError("goal_team_invalid");

            var team = (Guid)(await ActingTransaction.ScalarAsync(conn, tx,
                "insert into public.goal_teams (goal_id, name) values (@g, @name) returning id", ct, ("g", id), ("name", name)))!;
            foreach (var member in members)
            {
                await ActingTransaction.ExecuteAsync(conn, tx,
                    "insert into public.goal_team_members (goal_id, team_id, user_id) values (@g, @t, @u)", ct, ("g", id), ("t", team), ("u", member));
            }
            await AuditAsync(conn, tx, actor, AuditActor.User, "goal.team_created", id, g.GroupId, new { team, name, members = members.Length }, ct);
            return new CreatedTeam(team);
        }, RuleError, ct);
    }

    public Task<Result> DeleteTeamAsync(Guid actor, Guid id, Guid teamId, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            var g = await LoadAsync(conn, tx, id, ct);
            if (g is null) return NotFound;
            if (!await CanManageAsync(conn, tx, actor, g.GroupId, ct)) return Forbidden;
            await ActingTransaction.ExecuteAsync(conn, tx, "delete from public.goal_team_members where team_id = @t", ct, ("t", teamId));
            if (await ActingTransaction.ExecuteAsync(conn, tx, "delete from public.goal_teams where id = @t and goal_id = @g", ct,
                    ("t", teamId), ("g", id)) == 0)
                return Error.NotFound("goal.team_not_found", "Takım bulunamadı.");
            await AuditAsync(conn, tx, actor, AuditActor.User, "goal.team_deleted", id, g.GroupId, new { team = teamId }, ct);
            return Result.Success();
        }, RuleError, ct);

    /// <summary>Approving completes the task (trigger); rejecting lets the member claim again.</summary>
    public Task<Result> DecideClaimAsync(Guid actor, Guid id, Guid userId, bool approve, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            var g = await LoadAsync(conn, tx, id, ct);
            if (g is null) return NotFound;
            if (!await CanManageAsync(conn, tx, actor, g.GroupId, ct)) return Forbidden;
            if (await ActingTransaction.ExecuteAsync(conn, tx,
                    "update public.goal_claims set status = @s where goal_id = @g and user_id = @u and status = 'pending'", ct,
                    ("s", approve ? "approved" : "rejected"), ("g", id), ("u", userId)) == 0)
                return Error.NotFound("goal.claim_not_found", "Bekleyen bir bildirim bulunamadı.");
            await AuditAsync(conn, tx, actor, AuditActor.User, approve ? "goal.claim_approved" : "goal.claim_rejected", id, g.GroupId, new { userId }, ct);
            return Result.Success();
        }, RuleError, ct);
}
