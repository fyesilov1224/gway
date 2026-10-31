using Gway.Modules.Support.Contracts;
using Gway.SharedKernel;
using Gway.SharedKernel.Auditing;
using Gway.SharedKernel.Database;
using Microsoft.Extensions.DependencyInjection;
using Npgsql;

namespace Gway.Modules.Support;

public static class SupportModule
{
    /// <summary>Users write their tickets through Supabase (RLS); this module holds the platform team's writes.</summary>
    public static IServiceCollection AddSupportModule(this IServiceCollection services)
    {
        services.AddSingleton<ISupportAdministration, SupportAdministration>();
        return services;
    }
}

/// <summary>Staff replies and status changes (docs/ARCHITECTURE.md §7b). Both are audited.</summary>
internal sealed class SupportAdministration(NpgsqlDataSource db) : ISupportAdministration
{
    private const int MaxBodyLength = 4000;

    private static readonly Error NotFound = Error.NotFound("support.ticket_not_found", "Mesaj bulunamadı.");

    public Task<Result> ReplyAsync(Guid actorId, Guid ticketId, string body, CancellationToken ct)
    {
        body = body?.Trim() ?? "";
        if (body.Length is < 1 or > MaxBodyLength)
            return Task.FromResult<Result>(Error.Validation("support.invalid_body", "Yanıt 1–4000 karakter olmalı."));

        return RunAsync(actorId, ticketId, async (conn, tx, ticket) =>
        {
            if (ticket.Status == SupportStatuses.Closed)
                return Error.RuleViolation("support.ticket_closed", "Kapatılmış bir mesaja yanıt yazılamaz. Önce durumunu değiştir.");

            await using var cmd = new NpgsqlCommand(
                "insert into public.support_messages (ticket_id, author_kind, body) values (@id, 'staff', @body)", conn, tx);
            cmd.Parameters.AddWithValue("id", ticketId);
            cmd.Parameters.AddWithValue("body", body);
            await cmd.ExecuteNonQueryAsync(ct);

            await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.Staff, "support.replied", "support_ticket",
                ticketId.ToString(), new { length = body.Length }, ticket.GroupId), ct);
            return Result.Success();
        }, ct);
    }

    public Task<Result> SetStatusAsync(Guid actorId, Guid ticketId, string status, CancellationToken ct)
    {
        if (!SupportStatuses.All.Contains(status))
            return Task.FromResult<Result>(Error.Validation("support.invalid_status", "Geçersiz durum."));

        return RunAsync(actorId, ticketId, async (conn, tx, ticket) =>
        {
            if (ticket.Status == status) return Result.Success();

            await using var cmd = new NpgsqlCommand("update public.support_tickets set status = @status where id = @id", conn, tx);
            cmd.Parameters.AddWithValue("id", ticketId);
            cmd.Parameters.AddWithValue("status", status);
            await cmd.ExecuteNonQueryAsync(ct);

            await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.Staff, "support.status_changed", "support_ticket",
                ticketId.ToString(), new { from = ticket.Status, to = status }, ticket.GroupId), ct);
            return Result.Success();
        }, ct);
    }

    private sealed record TicketRow(string Status, Guid? GroupId);

    /// <summary>Locks the ticket and runs <paramref name="work"/> with the staff member named to the triggers.</summary>
    private async Task<Result> RunAsync(
        Guid actorId, Guid ticketId, Func<NpgsqlConnection, NpgsqlTransaction, TicketRow, Task<Result>> work, CancellationToken ct)
    {
        await using var conn = await db.OpenConnectionAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);
        await ActingUser.SetAsync(conn, tx, actorId, ct);

        TicketRow? ticket;
        await using (var find = new NpgsqlCommand("select status, group_id from public.support_tickets where id = @id for update", conn, tx))
        {
            find.Parameters.AddWithValue("id", ticketId);
            await using var reader = await find.ExecuteReaderAsync(ct);
            ticket = await reader.ReadAsync(ct) ? new TicketRow(reader.GetString(0), reader.IsDBNull(1) ? null : reader.GetGuid(1)) : null;
        }
        if (ticket is null) return NotFound;

        try
        {
            var result = await work(conn, tx, ticket);
            if (result.IsSuccess) await tx.CommitAsync(ct);
            return result;
        }
        catch (PostgresException ex) when (ex.SqlState == PostgresErrorCodes.RaiseException)
        {
            return Error.RuleViolation($"support.{ex.MessageText}", "Bu işlem destek kurallarına uygun değil.");
        }
    }
}
