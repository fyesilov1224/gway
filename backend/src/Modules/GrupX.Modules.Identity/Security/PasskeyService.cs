using Fido2NetLib;
using Fido2NetLib.Objects;
using GrupX.SharedKernel;
using GrupX.SharedKernel.Auditing;
using Microsoft.Extensions.Options;
using Npgsql;
using NpgsqlTypes;

namespace GrupX.Modules.Identity;

public sealed record PasskeyView(string Id, string Name, DateTimeOffset CreatedAt, DateTimeOffset? LastUsedAt);

/// <param name="Response">The browser's <c>PublicKeyCredential</c> from <c>navigator.credentials.create</c>, as JSON.</param>
public sealed record PasskeyRegistration(string? Name, AuthenticatorAttestationRawResponse Response);

/// <summary>
/// Passkeys (WebAuthn) as a second factor (docs/ARCHITECTURE.md §3h, Parmak izi): the device signs with a key that
/// never leaves it, after a fingerprint, face or screen lock; the server checks the signature.
/// </summary>
internal sealed class PasskeyService(NpgsqlDataSource db, IOptions<SecurityOptions> options, SecurityService security)
{
    public const int MaxPerUser = 10;
    private static readonly TimeSpan ChallengeLifetime = TimeSpan.FromMinutes(5);

    private static readonly Error Expired = Error.Validation(
        "security.passkey_expired", "Süre doldu ya da işlem zaten tamamlandı. Tekrar dene.");

    private static readonly Error Invalid = Error.Validation(
        "security.passkey_invalid", "Parmak izi doğrulanamadı. Tekrar dene ya da başka bir yöntem seç.");

    private static readonly Error None = Error.NotFound(
        "security.passkey_none", "Kayıtlı bir parmak izi (passkey) yok.");

    private readonly Lazy<Fido2> _fido = new(() =>
    {
        var passkeys = options.Value.Passkeys;
        return new Fido2(new Fido2Configuration
        {
            RPID = passkeys.RelyingPartyId,
            RPName = "GrupX",
            Origins = new HashSet<string>(passkeys.Origins, StringComparer.Ordinal),
        }, metadataService: null);
    });

    /// <summary>Options for <c>navigator.credentials.create</c>, as WebAuthn JSON.</summary>
    public async Task<Result<string>> RegistrationOptionsAsync(Guid userId, Guid? sessionId, CancellationToken ct)
    {
        await using var conn = await db.OpenConnectionAsync(ct);
        var state = await SecurityService.ReadStateAsync(conn, null, userId, sessionId, ct);
        if (state.Enforce && !state.SessionVerified) return SecurityService.SessionUnverified;
        if (state.Passkeys >= MaxPerUser)
            return Error.RuleViolation("security.passkey_limit", $"En fazla {MaxPerUser} parmak izi (passkey) ekleyebilirsin.");

        string name, displayName;
        await using (var cmd = new NpgsqlCommand(
            """
            select coalesce(p.username, u.email, 'grupx'), coalesce(p.display_name, p.username, u.email, 'GrupX')
            from auth.users u left join public.profiles p on p.id = u.id where u.id = @u
            """, conn))
        {
            cmd.Parameters.AddWithValue("u", userId);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            await r.ReadAsync(ct);
            (name, displayName) = (r.GetString(0), r.GetString(1));
        }

        var created = _fido.Value.RequestNewCredential(new RequestNewCredentialParams
        {
            User = new Fido2User { Id = userId.ToByteArray(), Name = name, DisplayName = displayName },
            ExcludeCredentials = [.. (await CredentialIdsAsync(conn, userId, ct)).Select(id => new PublicKeyCredentialDescriptor(id))],
            AuthenticatorSelection = new AuthenticatorSelection
            {
                ResidentKey = ResidentKeyRequirement.Preferred,
                UserVerification = UserVerificationRequirement.Required,
            },
            AttestationPreference = AttestationConveyancePreference.None,
        });
        var json = created.ToJson();
        await SaveChallengeAsync(conn, userId, "register", json, ct);
        return json;
    }

