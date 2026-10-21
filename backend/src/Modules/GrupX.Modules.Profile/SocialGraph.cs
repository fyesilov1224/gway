using System.Security.Claims;
using GrupX.SharedKernel;
using GrupX.SharedKernel.Database;
using GrupX.SharedKernel.Http;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;
using Npgsql;

namespace GrupX.Modules.Profile;

public sealed record FollowResponse(string Status)
{
    public const string Following = "following";
    public const string Requested = "requested";
}

public static class ProfileModule
{
    public static IServiceCollection AddProfileModule(this IServiceCollection services)
    {
        services.AddSingleton<SocialGraph>();
        services.AddSingleton<Teammates>();
        return services;
    }

    /// <summary>Follow, block and teammate writes (docs/ARCHITECTURE.md §3c); profiles themselves are written through Supabase.</summary>
    public static IEndpointRouteBuilder MapProfileEndpoints(this IEndpointRouteBuilder app)
    {
        var users = app.MapGroup("/users");

        users.MapPost("/{id:guid}/follow", async (Guid id, ClaimsPrincipal user, SocialGraph graph, CancellationToken ct) =>
            (await graph.FollowAsync(user.GetUserId(), id, ct)).ToHttpResult());

        users.MapDelete("/{id:guid}/follow", async (Guid id, ClaimsPrincipal user, SocialGraph graph, CancellationToken ct) =>
            (await graph.UnfollowAsync(user.GetUserId(), id, ct)).ToHttpResult());

        users.MapPost("/{id:guid}/block", async (Guid id, ClaimsPrincipal user, SocialGraph graph, CancellationToken ct) =>
            (await graph.BlockAsync(user.GetUserId(), id, ct)).ToHttpResult());

        users.MapDelete("/{id:guid}/block", async (Guid id, ClaimsPrincipal user, SocialGraph graph, CancellationToken ct) =>
            (await graph.UnblockAsync(user.GetUserId(), id, ct)).ToHttpResult());

        users.MapPost("/{id:guid}/teammate", async (Guid id, TeammateRequestBody? body, ClaimsPrincipal user, Teammates teammates, CancellationToken ct) =>
            (await teammates.RequestAsync(user.GetUserId(), id, body?.Message, ct)).ToHttpResult());

        users.MapDelete("/{id:guid}/teammate", async (Guid id, ClaimsPrincipal user, Teammates teammates, CancellationToken ct) =>
            (await teammates.RemoveAsync(user.GetUserId(), id, ct)).ToHttpResult());

        var me = app.MapGroup("/me");

        me.MapPost("/follow-requests/{userId:guid}/approval", async (Guid userId, ClaimsPrincipal user, SocialGraph graph, CancellationToken ct) =>
            (await graph.AcceptRequestAsync(user.GetUserId(), userId, ct)).ToHttpResult());

        me.MapDelete("/follow-requests/{userId:guid}", async (Guid userId, ClaimsPrincipal user, SocialGraph graph, CancellationToken ct) =>
            (await graph.RejectRequestAsync(user.GetUserId(), userId, ct)).ToHttpResult());

        me.MapDelete("/followers/{userId:guid}", async (Guid userId, ClaimsPrincipal user, SocialGraph graph, CancellationToken ct) =>
            (await graph.RemoveFollowerAsync(user.GetUserId(), userId, ct)).ToHttpResult());

        me.MapPost("/teammate-requests/{userId:guid}/approval", async (Guid userId, ClaimsPrincipal user, Teammates teammates, CancellationToken ct) =>
            (await teammates.AcceptAsync(user.GetUserId(), userId, ct)).ToHttpResult());

        me.MapDelete("/teammate-requests/{userId:guid}", async (Guid userId, ClaimsPrincipal user, Teammates teammates, CancellationToken ct) =>
            (await teammates.DeclineAsync(user.GetUserId(), userId, ct)).ToHttpResult());

        return app;
    }
}

/// <summary>Follows, follow requests and blocks (docs/ARCHITECTURE.md §3c, Takip). Triggers re-check every rule.</summary>
internal sealed class SocialGraph(NpgsqlDataSource db)
{
    private static readonly Error NotFound = Error.NotFound("profile.not_found", "Kullanıcı bulunamadı.");
    private static readonly Error Self = Error.Validation("profile.self", "Bu işlemi kendi hesabına uygulayamazsın.");
    private static readonly Error YouBlocked = Error.RuleViolation(
        "profile.you_blocked", "Engellediğin birini takip edemezsin. Önce engeli kaldır.");
    private static readonly Error Inactive = Error.RuleViolation("profile.account_inactive", "Hesabın aktif olmadığı için bu işlem yapılamaz.");
    private static readonly Error NoRequest = Error.NotFound("profile.no_request", "Bekleyen bir takip isteği bulunamadı.");

    private static Error RuleError(string code) => code switch
    {
        "follow_rate_limited" => Error.RuleViolation("profile.follow_rate_limited", "Bugün çok fazla kişiyi takip ettin. Yarın tekrar dene."),
        "blocked" => NotFound,
        _ => Error.RuleViolation($"profile.{code}", "Bu işlem şu anda yapılamıyor. Sayfayı yenileyip tekrar dene."),
    };

    private sealed record Target(bool IsPrivate, bool BlockedMe, bool IBlocked);

