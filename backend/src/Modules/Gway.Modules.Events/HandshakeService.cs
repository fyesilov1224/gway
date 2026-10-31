using System.Security.Claims;
using System.Security.Cryptography;
using Gway.SharedKernel;
using Gway.SharedKernel.Database;
using Gway.SharedKernel.Http;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Npgsql;

namespace Gway.Modules.Events;

/// <param name="Code">Six letters and digits without look-alikes; the QR code carries <c>gway-handshake:{event}:{code}</c>.</param>
public sealed record HandshakeCode(string Code, DateTimeOffset ExpiresAt);

/// <param name="Code">The other person's code, typed or read from their QR code.</param>
public sealed record HandshakeRequest(string? Code);

public sealed record HandshakePerson(Guid Id, string Username, string DisplayName, string? AvatarPath);

/// <param name="AlreadyMet">The two had already shaken hands at this event.</param>
public sealed record HandshakeResult(HandshakePerson Person, bool AlreadyMet);

public static class HandshakeEndpoints
{
    /// <summary>El sıkış (docs/ARCHITECTURE.md §3d): a short-lived code and shaking hands with someone's code.</summary>
    public static IEndpointRouteBuilder MapHandshakeEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapPost("/events/{id:guid}/handshake-code", async (Guid id, ClaimsPrincipal user, HandshakeService handshakes, CancellationToken ct) =>
            (await handshakes.CodeAsync(user.GetUserId(), id, ct)).ToHttpResult());

        app.MapPost("/events/{id:guid}/handshakes", async (
                Guid id, HandshakeRequest body, ClaimsPrincipal user, HandshakeService handshakes, CancellationToken ct) =>
            (await handshakes.ShakeAsync(user.GetUserId(), id, body?.Code, ct)).ToHttpResult());

        return app;
    }
}

/// <summary>Codes and handshakes; the triggers check who may shake hands, when, and the daily limit.</summary>
internal sealed class HandshakeService(NpgsqlDataSource db)
{
    public static readonly TimeSpan CodeLifetime = TimeSpan.FromMinutes(3);

    /// <summary>A code with less than this left is replaced, so a code shown is never about to die.</summary>
    private static readonly TimeSpan MinimumLeft = TimeSpan.FromSeconds(60);

    private const string Alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    private const string QrPrefix = "gway-handshake:";

    private static Error RuleError(string code) => code switch
    {
        "handshake_forbidden" => Error.Forbidden("handshake.forbidden", "Bu işlem için yetkin yok."),
        "handshake_closed" => Error.RuleViolation("handshake.closed",
            "El sıkış yalnızca organizasyona katılanlar arasında, başlamadan bir saat önceden bittikten altı saat sonrasına kadar açıktır."),
        "blocked" => Error.RuleViolation("handshake.blocked", "Bu kişiyle el sıkışamazsın."),
        "handshake_rate_limited" => Error.RuleViolation("handshake.rate_limited", "Bugün çok fazla el sıkıştın. Yarın yeniden dene."),
        "handshake_code_invalid" => Error.RuleViolation("handshake.code_invalid",
            "Kod geçersiz ya da süresi doldu. Karşındakinden kodunu yenilemesini iste."),
        "handshake_self" => Error.Validation("handshake.self", "Kendi kodunu okuttun. Karşındakinin kodunu okut."),
        _ => Error.RuleViolation($"handshake.{code}", "Bu işlem şu anda yapılamıyor. Sayfayı yenileyip tekrar dene."),
    };

    private static string NewCode() => string.Create(6, 0, (span, _) =>
    {
        for (var i = 0; i < span.Length; i++) span[i] = Alphabet[RandomNumberGenerator.GetInt32(Alphabet.Length)];
    });

