using GrupX.SharedKernel;

namespace GrupX.Modules.Identity.Contracts;

public sealed record SecuritySettingsView(
    bool Enforce,
    bool DetectVpn,
    bool WarnInstalledVpn,
    bool DetectPhoneMismatch,
    bool SmsConfigured,
    bool LookupEnabled,
    DateTimeOffset UpdatedAt);

/// <summary>One location check as staff see it: derived countries and flags, never coordinates.</summary>
public sealed record LocationCheckView(
    DateTimeOffset CheckedAt,
    string Platform,
    string? GpsCountry,
    string? IpCountry,
    string? SimCountry,
    string? PhoneCountry,
    bool IsMocked,
    bool Vpn,
    IReadOnlyList<string> VpnApps,
    IReadOnlyList<string> Signals,
    string Verdict);

public sealed record SecurityReviewItem(
    Guid Id,
    Guid UserId,
    string? Username,
    string? DisplayName,
    IReadOnlyList<string> Signals,
    string Status,
    DateTimeOffset OpenedAt,
    DateTimeOffset? ResolvedAt,
    string? Note,
    LocationCheckView? Check);

public sealed record UserSecurityView(
    string State,
    string? PhoneMasked,
    string? PhoneCountry,
    DateTimeOffset? PhoneVerifiedAt,
    bool TotpEnabled,
    int PasskeyCount,
    string? AllowedCountry,
    DateTimeOffset? LocationCheckedAt,
    DateTimeOffset? ExemptUntil,
    bool ReviewExempt,
    IReadOnlyList<LocationCheckView> Checks);

public sealed record ReviewApprovalRequest(int? ExemptDays, string? Note);

public sealed record ReviewBanRequest(string? Note);

/// <summary>Only the switches that are sent change.</summary>
public sealed record ReviewExemptRequest(bool Exempt, string? Note);

public sealed record SecuritySettingsRequest(bool? Enforce, bool? DetectVpn, bool? WarnInstalledVpn, bool? DetectPhoneMismatch);

/// <summary>Security verification for the admin panel (docs/ARCHITECTURE.md §3h). Callers check staff roles first.</summary>
public interface ISecurityAdministration
{
    Task<SecuritySettingsView> GetSettingsAsync(CancellationToken ct);

    Task<Result<SecuritySettingsView>> UpdateSettingsAsync(Guid actorId, SecuritySettingsRequest body, CancellationToken ct);

    /// <param name="status"><c>open</c>, <c>approved</c>, <c>banned</c>, or null for all.</param>
    Task<Result<IReadOnlyList<SecurityReviewItem>>> ListReviewsAsync(string? status, int page, CancellationToken ct);

    Task<Result> ApproveAsync(Guid actorId, Guid reviewId, ReviewApprovalRequest body, CancellationToken ct);

    Task<Result> BanAsync(Guid actorId, Guid reviewId, ReviewBanRequest body, CancellationToken ct);

    Task<Result<UserSecurityView>> GetUserAsync(Guid userId, CancellationToken ct);

    /// <summary>Store review account: skips security verification (§3h). Admin only; the caller checks the role.</summary>
    Task<Result> SetReviewExemptAsync(Guid actorId, Guid userId, ReviewExemptRequest body, CancellationToken ct);
}
