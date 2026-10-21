using System.Security.Claims;

namespace GrupX.SharedKernel.Http;

public static class ClaimsPrincipalExtensions
{
    /// <summary>The Supabase user id (<c>sub</c>). Only call on endpoints that require authentication.</summary>
    public static Guid GetUserId(this ClaimsPrincipal user) =>
        Guid.TryParse(user.FindFirstValue("sub"), out var id)
            ? id
            : throw new InvalidOperationException("Authenticated user has no valid 'sub' claim.");
}
