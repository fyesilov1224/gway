using System.Text.Json;
using Npgsql;
using NpgsqlTypes;

namespace Gway.SharedKernel.Auditing;

public static class AuditActor
{
    public const string User = "user";
    public const string Staff = "staff";
    public const string System = "system";
}

/// <summary>One immutable row in <c>public.audit_log</c>. <see cref="Action"/> is a dotted code, e.g. <c>user.suspended</c>.</summary>
public sealed record AuditEntry(
    Guid? ActorId,
    string ActorKind,
    string Action,
    string TargetType,
    string? TargetId,
    object? Data = null,
    Guid? GroupId = null);

public static class AuditLog
{
    /// <summary>Appends an entry inside the caller's transaction, so the change and its audit record commit together.</summary>
    public static async Task AppendAsync(NpgsqlConnection connection, NpgsqlTransaction transaction, AuditEntry entry, CancellationToken ct)
    {
        ArgumentNullException.ThrowIfNull(entry);

        await using var cmd = new NpgsqlCommand(
            """
            insert into public.audit_log (actor_id, actor_kind, action, target_type, target_id, group_id, data)
            values (@actor_id, @actor_kind, @action, @target_type, @target_id, @group_id, @data)
            """,
            connection,
            transaction);

        cmd.Parameters.AddWithValue("actor_id", (object?)entry.ActorId ?? DBNull.Value);
        cmd.Parameters.AddWithValue("actor_kind", entry.ActorKind);
        cmd.Parameters.AddWithValue("action", entry.Action);
        cmd.Parameters.AddWithValue("target_type", entry.TargetType);
        cmd.Parameters.AddWithValue("target_id", (object?)entry.TargetId ?? DBNull.Value);
        cmd.Parameters.AddWithValue("group_id", (object?)entry.GroupId ?? DBNull.Value);
        cmd.Parameters.Add(new NpgsqlParameter("data", NpgsqlDbType.Jsonb)
        {
            Value = JsonSerializer.Serialize(entry.Data ?? new { }, JsonSerializerOptions.Web),
        });

        await cmd.ExecuteNonQueryAsync(ct);
    }
}
