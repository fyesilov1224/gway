using GrupX.SharedKernel;

namespace GrupX.Modules.Identity.Contracts;

public sealed record SecuritySettingsView(bool Enforce, bool SmsConfigured, bool LookupEnabled, DateTimeOffset UpdatedAt);

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
    string? AllowedCountry,
    DateTimeOffset? LocationCheckedAt,
    DateTimeOffset? ExemptUntil,
    IReadOnlyList<LocationCheckView> Checks);

public sealed record ReviewApprovalRequest(int? ExemptDays, string? Note);

public sealed record ReviewBanRequest(string? Note);

public sealed record SecuritySettingsRequest(bool Enforce);

/// <summary>Security verification for the admin panel (docs/ARCHITECTURE.md §3h). Callers check staff roles first.</summary>
public interface ISecurityAdministration
{
    Task<SecuritySettingsView> GetSettingsAsync(CancellationToken ct);

    Task<Result<SecuritySettingsView>> SetEnforceAsync(Guid actorId, bool enforce, CancellationToken ct);

    /// <param name="status"><c>open</c>, <c>approved</c>, <c>banned</c>, or null for all.</param>
    Task<Result<IReadOnlyList<SecurityReviewItem>>> ListReviewsAsync(string? status, int page, CancellationToken ct);

    Task<Result> ApproveAsync(Guid actorId, Guid reviewId, ReviewApprovalRequest body, CancellationToken ct);

    Task<Result> BanAsync(Guid actorId, Guid reviewId, ReviewBanRequest body, CancellationToken ct);

    Task<Result<UserSecurityView>> GetUserAsync(Guid userId, CancellationToken ct);
}
