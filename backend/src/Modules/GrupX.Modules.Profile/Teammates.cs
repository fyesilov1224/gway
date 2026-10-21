using GrupX.SharedKernel;
using GrupX.SharedKernel.Database;
using Npgsql;

namespace GrupX.Modules.Profile;

public sealed record TeammateRequestBody(string? Message)
{
    public const int MaxMessageLength = 200;
}

public sealed record TeammateResponse(string Status)
{
    public const string Requested = "requested";
    public const string Teammates = "teammates";
}

/// <summary>Teammate requests and the teammates relation (docs/ARCHITECTURE.md §3c, Ekip arkadaşı). Triggers re-check every rule.</summary>
internal sealed class Teammates(NpgsqlDataSource db)
{
    private static readonly Error NotFound = Error.NotFound("profile.not_found", "Kullanıcı bulunamadı.");
    private static readonly Error Self = Error.Validation("profile.self", "Bu işlemi kendi hesabına uygulayamazsın.");
    private static readonly Error NoRequest = Error.NotFound("profile.no_teammate_request", "Bekleyen bir ekip arkadaşlığı isteği bulunamadı.");

    private static Error RuleError(string code) => code switch
    {
        "blocked" => NotFound,
        "teammate_not_looking" => Error.RuleViolation("profile.teammate_not_looking", "Bu kişi şu anda ekip arkadaşı aramıyor."),
        "teammate_recently_asked" => Error.RuleViolation(
            "profile.teammate_recently_asked", "Bu kişiye son 24 saatte zaten istek gönderdin. Yarın tekrar deneyebilirsin."),
        "teammate_rate_limited" => Error.RuleViolation(
            "profile.teammate_rate_limited", "Bugün çok fazla ekip arkadaşlığı isteği gönderdin. Yarın tekrar dene."),
        _ => Error.RuleViolation($"profile.{code}", "Bu işlem şu anda yapılamıyor. Sayfayı yenileyip tekrar dene."),
    };

    private static Task<int> PairAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid a, Guid b, CancellationToken ct) =>
        ActingTransaction.ExecuteAsync(conn, tx,
            "insert into public.teammates (user_a, user_b) values (least(@a, @b), greatest(@a, @b)) on conflict do nothing", ct,
            ("a", a), ("b", b));

    private static Task<int> DropRequestAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid requester, Guid target, CancellationToken ct) =>
        ActingTransaction.ExecuteAsync(conn, tx,
            "delete from public.teammate_requests where requester_id = @r and target_id = @t", ct, ("r", requester), ("t", target));

    /// <summary>Sends a request; when the other person already asked, it accepts theirs instead.</summary>
    public Task<Result<TeammateResponse>> RequestAsync(Guid actor, Guid target, string? message, CancellationToken ct)
    {
        message = message?.Trim() ?? "";
        if (actor == target) return Task.FromResult<Result<TeammateResponse>>(Self);
        if (message.Length > TeammateRequestBody.MaxMessageLength)
        {
            return Task.FromResult<Result<TeammateResponse>>(
                Error.Validation("profile.teammate_message_too_long", $"Mesaj en fazla {TeammateRequestBody.MaxMessageLength} karakter olabilir."));
        }

        return ActingTransaction.RunAsync<TeammateResponse>(db, actor, async (conn, tx) =>
        {
            var visible = await ActingTransaction.ScalarAsync(conn, tx,
                "select 1 from public.profiles where id = @id and private.is_account_active(id) and not private.has_blocked(id, @actor)", ct,
                ("id", target), ("actor", actor));
            if (visible is null) return NotFound;

            var teammates = (bool)(await ActingTransaction.ScalarAsync(conn, tx, "select private.are_teammates(@a, @b)", ct,
                ("a", actor), ("b", target)))!;
            if (teammates) return new TeammateResponse(TeammateResponse.Teammates);

            var incoming = await ActingTransaction.ScalarAsync(conn, tx,
                "select 1 from public.teammate_requests where requester_id = @t and target_id = @a for update", ct,
                ("t", target), ("a", actor));
            if (incoming is not null)
            {
                await PairAsync(conn, tx, actor, target, ct);
                await DropRequestAsync(conn, tx, target, actor, ct);
                return new TeammateResponse(TeammateResponse.Teammates);
            }

            var pending = await ActingTransaction.ScalarAsync(conn, tx,
                "select 1 from public.teammate_requests where requester_id = @a and target_id = @t", ct, ("a", actor), ("t", target));
            if (pending is not null) return new TeammateResponse(TeammateResponse.Requested);

            await ActingTransaction.ExecuteAsync(conn, tx,
                "insert into public.teammate_requests (requester_id, target_id, message) values (@a, @t, @m)", ct,
                ("a", actor), ("t", target), ("m", message));
            return new TeammateResponse(TeammateResponse.Requested);
        }, RuleError, ct);
    }

    /// <summary>Withdraws a request or ends the pair; nothing to undo is fine.</summary>
    public Task<Result> RemoveAsync(Guid actor, Guid other, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            await DropRequestAsync(conn, tx, actor, other, ct);
            await ActingTransaction.ExecuteAsync(conn, tx,
                "delete from public.teammates where user_a = least(@a, @b) and user_b = greatest(@a, @b)", ct, ("a", actor), ("b", other));
            return Result.Success();
        }, RuleError, ct);

    public Task<Result> AcceptAsync(Guid actor, Guid requester, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            var exists = await ActingTransaction.ScalarAsync(conn, tx,
                "select 1 from public.teammate_requests where requester_id = @r and target_id = @t for update", ct,
                ("r", requester), ("t", actor));
            if (exists is null) return NoRequest;

            await PairAsync(conn, tx, actor, requester, ct);
            await DropRequestAsync(conn, tx, requester, actor, ct);
            return Result.Success();
        }, RuleError, ct);

    public Task<Result> DeclineAsync(Guid actor, Guid requester, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
            await DropRequestAsync(conn, tx, requester, actor, ct) > 0 ? Result.Success() : NoRequest,
            RuleError, ct);
}
