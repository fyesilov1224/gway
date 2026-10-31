using Microsoft.AspNetCore.Authorization;
using Microsoft.Extensions.Caching.Memory;
using Npgsql;

namespace Gway.Api.Auth;

/// <summary>
/// The account must be active. A suspended account's new tokens already carry role <c>unverified</c>, but a token issued
/// before the suspension stays valid for up to an hour (docs/ARCHITECTURE.md §3a, Hesap yaşam döngüsü).
/// </summary>
internal sealed class ActiveAccountRequirement : IAuthorizationRequirement;

internal sealed class ActiveAccountHandler(NpgsqlDataSource db, IMemoryCache cache) : AuthorizationHandler<ActiveAccountRequirement>
{
    /// <summary>A suspension or its lifting reaches the API within this time.</summary>
    private static readonly TimeSpan CacheFor = TimeSpan.FromSeconds(15);

    protected override async Task HandleRequirementAsync(AuthorizationHandlerContext context, ActiveAccountRequirement requirement)
    {
        if (!Guid.TryParse(context.User.FindFirst("sub")?.Value, out var userId)) return;
        var active = await cache.GetOrCreateAsync((nameof(ActiveAccountHandler), userId), async entry =>
        {
            entry.AbsoluteExpirationRelativeToNow = CacheFor;
            await using var cmd = db.CreateCommand("select private.is_account_active(@id)");
            cmd.Parameters.AddWithValue("id", userId);
            return await cmd.ExecuteScalarAsync() is true;
        });
        if (active) context.Succeed(requirement);
    }
}
