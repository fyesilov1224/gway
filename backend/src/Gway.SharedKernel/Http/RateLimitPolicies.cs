namespace Gway.SharedKernel.Http;

/// <summary>Named rate limit policies registered by the API, on top of the global limit.</summary>
public static class RateLimitPolicies
{
    /// <summary>Few calls per user, e.g. starting a checkout.</summary>
    public const string Sensitive = "sensitive";
}
