using System.Security.Claims;
using GrupX.SharedKernel;
using GrupX.SharedKernel.Database;
using GrupX.SharedKernel.Http;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Routing;
using Npgsql;

namespace GrupX.Modules.Events;

public sealed record TonightAnswerRequest(bool Accept);

public sealed record CreatedTable(Guid Id, int Invited);

public static class TonightEndpoints
{
    /// <summary>
    /// The small table (docs/ARCHITECTURE.md §3d, Bu akşam boşum ve küçük masa). Saying "boşum" goes through Supabase;
    /// these writes affect other people.
    /// </summary>
    public static IEndpointRouteBuilder MapTonightEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapPost("/tonight/tables", async (ClaimsPrincipal user, TonightService tonight, CancellationToken ct) =>
            (await tonight.CreateAsync(user.GetUserId(), ct)).ToHttpResult());

        app.MapPost("/tonight/tables/{id:guid}/answer", async (
                Guid id, TonightAnswerRequest body, ClaimsPrincipal user, TonightService tonight, CancellationToken ct) =>
            (await tonight.AnswerAsync(user.GetUserId(), id, body.Accept, ct)).ToHttpResult());

        app.MapDelete("/tonight/tables/{id:guid}/membership", async (Guid id, ClaimsPrincipal user, TonightService tonight, CancellationToken ct) =>
            (await tonight.LeaveAsync(user.GetUserId(), id, ct)).ToHttpResult());

        return app;
    }
}

/// <summary>Small table writes; the database triggers check the one-table-per-evening rule and the closing time again.</summary>
internal sealed class TonightService(NpgsqlDataSource db)
{
    /// <summary>People asked besides the founder; with the founder a table seats 3–6.</summary>
    public const int MaxInvited = 5;

    public const int MinInvited = 2;

    private static readonly Error NotFree = Error.RuleViolation("tonight.not_free", "Küçük masa kurmak için önce \"Bu akşam boşum\" demelisin.");
    private static readonly Error AlreadyInTable = Error.Conflict("tonight.already_in_table", "Bu akşam zaten bir masadasın.");
    private static readonly Error AlreadyFounded = Error.Conflict("tonight.already_founded", "Bu akşam zaten bir masa kurdun.");
    private static readonly Error NotEnough = Error.RuleViolation("tonight.not_enough_people",
        "Şu anda ortak gruplarından boş olan yeterli kişi yok. Biraz sonra tekrar deneyebilirsin.");
    private static readonly Error NoInvite = Error.NotFound("tonight.no_invite", "Bu masaya bir davetin yok.");
    private static readonly Error NotAtTable = Error.NotFound("tonight.not_at_table", "Bu masada değilsin.");
    private static readonly Error Closed = Error.RuleViolation("tonight.closed", "Bu masa kapandı.");

    private static Error RuleError(string code) => code switch
    {
        "tonight_already_in_table" => AlreadyInTable,
        "tonight_closed" => Closed,
        _ => Error.RuleViolation($"tonight.{code}", "Bu işlem şu anda yapılamıyor. Sayfayı yenileyip tekrar dene."),
    };

    public Task<Result<CreatedTable>> CreateAsync(Guid actor, CancellationToken ct) =>
        ActingTransaction.RunAsync<CreatedTable>(db, actor, async (conn, tx) =>
        {
            if (await ActingTransaction.ScalarAsync(conn, tx, "select private.is_free_tonight(@a)", ct, ("a", actor)) is not true)
                return NotFree;
            // One founder at a time: a second request waits here and then sees the first table.
            await ActingTransaction.ExecuteAsync(conn, tx, "select pg_advisory_xact_lock(hashtext('tonight:' || @a::text))", ct, ("a", actor));
            if (await ActingTransaction.ScalarAsync(conn, tx,
                    "select exists (select 1 from public.tonight_tables where created_by = @a and evening = private.tonight_evening())",
                    ct, ("a", actor)) is true)
                return AlreadyFounded;
            if (await ActingTransaction.ScalarAsync(conn, tx,
                    """
                    select exists (select 1 from public.tonight_table_invites
                                   where user_id = @a and evening = private.tonight_evening() and state = 'accepted')
                    """, ct, ("a", actor)) is true)
                return AlreadyInTable;

            var candidates = new List<Guid>();
            await using (var cmd = new NpgsqlCommand("select private.tonight_candidates(@a, @n)", conn, tx))
            {
                cmd.Parameters.AddWithValue("a", actor);
                cmd.Parameters.AddWithValue("n", MaxInvited);
                await using var r = await cmd.ExecuteReaderAsync(ct);
                while (await r.ReadAsync(ct)) candidates.Add(r.GetGuid(0));
            }
            if (candidates.Count < MinInvited) return NotEnough;

            var id = (Guid)(await ActingTransaction.ScalarAsync(conn, tx,
                """
                insert into public.tonight_tables (created_by, evening, closes_at)
                values (@a, private.tonight_evening(), private.tonight_table_closes(private.tonight_evening()))
                returning id
                """, ct, ("a", actor)))!;
            await ActingTransaction.ExecuteAsync(conn, tx,
                "insert into public.tonight_table_invites (table_id, user_id, state) values (@t, @a, 'accepted')", ct, ("t", id), ("a", actor));
            await ActingTransaction.ExecuteAsync(conn, tx,
                "insert into public.tonight_table_invites (table_id, user_id) select @t, unnest(@people)", ct,
                ("t", id), ("people", candidates.ToArray()));
            return new CreatedTable(id, candidates.Count);
        }, RuleError, ct);

    public Task<Result> AnswerAsync(Guid actor, Guid tableId, bool accept, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            var state = await ActingTransaction.ScalarAsync(conn, tx,
                "select state from public.tonight_table_invites where table_id = @t and user_id = @a for update", ct, ("t", tableId), ("a", actor));
            if (state is not "pending") return NoInvite;
            await ActingTransaction.ExecuteAsync(conn, tx,
                "update public.tonight_table_invites set state = @s where table_id = @t and user_id = @a", ct,
                ("s", accept ? "accepted" : "declined"), ("t", tableId), ("a", actor));
            return Result.Success();
        }, RuleError, ct);

    public Task<Result> LeaveAsync(Guid actor, Guid tableId, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
            await ActingTransaction.ExecuteAsync(conn, tx,
                "update public.tonight_table_invites set state = 'left' where table_id = @t and user_id = @a and state = 'accepted'",
                ct, ("t", tableId), ("a", actor)) == 0
                ? NotAtTable
                : Result.Success(), RuleError, ct);
}
