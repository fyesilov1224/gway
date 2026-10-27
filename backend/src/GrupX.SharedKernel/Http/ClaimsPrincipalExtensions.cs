using System.Security.Claims;

namespace GrupX.SharedKernel.Http;

public static class ClaimsPrincipalExtensions
{
    /// <summary>The Supabase user id (<c>sub</c>). Only call on endpoints that require authentication.</summary>
    public static Guid GetUserId(this ClaimsPrincipal user) =>
        Guid.TryParse(user.FindFirstValue("sub"), out var id)
            ? id
            : throw new InvalidOperationException("Authenticated user has no valid 'sub' claim.");

    /// <summary>The Supabase Auth session (<c>session_id</c>); null for tokens without one.</summary>
    public static Guid? GetSessionId(this ClaimsPrincipal user) =>
        Guid.TryParse(user.FindFirstValue("session_id"), out var id) ? id : null;
}
