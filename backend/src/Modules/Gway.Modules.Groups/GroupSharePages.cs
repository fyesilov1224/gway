using Gway.SharedKernel.Http;
using Gway.SharedKernel.Localization;
using Gway.SharedKernel.Supabase;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Options;
using Npgsql;

namespace Gway.Modules.Groups;

/// <summary>Share pages of groups and invite links (docs/ARCHITECTURE.md §3b, Paylaşım sayfaları).</summary>
internal sealed class GroupSharePages(NpgsqlDataSource db, IConfiguration configuration, IOptions<SupabaseOptions> supabase)
{
    private string? AppUrl => configuration["Share:AppUrl"];

    public async Task<IResult> GroupAsync(string handle, CancellationToken ct)
    {
        var group = await ActiveGroupAsync("g.handle = @key", handle.Trim().ToLowerInvariant(), ct);
        return group is null
            ? SharePage.Fallback(AppUrl)
            : SharePage.Render(AppUrl, $"/g/{group.Handle}", _ => group.Name, language => Describe(group, language), Image(group));
    }

    public async Task<IResult> InviteAsync(string code, CancellationToken ct)
    {
        code = code.Trim().ToLowerInvariant();
        var group = await ActiveGroupAsync(
            "g.id = (select l.group_id from public.group_invite_links l where l.code = @key)", code, ct);
        return group is null
            ? SharePage.Fallback(AppUrl)
            : SharePage.Render(AppUrl, $"/i/{Uri.EscapeDataString(code)}", language => ServerText.Format(language, "{0} grubuna davetlisin", group.Name),
                language => Describe(group, language), Image(group));
    }

    private sealed record SharedGroup(string Handle, string Name, string About, int MemberCount, string? LogoPath, string? CoverPath);

    private async Task<SharedGroup?> ActiveGroupAsync(string where, string key, CancellationToken ct)
    {
#pragma warning disable CA2100 // where is one of this class's constants
        await using var cmd = db.CreateCommand(
            $"select g.handle, g.name, g.about, g.member_count, g.logo_path, g.cover_path from public.groups g where {where} and g.status = 'active'");
#pragma warning restore CA2100
        cmd.Parameters.AddWithValue("key", key);
        await using var r = await cmd.ExecuteReaderAsync(ct);
        return await r.ReadAsync(ct)
            ? new SharedGroup(r.GetString(0), r.GetString(1), r.GetString(2), r.GetInt32(3),
                r.IsDBNull(4) ? null : r.GetString(4), r.IsDBNull(5) ? null : r.GetString(5))
            : null;
    }

    private static string Describe(SharedGroup g, string language) =>
        string.IsNullOrWhiteSpace(g.About)
            ? ServerText.Format(language, "{0} üye · GWAY'de katıl.", g.MemberCount)
            : ServerText.Format(language, "{0} üye · {1}", g.MemberCount, g.About.Trim());

    private string? Image(SharedGroup g) =>
        SharePage.PublicImage(supabase.Value.Url, GroupService.ImageBucket, g.CoverPath ?? g.LogoPath);
}
