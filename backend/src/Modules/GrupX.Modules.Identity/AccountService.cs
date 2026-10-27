using GrupX.Modules.Identity.Contracts;
using GrupX.SharedKernel;
using GrupX.SharedKernel.Auditing;
using Npgsql;

namespace GrupX.Modules.Identity;

internal sealed class AccountService(NpgsqlDataSource db) : IAccountAdministration
{
    public const int DeletionGraceDays = 30;
    public const int MaxReasonLength = 500;

    private static readonly Error NotFound = Error.NotFound("account.not_found", "Hesap bulunamadı.");

    public async Task<Result<AccountState>> GetAsync(Guid userId, CancellationToken ct)
    {
        await using var conn = await db.OpenConnectionAsync(ct);
        await using var cmd = new NpgsqlCommand(
            "select status, suspended_until, suspension_reason, deletion_scheduled_for from public.account_status where user_id = @id",
            conn);
        cmd.Parameters.AddWithValue("id", userId);
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        return await reader.ReadAsync(ct) ? ReadState(reader) : NotFound;
    }

    public async Task<Result<AccountState>> RequestDeletionAsync(Guid userId, CancellationToken ct)
    {
        await using var conn = await db.OpenConnectionAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);

        var current = await LockAsync(conn, tx, userId, ct);
        if (current is null) return NotFound;
        if (current.Status == AccountStatuses.PendingDeletion)
            return Error.Conflict("account.deletion_already_requested", "Hesap silme isteğin zaten alındı.");
        if (IsSuspensionInEffect(current))
            return Error.RuleViolation("account.suspended", "Askıdaki hesaplar silme isteğinde bulunamaz. Lütfen destek ekibiyle iletişime geç.");

        // Groups restrict profile deletion (docs/ARCHITECTURE.md §3b).
        await using (var owns = new NpgsqlCommand("select 1 from public.groups where owner_id = @id limit 1", conn, tx))
        {
            owns.Parameters.AddWithValue("id", userId);
            if (await owns.ExecuteScalarAsync(ct) is not null)
            {
                return Error.RuleViolation("account.owns_groups",
                    "Sahibi olduğun gruplar var. Hesabını silmeden önce sahipliği devretmeli ya da grupları silmelisin.");
            }
        }

        var state = await UpdateAsync(conn, tx, userId,
            $"""
            status = 'pending_deletion', suspended_until = null, suspension_reason = null,
            deletion_requested_at = now(), deletion_scheduled_for = now() + interval '{DeletionGraceDays} days'
            """,
            ct);

