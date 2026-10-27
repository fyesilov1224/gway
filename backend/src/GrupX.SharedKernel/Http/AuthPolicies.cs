namespace GrupX.SharedKernel.Http;

/// <summary>Authorization policies registered by the API (docs/ARCHITECTURE.md §3h).</summary>
public static class AuthPolicies
{
    /// <summary>
    /// Any signed-in session, including one the token hook marked <c>unverified</c>. Only the security steps and
    /// the account state use it; everything else requires a verified (<c>authenticated</c>) session.
    /// </summary>
    public const string AllowUnverified = "allow-unverified";

    public const string VerifiedRole = "authenticated";
    public const string UnverifiedRole = "unverified";
}
