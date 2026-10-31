using System.ComponentModel.DataAnnotations;

namespace Gway.SharedKernel.Supabase;

public sealed class SupabaseOptions
{
    public const string SectionName = "Supabase";

    /// <summary>Project URL, e.g. <c>https://abc.supabase.co</c> or <c>http://127.0.0.1:54321</c>.</summary>
    [Required]
    [Url]
    public string Url { get; init; } = "";

    /// <summary>
    /// Legacy HS256 JWT secret. When empty, signing keys are read from the
    /// issuer's JWKS endpoint (asymmetric keys). Never commit this value.
    /// </summary>
    public string? JwtSecret { get; init; }

    /// <summary>Service role key for Storage admin calls. Never commit this value.</summary>
    [Required]
    public string ServiceRoleKey { get; init; } = "";

    public string Issuer => $"{Url.TrimEnd('/')}/auth/v1";
}