    public async Task<Result<PasskeyView>> RegisterAsync(Guid userId, Guid? sessionId, PasskeyRegistration body, CancellationToken ct)
    {
        ArgumentNullException.ThrowIfNull(body);
        var name = string.IsNullOrWhiteSpace(body.Name) ? "Parmak izi" : body.Name.Trim();
        if (name.Length > 60) return Error.Validation("security.passkey_name", "Ad en fazla 60 karakter olabilir.");

        await using var conn = await db.OpenConnectionAsync(ct);
        var state = await SecurityService.ReadStateAsync(conn, null, userId, sessionId, ct);
        if (state.Enforce && !state.SessionVerified) return SecurityService.SessionUnverified;
        if (await TakeChallengeAsync(conn, userId, "register", ct) is not { } json) return Expired;

        RegisteredPublicKeyCredential credential;
        try
        {
            credential = await _fido.Value.MakeNewCredentialAsync(new MakeNewCredentialParams
            {
                AttestationResponse = body.Response,
                OriginalOptions = CredentialCreateOptions.FromJson(json),
                IsCredentialIdUniqueToUserCallback = async (args, token) =>
                {
                    await using var cmd = new NpgsqlCommand("select 1 from public.passkeys where id = @id", conn);
                    cmd.Parameters.AddWithValue("id", args.CredentialId);
                    return await cmd.ExecuteScalarAsync(token) is null;
                },
            }, ct);
        }
        catch (Fido2VerificationException)
        {
            return Invalid;
        }

        await using var tx = await conn.BeginTransactionAsync(ct);
        var now = DateTimeOffset.UtcNow;
        await using (var cmd = new NpgsqlCommand(
            """
            insert into public.passkeys (id, user_id, public_key, sign_count, transports, aaguid, name)
            values (@id, @u, @key, @count, @transports, @aaguid, @name)
            """, conn, tx))
        {
            cmd.Parameters.AddWithValue("id", credential.Id);
            cmd.Parameters.AddWithValue("u", userId);
            cmd.Parameters.AddWithValue("key", credential.PublicKey);
            cmd.Parameters.AddWithValue("count", (long)credential.SignCount);
            cmd.Parameters.AddWithValue("transports", (credential.Transports ?? []).Select(t => t.ToString()).ToArray());
            cmd.Parameters.AddWithValue("aaguid", NpgsqlDbType.Uuid, credential.AaGuid == Guid.Empty ? DBNull.Value : credential.AaGuid);
            cmd.Parameters.AddWithValue("name", name);
            await cmd.ExecuteNonQueryAsync(ct);
        }
        await AuditLog.AppendAsync(conn, tx, new AuditEntry(userId, AuditActor.User, "security.passkey_added", "user",
            userId.ToString(), new { name }), ct);
        await tx.CommitAsync(ct);
        return new PasskeyView(Base64Url(credential.Id), name, now, null);
    }

    public async Task<IReadOnlyList<PasskeyView>> ListAsync(Guid userId, CancellationToken ct)
    {
        await using var cmd = db.CreateCommand(
            "select id, name, created_at, last_used_at from public.passkeys where user_id = @u order by created_at");
        cmd.Parameters.AddWithValue("u", userId);
        await using var r = await cmd.ExecuteReaderAsync(ct);
        var list = new List<PasskeyView>();
        while (await r.ReadAsync(ct))
        {
            list.Add(new PasskeyView(Base64Url((byte[])r[0]), r.GetString(1), r.GetFieldValue<DateTimeOffset>(2),
                r.IsDBNull(3) ? null : r.GetFieldValue<DateTimeOffset>(3)));
        }
        return list;
    }

    public async Task<Result> DeleteAsync(Guid userId, Guid? sessionId, string id, CancellationToken ct)
    {
        if (FromBase64Url(id) is not { } credentialId) return None;
        await using var conn = await db.OpenConnectionAsync(ct);
        var state = await SecurityService.ReadStateAsync(conn, null, userId, sessionId, ct);
        if (state.Enforce && !state.SessionVerified) return SecurityService.SessionUnverified;

        await using var tx = await conn.BeginTransactionAsync(ct);
        await using (var cmd = new NpgsqlCommand("delete from public.passkeys where id = @id and user_id = @u", conn, tx))
        {
            cmd.Parameters.AddWithValue("id", credentialId);
            cmd.Parameters.AddWithValue("u", userId);
            if (await cmd.ExecuteNonQueryAsync(ct) == 0) return None;
        }
        await AuditLog.AppendAsync(conn, tx, new AuditEntry(userId, AuditActor.User, "security.passkey_removed", "user", userId.ToString()), ct);
        await tx.CommitAsync(ct);
        return Result.Success();
    }

    /// <summary>Options for <c>navigator.credentials.get</c> in the second-factor step.</summary>
    public async Task<Result<string>> AssertionOptionsAsync(Guid userId, CancellationToken ct)
    {
        await using var conn = await db.OpenConnectionAsync(ct);
        var state = await SecurityService.ReadStateAsync(conn, null, userId, null, ct);
        if (SecurityService.Precondition(state) is { } error) return error;
        if (state.Phone is null) return SecurityService.PhoneRequired;

        var ids = await CredentialIdsAsync(conn, userId, ct);
        if (ids.Count == 0) return None;
        var assertion = _fido.Value.GetAssertionOptions(new GetAssertionOptionsParams
        {
            AllowedCredentials = [.. ids.Select(id => new PublicKeyCredentialDescriptor(id))],
            UserVerification = UserVerificationRequirement.Required,
        });
        var json = assertion.ToJson();
        await SaveChallengeAsync(conn, userId, "assert", json, ct);
        return json;
    }