    /// <summary>The other account as the actor may see it; null when it does not exist, is hidden or blocked the actor.</summary>
    private static async Task<Target?> TargetAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid actor, Guid target, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand(
            """
            select is_private, private.has_blocked(id, @actor), private.has_blocked(@actor, id)
            from public.profiles where id = @target and private.is_account_active(id)
            """, conn, tx);
        cmd.Parameters.AddWithValue("actor", actor);
        cmd.Parameters.AddWithValue("target", target);
        await using var r = await cmd.ExecuteReaderAsync(ct);
        if (!await r.ReadAsync(ct)) return null;
        var t = new Target(r.GetBoolean(0), r.GetBoolean(1), r.GetBoolean(2));
        return t.BlockedMe ? null : t;
    }

    private static async Task<bool> IsActiveAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid user, CancellationToken ct) =>
        (bool)(await ActingTransaction.ScalarAsync(conn, tx,
            "select private.is_account_active(@id) and exists (select 1 from public.profiles where id = @id)", ct, ("id", user)))!;

    public Task<Result<FollowResponse>> FollowAsync(Guid actor, Guid target, CancellationToken ct) =>
        ActingTransaction.RunAsync<FollowResponse>(db, actor, async (conn, tx) =>
        {
            if (actor == target) return Self;
            if (!await IsActiveAsync(conn, tx, actor, ct)) return Inactive;
            var t = await TargetAsync(conn, tx, actor, target, ct);
            if (t is null) return NotFound;
            if (t.IBlocked) return YouBlocked;

            var follows = await ActingTransaction.ScalarAsync(conn, tx,
                "select 1 from public.follows where follower_id = @a and followee_id = @b", ct, ("a", actor), ("b", target));
            if (follows is not null) return new FollowResponse(FollowResponse.Following);

            if (!t.IsPrivate)
            {
                await ActingTransaction.ExecuteAsync(conn, tx,
                    "insert into public.follows (follower_id, followee_id) values (@a, @b)", ct, ("a", actor), ("b", target));
                return new FollowResponse(FollowResponse.Following);
            }

            await ActingTransaction.ExecuteAsync(conn, tx,
                "insert into public.follow_requests (requester_id, target_id) values (@a, @b) on conflict do nothing", ct,
                ("a", actor), ("b", target));
            return new FollowResponse(FollowResponse.Requested);
        }, RuleError, ct);

    /// <summary>Ends a follow or withdraws a request; nothing to undo is fine.</summary>
    public Task<Result> UnfollowAsync(Guid actor, Guid target, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            await ActingTransaction.ExecuteAsync(conn, tx,
                "delete from public.follows where follower_id = @a and followee_id = @b", ct, ("a", actor), ("b", target));
            await ActingTransaction.ExecuteAsync(conn, tx,
                "delete from public.follow_requests where requester_id = @a and target_id = @b", ct, ("a", actor), ("b", target));
            return Result.Success();
        }, RuleError, ct);

    public Task<Result> AcceptRequestAsync(Guid actor, Guid requester, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            var exists = await ActingTransaction.ScalarAsync(conn, tx,
                "select 1 from public.follow_requests where requester_id = @r and target_id = @t for update", ct,
                ("r", requester), ("t", actor));
            if (exists is null) return NoRequest;

            await ActingTransaction.ExecuteAsync(conn, tx,
                "insert into public.follows (follower_id, followee_id) values (@r, @t) on conflict do nothing", ct,
                ("r", requester), ("t", actor));
            await ActingTransaction.ExecuteAsync(conn, tx,
                "delete from public.follow_requests where requester_id = @r and target_id = @t", ct, ("r", requester), ("t", actor));
            return Result.Success();
        }, RuleError, ct);

    public Task<Result> RejectRequestAsync(Guid actor, Guid requester, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
            await ActingTransaction.ExecuteAsync(conn, tx,
                "delete from public.follow_requests where requester_id = @r and target_id = @t", ct, ("r", requester), ("t", actor)) > 0
                ? Result.Success()
                : NoRequest,
            RuleError, ct);

    public Task<Result> RemoveFollowerAsync(Guid actor, Guid follower, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
            await ActingTransaction.ExecuteAsync(conn, tx,
                "delete from public.follows where follower_id = @f and followee_id = @me", ct, ("f", follower), ("me", actor)) > 0
                ? Result.Success()
                : Error.NotFound("profile.not_follower", "Bu kişi seni takip etmiyor."),
            RuleError, ct);

    public Task<Result> BlockAsync(Guid actor, Guid target, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            if (actor == target) return Self;
            var exists = await ActingTransaction.ScalarAsync(conn, tx, "select 1 from public.profiles where id = @id", ct, ("id", target));
            if (exists is null) return NotFound;
            await ActingTransaction.ExecuteAsync(conn, tx,
                "insert into public.blocks (blocker_id, blocked_id) values (@a, @b) on conflict do nothing", ct, ("a", actor), ("b", target));
            return Result.Success();
        }, RuleError, ct);

    public Task<Result> UnblockAsync(Guid actor, Guid target, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            await ActingTransaction.ExecuteAsync(conn, tx,
                "delete from public.blocks where blocker_id = @a and blocked_id = @b", ct, ("a", actor), ("b", target));
            return Result.Success();
        }, RuleError, ct);
}
