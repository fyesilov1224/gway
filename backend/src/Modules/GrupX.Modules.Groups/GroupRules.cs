using System.Text.RegularExpressions;
using GrupX.SharedKernel;

namespace GrupX.Modules.Groups;

public sealed record GroupLink(string Label, string Url);

internal static class JoinPolicies
{
    public const string Open = "open";
    public const string Request = "request";
    public const string Invite = "invite";

    public static readonly string[] All = [Open, Request, Invite];
}

/// <summary>Group roles; the slugs and ranks mirror <c>public.group_roles</c>.</summary>
internal static class GroupRoles
{
    public const string Owner = "owner";
    public const string Admin = "admin";
    public const string Discipline = "discipline";
    public const string Moderator = "moderator";
    public const string Member = "member";

    /// <summary>Roles stored in <c>group_member_roles</c>; owner and member are structural.</summary>
    public static readonly string[] Assignable = [Admin, Discipline, Moderator];
}

/// <summary>Permission slugs of <c>public.group_permissions</c> used by this module.</summary>
internal static class GroupPermissions
{
    public const string Edit = "group.edit";
    public const string Delete = "group.delete";
    public const string Transfer = "group.transfer";
    public const string AssignRoles = "roles.assign";
    public const string ApproveMembers = "members.approve";
    public const string InviteMembers = "members.invite";
}

/// <summary>Input rules of docs/ARCHITECTURE.md §3b. The database enforces the same limits.</summary>
internal static partial class GroupRules
{
    public const int MaxAbout = 1000;
    public const int MaxRules = 2000;
    public const int MaxLinks = 5;
    public const int MaxLinkLabel = 40;
    public const int MaxLinkUrl = 300;
    public const int MaxReason = 500;

    public static readonly string[] CaseThresholds = ["majority", "two_thirds", "unanimous"];

    [GeneratedRegex(@"^[a-z0-9_.]{3,30}$")]
    private static partial Regex HandleFormat();

    public static Error? ValidateHandle(string? handle) =>
        handle is null || !HandleFormat().IsMatch(handle) || handle.StartsWith('.') || handle.EndsWith('.') || handle.Contains("..", StringComparison.Ordinal)
            ? Error.Validation("group.invalid_handle",
                "Grup adresi 3-30 karakter olmalı; küçük harf, rakam, alt çizgi ve nokta içerebilir, nokta ile başlayıp bitemez.")
            : null;

    public static Error? ValidateName(string? name) =>
        name is null || name.Trim().Length is < 3 or > 60
            ? Error.Validation("group.invalid_name", "Grup adı 3-60 karakter olmalı.")
            : null;

    public static Error? ValidateJoinPolicy(string? policy) =>
        policy is null || !JoinPolicies.All.Contains(policy)
            ? Error.Validation("group.invalid_join_policy", "Geçerli bir katılım tipi seç.")
            : null;

    /// <summary>Plate number of one of Turkey's 81 provinces (docs/ARCHITECTURE.md §3d, Harita ile keşif).</summary>
    public static Error? ValidateProvince(int province) =>
        province is < 1 or > 81 ? Error.Validation("group.invalid_province", "Geçerli bir il seç.") : null;

    public static Error? ValidateAbout(string? about) =>
        about is not null && about.Trim().Length > MaxAbout
            ? Error.Validation("group.invalid_about", $"Tanıtım en fazla {MaxAbout} karakter olabilir.")
            : null;

    public static Error? ValidateRules(string? rules) =>
        rules is not null && rules.Trim().Length > MaxRules
            ? Error.Validation("group.invalid_rules", $"Kurallar en fazla {MaxRules} karakter olabilir.")
            : null;

    public static Error? ValidateLinks(IReadOnlyList<GroupLink>? links)
    {
        if (links is null) return null;
        var invalid = Error.Validation("group.invalid_links",
            $"En fazla {MaxLinks} bağlantı ekleyebilirsin. Her bağlantının bir etiketi ve http(s) ile başlayan bir adresi olmalı.");
        if (links.Count > MaxLinks) return invalid;
        foreach (var link in links)
        {
            var label = link?.Label?.Trim() ?? "";
            var url = link?.Url?.Trim() ?? "";
            if (label.Length is 0 or > MaxLinkLabel || url.Length > MaxLinkUrl) return invalid;
            if (!Uri.TryCreate(url, UriKind.Absolute, out var uri) || (uri.Scheme != Uri.UriSchemeHttps && uri.Scheme != Uri.UriSchemeHttp))
                return invalid;
        }
        return null;
    }

    /// <summary>Empty string clears the image; otherwise the path must sit in the group's storage folder.</summary>
    public static Error? ValidateImagePath(Guid groupId, string? path) =>
        path is null || path.Length == 0 || (path.StartsWith($"{groupId}/", StringComparison.Ordinal) && !path.Contains("..", StringComparison.Ordinal))
            ? null
            : Error.Validation("group.invalid_image_path", "Görsel yüklenemedi. Lütfen tekrar dene.");

    public static List<GroupLink> Normalize(IReadOnlyList<GroupLink> links) =>
        [.. links.Select(l => new GroupLink(l.Label.Trim(), l.Url.Trim()))];
}
