using GrupX.SharedKernel;
using Npgsql;

namespace GrupX.Modules.Billing;

internal sealed record BillingGroup(Guid Id, string Handle, string Name);

internal sealed record PlanRow(string Slug, string Name, int Tier, bool IsActive);

/// <summary>SQL shared by checkout, settlement and administration. Reads the groups tables, never writes them.</summary>
internal static class BillingStore
{
    /// <summary>The active group, if <paramref name="actorId"/> holds <c>billing.manage</c> in it (owner, active account).</summary>
    public static async Task<Result<BillingGroup>> AuthorizeAsync(
        NpgsqlConnection conn, NpgsqlTransaction tx, Guid groupId, Guid actorId, bool lockGroup, CancellationToken ct)
    {
#pragma warning disable CA2100 // constant SQL with an optional constant suffix
        await using var cmd = new NpgsqlCommand(
            "select handle, name, status, private.user_has_group_permission(@actor, id, 'billing.manage') from public.groups where id = @id"
            + (lockGroup ? " for update" : ""), conn, tx);
#pragma warning restore CA2100
        cmd.Parameters.AddWithValue("id", groupId);
        cmd.Parameters.AddWithValue("actor", actorId);
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        if (!await reader.ReadAsync(ct)) return BillingErrors.GroupNotFound;
        if (reader.GetString(2) != "active") return BillingErrors.GroupSuspended;
        if (!reader.GetBoolean(3)) return BillingErrors.Forbidden;
        return new BillingGroup(groupId, reader.GetString(0), reader.GetString(1));
    }

    public static async Task<List<PlanRow>> PlansAsync(NpgsqlConnection conn, NpgsqlTransaction tx, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand("select slug, name, tier, is_active from public.plans order by tier", conn, tx);
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        var plans = new List<PlanRow>();
        while (await reader.ReadAsync(ct)) plans.Add(new PlanRow(reader.GetString(0), reader.GetString(1), reader.GetInt32(2), reader.GetBoolean(3)));
        return plans;
    }

    /// <summary>List prices in one currency, keyed by (plan, period).</summary>
    public static async Task<Dictionary<(string Plan, string Period), int>> PricesAsync(
        NpgsqlConnection conn, NpgsqlTransaction tx, string currency, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand(
            "select plan_slug, period, amount_minor from public.plan_prices where currency = @currency", conn, tx);
        cmd.Parameters.AddWithValue("currency", currency);
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        var prices = new Dictionary<(string, string), int>();
        while (await reader.ReadAsync(ct)) prices[(reader.GetString(0), reader.GetString(1))] = reader.GetInt32(2);
        return prices;
    }

    /// <summary>Slices that end after <paramref name="now"/>, in timeline order.</summary>
    public static async Task<List<Slice>> LiveSlicesAsync(
        NpgsqlConnection conn, NpgsqlTransaction tx, Guid groupId, DateTimeOffset now, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand(
            """
            select s.id, s.plan_slug, p.tier, s.period, s.starts_at, s.ends_at
            from public.group_subscriptions s
            join public.plans p on p.slug = s.plan_slug
            where s.group_id = @group and s.ends_at > @now and s.ends_at > s.starts_at
            order by s.starts_at
            """, conn, tx);
        cmd.Parameters.AddWithValue("group", groupId);
        cmd.Parameters.AddWithValue("now", now);
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        var slices = new List<Slice>();
        while (await reader.ReadAsync(ct))
        {
            slices.Add(new Slice(reader.GetGuid(0), reader.GetString(1), reader.GetInt32(2), reader.GetString(3),
                reader.GetFieldValue<DateTimeOffset>(4), reader.GetFieldValue<DateTimeOffset>(5)));
        }
        return slices;
    }

    public static async Task<int?> SalesTermsVersionAsync(NpgsqlConnection conn, NpgsqlTransaction tx, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand(
            "select max(version) from public.legal_documents where kind = 'distance_sales' and published_at <= now()", conn, tx);
        return await cmd.ExecuteScalarAsync(ct) as int?;
    }

    /// <summary>
    /// Runs <paramref name="work"/> in a transaction; commits on success. A trigger rejection becomes
    /// a rule violation (a race the C# checks could not see).
    /// </summary>
    public static async Task<Result<T>> RunAsync<T>(
        NpgsqlDataSource db, Func<NpgsqlConnection, NpgsqlTransaction, Task<Result<T>>> work, CancellationToken ct)
    {
        await using var conn = await db.OpenConnectionAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);
        try
        {
            var result = await work(conn, tx);
            if (result.IsSuccess) await tx.CommitAsync(ct);
            return result;
        }
        catch (PostgresException ex) when (ex.SqlState == PostgresErrorCodes.RaiseException)
        {
            return Error.RuleViolation($"billing.{ex.MessageText}", "Bu işlem paket kurallarına uygun değil. Sayfayı yenileyip tekrar dene.");
        }
    }
}
