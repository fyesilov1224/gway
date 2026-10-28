using GrupX.SharedKernel;
using GrupX.SharedKernel.Auditing;
using GrupX.SharedKernel.Database;
using Npgsql;

namespace GrupX.Modules.Events;

/// <summary>
/// The groups league (docs/ARCHITECTURE.md §3d, Gruplar Ligi): closing seasons, and the platform team taking a group
/// out of an open season. Points and tables are read by the database functions.
/// </summary>
internal sealed class LeagueService(NpgsqlDataSource db)
{
    private static Error RuleError(string code) => code switch
    {
        "league_season_closed" => Error.RuleViolation("league.season_closed", "Bu ayın sezonu kapandı; sonuçlar artık değişmez."),
        "league_forbidden" => Error.Forbidden("league.forbidden", "Ligden çıkarma yalnızca platform ekibinin işidir."),
        _ => Error.RuleViolation($"league.{code}", "Bu işlem şu anda yapılamıyor. Sayfayı yenileyip tekrar dene."),
    };

    /// <summary>Closes the seasons that ended more than 8 days ago (system job); returns how many.</summary>
    public async Task<int> FinalizeAsync(CancellationToken ct)
    {
        await using var cmd = db.CreateCommand("select private.finalize_league_seasons()");
        return (int)(await cmd.ExecuteScalarAsync(ct))!;
    }

    public Task<Result> ExcludeAsync(Guid actorId, DateOnly month, Guid groupId, string reason, CancellationToken ct)
    {
        reason = reason?.Trim() ?? "";
        if (reason.Length is < 3 or > 500) return Task.FromResult<Result>(Error.Validation("league.invalid_reason", "Gerekçe 3–500 karakter olmalı."));
        if (month.Day != 1) return Task.FromResult<Result>(Error.Validation("league.invalid_month", "Ay, ayın ilk günüyle verilmeli."));

        return ActingTransaction.RunAsync(db, actorId, async (conn, tx) =>
        {
            if (await ActingTransaction.ScalarAsync(conn, tx, "select exists (select 1 from public.groups where id = @g)", ct, ("g", groupId)) is not true)
                return Error.NotFound("group.not_found", "Grup bulunamadı.");
            if (await ActingTransaction.ExecuteAsync(conn, tx,
                    "insert into public.league_exclusions (month, group_id, reason) values (@m, @g, @r) on conflict do nothing",
                    ct, ("m", month), ("g", groupId), ("r", reason)) == 0)
                return Error.Conflict("league.already_excluded", "Bu grup bu ayın liginden zaten çıkarıldı.");
            await AuditLog.AppendAsync(conn, tx, new AuditEntry(
                actorId, AuditActor.Staff, "league.group_excluded", "group", groupId.ToString(), new { month, reason }, groupId), ct);
            return Result.Success();
        }, RuleError, ct);
    }

    public Task<Result> RestoreAsync(Guid actorId, DateOnly month, Guid groupId, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actorId, async (conn, tx) =>
        {
            if (await ActingTransaction.ExecuteAsync(conn, tx,
                    "delete from public.league_exclusions where month = @m and group_id = @g", ct, ("m", month), ("g", groupId)) == 0)
                return Error.NotFound("league.not_excluded", "Bu grup bu ayın liginden çıkarılmamış.");
            await AuditLog.AppendAsync(conn, tx, new AuditEntry(
                actorId, AuditActor.Staff, "league.exclusion_removed", "group", groupId.ToString(), new { month }, groupId), ct);
            return Result.Success();
        }, RuleError, ct);
}