    public async Task<Result<SecurityStatus>> VerifyAsync(
        Guid userId, Guid? sessionId, AuthenticatorAssertionRawResponse response, CancellationToken ct)
    {
        ArgumentNullException.ThrowIfNull(response);
        if (sessionId is null) return SecurityService.NoSession;

        await using var conn = await db.OpenConnectionAsync(ct);
        var state = await SecurityService.ReadStateAsync(conn, null, userId, sessionId, ct);
        if (SecurityService.Precondition(state) is { } error) return error;
        if (state.Phone is null) return SecurityService.PhoneRequired;
        if (await TakeChallengeAsync(conn, userId, "assert", ct) is not { } json) return Expired;

        byte[] publicKey;
        long count;
        await using (var cmd = new NpgsqlCommand(
            "select public_key, sign_count from public.passkeys where id = @id and user_id = @u", conn))
        {
            cmd.Parameters.AddWithValue("id", response.RawId ?? []);
            cmd.Parameters.AddWithValue("u", userId);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            if (!await r.ReadAsync(ct)) return Invalid;
            (publicKey, count) = ((byte[])r[0], r.GetInt64(1));
        }

        VerifyAssertionResult result;
        try
        {
            result = await _fido.Value.MakeAssertionAsync(new MakeAssertionParams
            {
                AssertionResponse = response,
                OriginalOptions = AssertionOptions.FromJson(json),
                StoredPublicKey = publicKey,
                StoredSignatureCounter = (uint)count,
                // The key must belong to this account: its user handle is the account id.
                IsUserHandleOwnerOfCredentialIdCallback = (args, _) =>
                    Task.FromResult(args.UserHandle is not { Length: 16 } handle || new Guid(handle) == userId),
            }, ct);
        }
        catch (Fido2VerificationException)
        {
            return Invalid;
        }

        await using var tx = await conn.BeginTransactionAsync(ct);
        await using (var cmd = new NpgsqlCommand(
            "update public.passkeys set sign_count = @count, last_used_at = now() where id = @id", conn, tx))
        {
            cmd.Parameters.AddWithValue("count", (long)result.SignCount);
            cmd.Parameters.AddWithValue("id", result.CredentialId);
            await cmd.ExecuteNonQueryAsync(ct);
        }
        try
        {
            await SecurityService.MarkSessionVerifiedAsync(conn, tx, userId, sessionId.Value, "passkey", ct);
        }
        catch (PostgresException ex) when (ex.SqlState == PostgresErrorCodes.ForeignKeyViolation)
        {
            return SecurityService.NoSession;
        }
        await tx.CommitAsync(ct);
        return await security.GetStatusAsync(userId, sessionId, ct);
    }

    private static async Task<List<byte[]>> CredentialIdsAsync(NpgsqlConnection conn, Guid userId, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand("select id from public.passkeys where user_id = @u", conn);
        cmd.Parameters.AddWithValue("u", userId);
        await using var r = await cmd.ExecuteReaderAsync(ct);
        var ids = new List<byte[]>();
        while (await r.ReadAsync(ct)) ids.Add((byte[])r[0]);
        return ids;
    }

    private static async Task SaveChallengeAsync(NpgsqlConnection conn, Guid userId, string purpose, string json, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand(
            """
            insert into public.webauthn_challenges (user_id, purpose, options, expires_at) values (@u, @p, @o, @e)
            on conflict (user_id, purpose) do update set options = excluded.options, expires_at = excluded.expires_at
            """, conn);
        cmd.Parameters.AddWithValue("u", userId);
        cmd.Parameters.AddWithValue("p", purpose);
        cmd.Parameters.AddWithValue("o", json);
        cmd.Parameters.AddWithValue("e", DateTimeOffset.UtcNow.Add(ChallengeLifetime));
        await cmd.ExecuteNonQueryAsync(ct);
    }

    /// <summary>Single use: the pending options are deleted as they are read.</summary>
    private static async Task<string?> TakeChallengeAsync(NpgsqlConnection conn, Guid userId, string purpose, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand(
            "delete from public.webauthn_challenges where user_id = @u and purpose = @p and expires_at > now() returning options", conn);
        cmd.Parameters.AddWithValue("u", userId);
        cmd.Parameters.AddWithValue("p", purpose);
        return await cmd.ExecuteScalarAsync(ct) as string;
    }

    internal static string Base64Url(byte[] bytes) =>
        Convert.ToBase64String(bytes).TrimEnd('=').Replace('+', '-').Replace('/', '_');

    private static byte[]? FromBase64Url(string value)
    {
        var s = value.Replace('-', '+').Replace('_', '/');
        s = s.PadRight(s.Length + ((4 - (s.Length % 4)) % 4), '=');
        try
        {
            return Convert.FromBase64String(s);
        }
        catch (FormatException)
        {
            return null;
        }
    }
}
