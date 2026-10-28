using System.Globalization;
using System.Text.Json;
using Npgsql;

namespace GrupX.Modules.Admin;

/// <summary>One league of a month: its size and its leader.</summary>
public sealed record AdminLeague(
    string Category, string CategoryName, int Province, int Groups, Guid LeaderId, string LeaderName, int LeaderPoints, int Excluded);

public sealed record AdminLeagueMonth(DateOnly Month, bool Finalized, IReadOnlyList<AdminLeague> Leagues);

public sealed record AdminLeagueExclusion(Guid GroupId, string GroupName, string GroupHandle, string Reason, DateTimeOffset CreatedAt, string? By);

/// <summary>A league's table as the app shows it (<c>private.league_table</c>), with the groups taken out of it.</summary>
public sealed record AdminLeagueTable(JsonElement Table, IReadOnlyList<AdminLeagueExclusion> Exclusions);

public sealed record AdminLeagueExclusionRequest(string Reason);

/// <summary>Read side of the league page (docs/ARCHITECTURE.md §3d, Gruplar Ligi).</summary>
internal sealed class AdminLeagues(NpgsqlDataSource db)
{
    private static readonly TimeZoneInfo Turkey = TimeZoneInfo.FindSystemTimeZoneById("Europe/Istanbul");

    /// <summary><c>2026-10</c> to its first day; null for a malformed value, the current Turkish month when empty.</summary>
    public static DateOnly? ParseMonth(string? month, DateTimeOffset now)
    {
        if (string.IsNullOrWhiteSpace(month))
        {
            var local = TimeZoneInfo.ConvertTime(now, Turkey);
            return new DateOnly(local.Year, local.Month, 1);
        }
        return DateOnly.TryParseExact(month + "-01", "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out var d) ? d : null;
    }

    public async Task<AdminLeagueMonth> LeaguesAsync(DateOnly month, CancellationToken ct)
    {
        await using var conn = await db.OpenConnectionAsync(ct);
        await using var cmd = new NpgsqlCommand(
            """
            with closed as (
              select exists (select 1 from public.league_seasons where month = @m) as yes
            ), standings as (
              select r.category_slug, r.province, r.group_id, r.points, r.rank
              from public.league_results r where (select yes from closed) and r.month = @m
              union all
              select s.category_slug, s.province, s.group_id, s.points,
                     rank() over (partition by s.category_slug, s.province order by s.points desc, s.member_count, s.name)::int
              from private.league_scores(@m) s where not (select yes from closed)
            )
            select (select yes from closed), s.category_slug, c.name, s.province::int, count(*)::int,
                   (array_agg(s.group_id order by s.rank, g.name))[1], (array_agg(g.name order by s.rank, g.name))[1],
                   max(s.points)::int,
                   (select count(*)::int from public.league_exclusions x join public.groups xg on xg.id = x.group_id
                    where x.month = @m and xg.category_slug = s.category_slug and xg.province = s.province)
            from standings s
            join public.groups g on g.id = s.group_id
            join public.categories c on c.slug = s.category_slug
            group by s.category_slug, c.name, c.sort_order, s.province
            order by count(*) desc, c.sort_order, s.province
            """, conn);
        cmd.Parameters.AddWithValue("m", month);
        var leagues = new List<AdminLeague>();
        var finalized = false;
        await using (var r = await cmd.ExecuteReaderAsync(ct))
        {
            while (await r.ReadAsync(ct))
            {
                finalized = r.GetBoolean(0);
                leagues.Add(new AdminLeague(r.GetString(1), r.GetString(2), r.GetInt32(3), r.GetInt32(4), r.GetGuid(5), r.GetString(6),
                    r.GetInt32(7), r.GetInt32(8)));
            }
        }
        if (leagues.Count == 0)
        {
            await using var closed = new NpgsqlCommand("select exists (select 1 from public.league_seasons where month = @m)", conn);
            closed.Parameters.AddWithValue("m", month);
            finalized = (bool)(await closed.ExecuteScalarAsync(ct))!;
        }
        return new AdminLeagueMonth(month, finalized, leagues);
    }

    public async Task<AdminLeagueTable> TableAsync(DateOnly month, string category, short province, CancellationToken ct)
    {
        await using var conn = await db.OpenConnectionAsync(ct);
        JsonElement table;
        await using (var cmd = new NpgsqlCommand("select private.league_table(@c, @p, @m)::text", conn))
        {
            cmd.Parameters.AddWithValue("c", category);
            cmd.Parameters.AddWithValue("p", province);
            cmd.Parameters.AddWithValue("m", month);
            using var doc = JsonDocument.Parse((string)(await cmd.ExecuteScalarAsync(ct))!);
            table = doc.RootElement.Clone();
        }

        var exclusions = new List<AdminLeagueExclusion>();
        await using (var cmd = new NpgsqlCommand(
            """
            select g.id, g.name, g.handle, x.reason, x.created_at, p.username
            from public.league_exclusions x
            join public.groups g on g.id = x.group_id
            left join public.profiles p on p.id = x.excluded_by
            where x.month = @m and g.category_slug = @c and g.province = @p
            order by x.created_at desc
            """, conn))
        {
            cmd.Parameters.AddWithValue("m", month);
            cmd.Parameters.AddWithValue("c", category);
            cmd.Parameters.AddWithValue("p", province);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            while (await r.ReadAsync(ct))
            {
                exclusions.Add(new AdminLeagueExclusion(r.GetGuid(0), r.GetString(1), r.GetString(2), r.GetString(3),
                    r.GetFieldValue<DateTimeOffset>(4), r.IsDBNull(5) ? null : r.GetString(5)));
            }
        }
        return new AdminLeagueTable(table, exclusions);
    }
}
