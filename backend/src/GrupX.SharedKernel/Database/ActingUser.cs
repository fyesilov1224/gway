using System.Text.Json;
using Npgsql;

namespace GrupX.SharedKernel.Database;

/// <summary>
/// Tells database triggers who performs a change. The backend connection bypasses RLS,
/// so triggers re-check the rules through <c>auth.uid()</c> (docs/ARCHITECTURE.md §3b).
/// </summary>
public static class ActingUser
{
    /// <summary>Sets <c>request.jwt.claims</c> for the rest of <paramref name="transaction"/> only.</summary>
    public static async Task SetAsync(NpgsqlConnection connection, NpgsqlTransaction transaction, Guid userId, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand("select set_config('request.jwt.claims', @claims, true)", connection, transaction);
        cmd.Parameters.AddWithValue("claims", JsonSerializer.Serialize(new { sub = userId }));
        await cmd.ExecuteNonQueryAsync(ct);
    }
}