        await AuditLog.AppendAsync(conn, tx,
            new AuditEntry(userId, AuditActor.User, "account.deletion_requested", "user", userId.ToString(),
                new { scheduledFor = state.DeletionScheduledFor }),
            ct);
        await tx.CommitAsync(ct);
        return state;
    }

    public async Task<Result<AccountState>> CancelDeletionAsync(Guid userId, CancellationToken ct)
    {
        await using var conn = await db.OpenConnectionAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);

        var current = await LockAsync(conn, tx, userId, ct);
        if (current is null) return NotFound;
        if (current.Status != AccountStatuses.PendingDeletion)
            return Error.Conflict("account.no_pending_deletion", "Bekleyen bir hesap silme isteğin yok.");

        var state = await UpdateAsync(conn, tx, userId,
            "status = 'active', deletion_requested_at = null, deletion_scheduled_for = null", ct);

        await AuditLog.AppendAsync(conn, tx,
            new AuditEntry(userId, AuditActor.User, "account.deletion_cancelled", "user", userId.ToString()), ct);
        await tx.CommitAsync(ct);
        return state;
    }

    public async Task<Result<AccountState>> SuspendAsync(Guid actorId, Guid userId, string reason, DateTimeOffset? until, CancellationToken ct)
    {
        reason = reason?.Trim() ?? "";
        if (reason.Length is 0 or > MaxReasonLength)
            return Error.Validation("account.invalid_reason", $"Askıya alma gerekçesi 1-{MaxReasonLength} karakter olmalı.");
        if (until is { } u && u <= DateTimeOffset.UtcNow)
            return Error.Validation("account.invalid_until", "Askı bitiş tarihi gelecekte olmalı.");

        await using var conn = await db.OpenConnectionAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);

        var current = await LockAsync(conn, tx, userId, ct);
        if (current is null) return NotFound;
        if (current.Status == AccountStatuses.PendingDeletion)
            return Error.RuleViolation("account.pending_deletion", "Silinmek üzere olan bir hesap askıya alınamaz.");

        await ApplySuspensionAsync(conn, tx, userId, reason, until, ct);

        await AuditLog.AppendAsync(conn, tx,
            new AuditEntry(actorId, AuditActor.Staff, "user.suspended", "user", userId.ToString(), new { reason, until }), ct);

        var state = await LockAsync(conn, tx, userId, ct);
        await tx.CommitAsync(ct);
        return state!;
    }

    public async Task<Result<AccountState>> UnsuspendAsync(Guid actorId, Guid userId, CancellationToken ct)
    {
        await using var conn = await db.OpenConnectionAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);

        var current = await LockAsync(conn, tx, userId, ct);
        if (current is null) return NotFound;
        if (current.Status != AccountStatuses.Suspended)
            return Error.Conflict("account.not_suspended", "Bu hesap askıda değil.");

        var state = await UpdateAsync(conn, tx, userId,
            "status = 'active', suspended_until = null, suspension_reason = null", ct);

        await using (var cmd = new NpgsqlCommand("update auth.users set banned_until = null where id = @id", conn, tx))
        {
            cmd.Parameters.AddWithValue("id", userId);
            await cmd.ExecuteNonQueryAsync(ct);
        }

        await AuditLog.AppendAsync(conn, tx,
            new AuditEntry(actorId, AuditActor.Staff, "user.unsuspended", "user", userId.ToString()), ct);
        await tx.CommitAsync(ct);
        return state;
    }

    private static bool IsSuspensionInEffect(AccountState s) =>
        s.Status == AccountStatuses.Suspended && (s.SuspendedUntil is null || s.SuspendedUntil > DateTimeOffset.UtcNow);

    /// <summary>
    /// Suspends inside the caller's transaction: account state, Supabase Auth ban and ending the sessions.
    /// Used by staff suspensions and automatic security bans (docs/ARCHITECTURE.md §3h).
    /// </summary>
    internal static async Task ApplySuspensionAsync(
        NpgsqlConnection conn, NpgsqlTransaction tx, Guid userId, string reason, DateTimeOffset? until, CancellationToken ct)
    {
        await using (var cmd = new NpgsqlCommand(
            """
            update public.account_status
            set status = 'suspended', suspended_until = @until, suspension_reason = @reason, updated_at = now()
            where user_id = @id
            """, conn, tx))
        {
            cmd.Parameters.AddWithValue("id", userId);
            cmd.Parameters.AddWithValue("until", (object?)until?.UtcDateTime ?? DBNull.Value);
            cmd.Parameters.AddWithValue("reason", reason);
            await cmd.ExecuteNonQueryAsync(ct);
        }

        // Block sign-in and token refresh in Supabase Auth, and end existing sessions.
        await using (var cmd = new NpgsqlCommand(
            """
            update auth.users set banned_until = coalesce(@until, now() + interval '100 years') where id = @id;
            delete from auth.sessions where user_id = @id;
            """, conn, tx))
        {
            cmd.Parameters.AddWithValue("id", userId);
            cmd.Parameters.AddWithValue("until", (object?)until?.UtcDateTime ?? DBNull.Value);
            await cmd.ExecuteNonQueryAsync(ct);
        }
    }

    private static async Task<AccountState?> LockAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid userId, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand(
            """
            select status, suspended_until, suspension_reason, deletion_scheduled_for
            from public.account_status where user_id = @id for update
            """, conn, tx);
        cmd.Parameters.AddWithValue("id", userId);
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        return await reader.ReadAsync(ct) ? ReadState(reader) : null;
    }

    /// <param name="assignments">Constant SQL only; never user input.</param>
    private static async Task<AccountState> UpdateAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid userId, string assignments, CancellationToken ct)
    {
#pragma warning disable CA2100 // assignments are compile-time constants from this class
        await using var cmd = new NpgsqlCommand(
            $"""
            update public.account_status set {assignments}, updated_at = now()
            where user_id = @id
            returning status, suspended_until, suspension_reason, deletion_scheduled_for
            """, conn, tx);
#pragma warning restore CA2100
        cmd.Parameters.AddWithValue("id", userId);
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        await reader.ReadAsync(ct);
        return ReadState(reader);
    }

    private static AccountState ReadState(NpgsqlDataReader r) => new(
        r.GetString(0),
        r.IsDBNull(1) ? null : r.GetFieldValue<DateTimeOffset>(1),
        r.IsDBNull(2) ? null : r.GetString(2),
        r.IsDBNull(3) ? null : r.GetFieldValue<DateTimeOffset>(3));
}
