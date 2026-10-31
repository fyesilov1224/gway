using Npgsql;

namespace Gway.SharedKernel.Database;

/// <summary>
/// A transaction that names the acting user to the database triggers (<see cref="ActingUser"/>) and commits only on
/// success. A trigger rejection (P0001, the rule's code as message) becomes the error <paramref name="ruleError"/> maps it
/// to: a rule the C# checks could not see, usually a race.
/// </summary>
public static class ActingTransaction
{
    public static async Task<Result<T>> RunAsync<T>(
        NpgsqlDataSource db,
        Guid actorId,
        Func<NpgsqlConnection, NpgsqlTransaction, Task<Result<T>>> work,
        Func<string, Error> ruleError,
        CancellationToken ct)
    {
        ArgumentNullException.ThrowIfNull(db);
        ArgumentNullException.ThrowIfNull(work);
        ArgumentNullException.ThrowIfNull(ruleError);

        await using var conn = await db.OpenConnectionAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);
        await ActingUser.SetAsync(conn, tx, actorId, ct);
        try
        {
            var result = await work(conn, tx);
            if (result.IsSuccess) await tx.CommitAsync(ct);
            return result;
        }
        catch (PostgresException ex) when (ex.SqlState == PostgresErrorCodes.RaiseException)
        {
            return ruleError(ex.MessageText);
        }
    }

    /// <summary><see cref="RunAsync{T}"/> for work without a result value.</summary>
    public static async Task<Result> RunAsync(
        NpgsqlDataSource db,
        Guid actorId,
        Func<NpgsqlConnection, NpgsqlTransaction, Task<Result>> work,
        Func<string, Error> ruleError,
        CancellationToken ct)
    {
        ArgumentNullException.ThrowIfNull(work);
        var result = await RunAsync<bool>(db, actorId, async (conn, tx) =>
        {
            var inner = await work(conn, tx);
            return inner.IsSuccess ? true : inner.Error;
        }, ruleError, ct);
        return result.IsSuccess ? Result.Success() : result.Error;
    }

    /// <summary>Runs a scalar query in the transaction.</summary>
    public static async Task<object?> ScalarAsync(
        NpgsqlConnection conn, NpgsqlTransaction tx, string sql, CancellationToken ct, params (string Name, object? Value)[] parameters)
    {
#pragma warning disable CA2100 // callers pass compile-time constant SQL
        await using var cmd = new NpgsqlCommand(sql, conn, tx);
#pragma warning restore CA2100
        foreach (var (name, value) in parameters) cmd.Parameters.AddWithValue(name, value ?? DBNull.Value);
        var scalar = await cmd.ExecuteScalarAsync(ct);
        return scalar is DBNull ? null : scalar;
    }

    /// <summary>Runs a statement in the transaction; returns the affected rows.</summary>
    public static async Task<int> ExecuteAsync(
        NpgsqlConnection conn, NpgsqlTransaction tx, string sql, CancellationToken ct, params (string Name, object? Value)[] parameters)
    {
#pragma warning disable CA2100 // callers pass compile-time constant SQL
        await using var cmd = new NpgsqlCommand(sql, conn, tx);
#pragma warning restore CA2100
        foreach (var (name, value) in parameters) cmd.Parameters.AddWithValue(name, value ?? DBNull.Value);
        return await cmd.ExecuteNonQueryAsync(ct);
    }
}