    /// <summary>The person's current code at the event, renewed when it is close to expiring.</summary>
    public async Task<Result<HandshakeCode>> CodeAsync(Guid actor, Guid eventId, CancellationToken ct)
    {
        // Two codes colliding is about one in a billion; a retry with a new code settles it.
        for (var attempt = 0; ; attempt++)
        {
            try
            {
                return await ActingTransaction.RunAsync<HandshakeCode>(db, actor, async (conn, tx) =>
                {
                    await using (var current = new NpgsqlCommand(
                        "select code, expires_at from public.handshake_codes where event_id = @e and user_id = @u and expires_at > now() + @left",
                        conn, tx))
                    {
                        current.Parameters.AddWithValue("e", eventId);
                        current.Parameters.AddWithValue("u", actor);
                        current.Parameters.AddWithValue("left", MinimumLeft);
                        await using var r = await current.ExecuteReaderAsync(ct);
                        if (await r.ReadAsync(ct)) return new HandshakeCode(r.GetString(0), r.GetFieldValue<DateTimeOffset>(1));
                    }

                    var code = NewCode();
                    await using var insert = new NpgsqlCommand(
                        """
                        insert into public.handshake_codes (event_id, user_id, code, expires_at) values (@e, @u, @code, now() + @life)
                        on conflict (event_id, user_id) do update set code = excluded.code, expires_at = excluded.expires_at
                        returning expires_at
                        """, conn, tx);
                    insert.Parameters.AddWithValue("e", eventId);
                    insert.Parameters.AddWithValue("u", actor);
                    insert.Parameters.AddWithValue("code", code);
                    insert.Parameters.AddWithValue("life", CodeLifetime);
                    await using var created = await insert.ExecuteReaderAsync(ct);
                    await created.ReadAsync(ct);
                    return new HandshakeCode(code, created.GetFieldValue<DateTimeOffset>(0));
                }, RuleError, ct);
            }
            catch (PostgresException ex) when (ex.SqlState == PostgresErrorCodes.UniqueViolation && attempt < 3)
            {
            }
        }
    }

    /// <summary>"gway-handshake:{event}:{code}" or the bare code, any case and spacing.</summary>
    internal static string? Normalize(Guid eventId, string? raw)
    {
        var text = raw?.Trim() ?? "";
        if (text.StartsWith(QrPrefix, StringComparison.OrdinalIgnoreCase))
        {
            var parts = text[QrPrefix.Length..].Split(':');
            if (parts.Length != 2 || !Guid.TryParse(parts[0], out var codeEvent) || codeEvent != eventId) return null;
            text = parts[1];
        }
        var code = new string(text.Where(c => !char.IsWhiteSpace(c) && c != '-').ToArray()).ToUpperInvariant();
        return code.Length == 6 && code.All(Alphabet.Contains) ? code : null;
    }

    public Task<Result<HandshakeResult>> ShakeAsync(Guid actor, Guid eventId, string? raw, CancellationToken ct)
    {
        var code = Normalize(eventId, raw);
        if (code is null) return Task.FromResult<Result<HandshakeResult>>(RuleError("handshake_code_invalid"));

        return ActingTransaction.RunAsync<HandshakeResult>(db, actor, async (conn, tx) =>
        {
            var other = await ActingTransaction.ScalarAsync(conn, tx,
                "select user_id from public.handshake_codes where code = @c and event_id = @e and expires_at > now()", ct,
                ("c", code), ("e", eventId)) as Guid?;
            if (other is null) return RuleError("handshake_code_invalid");
            if (other == actor) return RuleError("handshake_self");

            var (a, b) = actor.CompareTo(other.Value) < 0 ? (actor, other.Value) : (other.Value, actor);
            // Guid and uuid order differently; the database decides which id is smaller.
            var inserted = await ActingTransaction.ExecuteAsync(conn, tx,
                """
                insert into public.handshakes (event_id, user_a, user_b)
                values (@e, least(@a::uuid, @b::uuid), greatest(@a::uuid, @b::uuid))
                on conflict do nothing
                """, ct, ("e", eventId), ("a", a), ("b", b));

            await using var cmd = new NpgsqlCommand("select id, username, display_name, avatar_path from public.profiles where id = @id", conn, tx);
            cmd.Parameters.AddWithValue("id", other.Value);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            if (!await r.ReadAsync(ct)) return RuleError("handshake_code_invalid");
            return new HandshakeResult(
                new HandshakePerson(r.GetGuid(0), r.GetString(1), r.GetString(2), r.IsDBNull(3) ? null : r.GetString(3)), inserted == 0);
        }, RuleError, ct);
    }
}
