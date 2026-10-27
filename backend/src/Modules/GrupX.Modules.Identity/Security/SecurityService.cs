using GrupX.SharedKernel;
using GrupX.SharedKernel.Auditing;
using GrupX.SharedKernel.Geo;
using Microsoft.AspNetCore.Http;
using Npgsql;
using NpgsqlTypes;

namespace GrupX.Modules.Identity;

/// <summary>What the app must do next (docs/ARCHITECTURE.md §3h, Akış).</summary>
public static class SecuritySteps
{
    public const string Location = "location";
    public const string Phone = "phone";
    public const string SecondFactor = "second_factor";
    public const string Restricted = "restricted";
    public const string Done = "done";
}

/// <param name="CallingCode">Dialling code of <paramref name="AllowedCountry"/>; the app locks the phone prefix to it.</param>
/// <param name="Warnings">Only on a location check's answer: messages for the user that do not restrict (<c>vpn_installed</c>).</param>
public sealed record SecurityStatus(
    bool Enforced,
    bool SessionVerified,
    string Step,
    string? AllowedCountry,
    int? CallingCode,
    string? PhoneMasked,
    bool TotpEnabled,
    IReadOnlyList<string>? Warnings = null);

public sealed record LocationSignals(
    double Latitude,
    double Longitude,
    double? Accuracy,
    bool IsMocked,
    bool Vpn,
    string? SimCountry,
    string Platform,
    IReadOnlyList<string>? VpnApps = null);

public sealed record PhoneStartRequest(string Phone);

public sealed record PhoneVerifyRequest(string Phone, string Code);

public sealed record SecondFactorRequest(string Method, string Code);

public sealed record TotpCodeRequest(string Code);

public sealed record TotpSetup(string Secret, string Uri);

/// <summary>Signal codes stored on checks and reviews.</summary>
internal static class SecuritySignals
{
    // Certain: banned automatically.
    public const string MockLocation = "mock_location";
    public const string ForeignPhone = "foreign_phone";
    public const string BannedPhone = "banned_phone";

    // Uncertain: restricted until staff review.
    public const string IpMismatch = "ip_mismatch";
    public const string Vpn = "vpn";
    public const string SimMismatch = "sim_mismatch";
    public const string PhoneMismatch = "phone_mismatch";

    // Information only: a warning for the user, no restriction.
    public const string VpnInstalled = "vpn_installed";
}

/// <summary>
/// The user side of security verification (docs/ARCHITECTURE.md §3h): location checks and their verdict, phone
/// verification locked to the allowed country, the per-session second factor and the authenticator app.
/// What counts as a verified session is defined once, in <c>private.is_session_verified</c>.
/// </summary>
internal sealed class SecurityService(NpgsqlDataSource db, ISmsVerifier sms, CountryResolver geo, TimeProvider time)
{
    public const int RetentionDays = 90;
    private const int SmsPerUserHour = 5;
    private const int SmsPerUserDay = 10;
    private const int SmsPerPhoneHour = 5;
    private const string BanReason = "Güvenlik doğrulaması: otomatik kapatma";

    private static readonly Lazy<CountryLocator> Borders = new(CountryLocator.Load);

    private static readonly HashSet<string> Platforms = ["android", "ios", "web"];

    private const int MaxVpnApps = 20;

    private static readonly Error LocationRequired = Error.RuleViolation(
        "security.location_required", "Devam etmek için konumunu doğrulamamız gerekiyor.");

    private static readonly Error Restricted = Error.Forbidden(
        "security.restricted", "Hesabın güvenlik incelemesinde. Sorun olduğunu düşünüyorsan destek ekibine yaz.");

    private static readonly Error Banned = Error.Forbidden(
        "security.banned", "Hesabın güvenlik nedeniyle kapatıldı. İtiraz için destek ekibine yaz.");

    private static readonly Error PhoneInUse = Error.Conflict(
        "security.phone_in_use", "Bu numara başka bir hesapta kayıtlı.");

    private static readonly Error PhoneAlreadyVerified = Error.Conflict(
        "security.phone_already_verified", "Telefon numaran zaten doğrulandı.");

    private static readonly Error PhoneRequired = Error.RuleViolation(
        "security.phone_required", "Önce telefon numaranı doğrulaman gerekiyor.");

    private static readonly Error CodeInvalid = Error.Validation(
        "security.code_invalid", "Kod hatalı ya da süresi dolmuş.");

    private static readonly Error NoSession = Error.Unauthorized(
        "security.no_session", "Oturumun bulunamadı. Lütfen yeniden giriş yap.");

    private static readonly Error SessionUnverified = Error.Forbidden(
        "security.session_unverified", "Bu işlem için önce oturumunu doğrulaman gerekiyor.");

    private static readonly Error NotMobile = Error.Validation(
        "security.phone_not_mobile", "Yalnızca cep telefonu numarasıyla doğrulama yapılabilir.");

    private sealed record UserState(
        bool Enforce,
        string State,
        string? AllowedCountry,
        bool LocationFresh,
        string? Phone,
        bool Totp,
        bool SessionVerified);

    public async Task<SecurityStatus> GetStatusAsync(Guid userId, Guid? sessionId, CancellationToken ct)
    {
        await using var conn = await db.OpenConnectionAsync(ct);
        return ToStatus(await ReadStateAsync(conn, null, userId, sessionId, ct));
    }

    public async Task<Result<SecurityStatus>> RecordLocationAsync(
        Guid userId, Guid? sessionId, LocationSignals signals, HttpContext http, CancellationToken ct)
    {
        ArgumentNullException.ThrowIfNull(signals);
        if (!double.IsFinite(signals.Latitude) || !double.IsFinite(signals.Longitude)
            || signals.Latitude is < -90 or > 90 || signals.Longitude is < -180 or > 180
            || signals.Accuracy is < 0 || !Platforms.Contains(signals.Platform ?? ""))
            return Error.Validation("security.location_invalid", "Konum bilgisi okunamadı. Tekrar dene.");

        // Package names only; anything else the device sent is dropped rather than failing the sign-in.
        var vpnApps = (signals.VpnApps ?? [])
            .Where(a => a is { Length: > 0 and <= 200 } && a.All(c => char.IsAsciiLetterOrDigit(c) || c is '.' or '_'))
            .Distinct(StringComparer.Ordinal)
            .Take(MaxVpnApps)
            .ToArray();
        var gps = Borders.Value.CountryAt(signals.Latitude, signals.Longitude);
        var ip = geo.TryResolve(http);
        var sim = CountryResolver.Normalize(signals.SimCountry);
        var allowed = gps ?? ip ?? geo.Resolve(http);

        await using var conn = await db.OpenConnectionAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);

        var (state, exempt) = await LockUserSecurityAsync(conn, tx, userId, ct);
        var switches = await ReadSwitchesAsync(conn, tx, ct);
        var phoneCountry = await ScalarAsync<string>(conn, tx,
            "select country from public.phone_verifications where user_id = @u", ("u", userId), ct);

        var hard = new List<string>();
        var soft = new List<string>();
        var warnings = new List<string>();
        if (signals.IsMocked) hard.Add(SecuritySignals.MockLocation);
        if (switches.DetectVpn)
        {
            if (gps is not null && ip is not null && gps != ip) soft.Add(SecuritySignals.IpMismatch);
            if (signals.Vpn) soft.Add(SecuritySignals.Vpn);
        }
        if (switches.DetectPhoneMismatch)
        {
            if (sim is not null && sim != allowed) soft.Add(SecuritySignals.SimMismatch);
            if (phoneCountry is not null && phoneCountry != allowed) soft.Add(SecuritySignals.PhoneMismatch);
        }
        // A running VPN is already a signal; an installed one only warns.
        if (switches.WarnInstalledVpn && vpnApps.Length > 0 && !signals.Vpn) warnings.Add(SecuritySignals.VpnInstalled);

        var all = hard.Concat(soft).Concat(warnings).ToArray();
        var staff = await IsStaffAsync(conn, tx, userId, ct);
        var verdict = hard.Count > 0 && !staff ? "banned"
            : hard.Count > 0 || (soft.Count > 0 && !exempt) ? "restricted"
            : "ok";

        long checkId;
        await using (var cmd = new NpgsqlCommand(
            """
            insert into public.location_checks
              (user_id, platform, gps_country, ip_country, sim_country, phone_country, accuracy_m, is_mocked, vpn, vpn_apps, signals, verdict)
            values (@u, @platform, @gps, @ip, @sim, @phone, @accuracy, @mocked, @vpn, @apps, @signals, @verdict)
            returning id
            """, conn, tx))
        {
            cmd.Parameters.AddWithValue("u", userId);
            cmd.Parameters.AddWithValue("platform", signals.Platform!);
            cmd.Parameters.AddWithValue("gps", (object?)gps ?? DBNull.Value);
            cmd.Parameters.AddWithValue("ip", (object?)ip ?? DBNull.Value);
            cmd.Parameters.AddWithValue("sim", (object?)sim ?? DBNull.Value);
            cmd.Parameters.AddWithValue("phone", (object?)phoneCountry ?? DBNull.Value);
            cmd.Parameters.AddWithValue("accuracy", NpgsqlDbType.Real, signals.Accuracy is { } a ? (float)a : DBNull.Value);
            cmd.Parameters.AddWithValue("mocked", signals.IsMocked);
            cmd.Parameters.AddWithValue("vpn", signals.Vpn);
            cmd.Parameters.AddWithValue("apps", vpnApps);
            cmd.Parameters.AddWithValue("signals", all);
            cmd.Parameters.AddWithValue("verdict", verdict);
            checkId = (long)(await cmd.ExecuteScalarAsync(ct))!;
        }

        if (verdict == "banned")
        {
            await BanAsync(conn, tx, userId, all, null, checkId, null, ct);
            await tx.CommitAsync(ct);
            return Banned;
        }

        if (verdict == "restricted") await RestrictAsync(conn, tx, userId, state, [.. hard, .. soft], checkId, ct);

        await ExecuteAsync(conn, tx,
            """
            update public.user_security
            set location_checked_at = now(), allowed_country = @allowed, updated_at = now()
            where user_id = @u
            """, ct, ("u", userId), ("allowed", allowed));

        var result = ToStatus(await ReadStateAsync(conn, tx, userId, sessionId, ct)) with { Warnings = warnings };
        await tx.CommitAsync(ct);
        return result;
    }

    private sealed record Switches(bool DetectVpn, bool WarnInstalledVpn, bool DetectPhoneMismatch);

    private static async Task<Switches> ReadSwitchesAsync(NpgsqlConnection conn, NpgsqlTransaction tx, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand(
            "select detect_vpn, warn_installed_vpn, detect_phone_mismatch from public.security_settings", conn, tx);
        await using var r = await cmd.ExecuteReaderAsync(ct);
        await r.ReadAsync(ct);
        return new Switches(r.GetBoolean(0), r.GetBoolean(1), r.GetBoolean(2));
    }

    public async Task<Result> StartPhoneAsync(Guid userId, PhoneStartRequest body, CancellationToken ct)
    {
        ArgumentNullException.ThrowIfNull(body);
        if (!sms.IsConfigured) return SmsErrors.NotConfigured;

        var checkedPhone = await CheckNewPhoneAsync(userId, body.Phone, ct);
        if (!checkedPhone.IsSuccess) return checkedPhone.Error;
        var (phone, allowed) = checkedPhone.Value;

        // Lookup costs money: only after the free checks and the rate limit.
        if (await sms.LineTypeAsync(phone.E164, ct) is { } lineType && lineType != "mobile") return NotMobile;
        return await SendAsync(userId, phone.E164, allowed, "phone", ct);
    }

    public async Task<Result<SecurityStatus>> VerifyPhoneAsync(Guid userId, Guid? sessionId, PhoneVerifyRequest body, CancellationToken ct)
    {
        ArgumentNullException.ThrowIfNull(body);
        if (sessionId is null) return NoSession;
        if (!sms.IsConfigured) return SmsErrors.NotConfigured;

        var checkedPhone = await CheckNewPhoneAsync(userId, body.Phone, ct);
        if (!checkedPhone.IsSuccess) return checkedPhone.Error;
        var (phone, _) = checkedPhone.Value;

        var approved = await sms.CheckAsync(phone.E164, body.Code?.Trim() ?? "", ct);
        if (!approved.IsSuccess) return approved.Error;
        if (!approved.Value) return CodeInvalid;

        await using var conn = await db.OpenConnectionAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);
        try
        {
            await ExecuteAsync(conn, tx,
                "insert into public.phone_verifications (user_id, phone, country) values (@u, @phone, @country)",
                ct, ("u", userId), ("phone", phone.E164), ("country", phone.Country));
            await MarkSessionVerifiedAsync(conn, tx, userId, sessionId.Value, "phone", ct);
        }
        catch (PostgresException ex) when (ex.SqlState == PostgresErrorCodes.UniqueViolation)
        {
            return ex.ConstraintName == "phone_verifications_pkey" ? PhoneAlreadyVerified : PhoneInUse;
        }
        catch (PostgresException ex) when (ex.SqlState == PostgresErrorCodes.ForeignKeyViolation)
        {
            return NoSession;
        }
        await AuditLog.AppendAsync(conn, tx, new AuditEntry(userId, AuditActor.User, "security.phone_verified", "user",
            userId.ToString(), new { country = phone.Country }), ct);

        var result = ToStatus(await ReadStateAsync(conn, tx, userId, sessionId, ct));
        await tx.CommitAsync(ct);
        return result;
    }

    public async Task<Result> StartSecondFactorAsync(Guid userId, CancellationToken ct)
    {
        if (!sms.IsConfigured) return SmsErrors.NotConfigured;
        await using var conn = await db.OpenConnectionAsync(ct);
        var state = await ReadStateAsync(conn, null, userId, null, ct);
        if (Precondition(state) is { } error) return error;
        if (state.Phone is null) return PhoneRequired;
        return await SendAsync(userId, state.Phone, state.AllowedCountry!, "second_factor", ct);
    }

    public async Task<Result<SecurityStatus>> VerifySecondFactorAsync(
        Guid userId, Guid? sessionId, SecondFactorRequest body, CancellationToken ct)
    {
        ArgumentNullException.ThrowIfNull(body);
        if (sessionId is null) return NoSession;
        var code = body.Code?.Trim() ?? "";

        await using var conn = await db.OpenConnectionAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);
        var state = await ReadStateAsync(conn, tx, userId, sessionId, ct);
        if (Precondition(state) is { } error) return error;
        if (state.Phone is null) return PhoneRequired;

        switch (body.Method)
        {
            case "sms":
                if (!sms.IsConfigured) return SmsErrors.NotConfigured;
                var approved = await sms.CheckAsync(state.Phone, code, ct);
                if (!approved.IsSuccess) return approved.Error;
                if (!approved.Value) return CodeInvalid;
                break;
            case "totp":
                if (!await AcceptTotpAsync(conn, tx, userId, code, confirmedOnly: true, ct)) return CodeInvalid;
                break;
            default:
                return Error.Validation("security.method_invalid", "Geçersiz doğrulama yöntemi.");
        }

        try
        {
            await MarkSessionVerifiedAsync(conn, tx, userId, sessionId.Value, body.Method, ct);
        }
        catch (PostgresException ex) when (ex.SqlState == PostgresErrorCodes.ForeignKeyViolation)
        {
            return NoSession;
        }
        var result = ToStatus(await ReadStateAsync(conn, tx, userId, sessionId, ct));
        await tx.CommitAsync(ct);
        return result;
    }

    /// <summary>Starts (or restarts) authenticator setup. The secret is shown once, here.</summary>
    public async Task<Result<TotpSetup>> BeginTotpAsync(Guid userId, Guid? sessionId, CancellationToken ct)
    {
        await using var conn = await db.OpenConnectionAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);
        var state = await ReadStateAsync(conn, tx, userId, sessionId, ct);
        if (state.Enforce && !state.SessionVerified) return SessionUnverified;
        if (state.Totp) return Error.Conflict("security.totp_exists", "Doğrulama uygulaman zaten kurulu.");

        var secret = Totp.NewSecret();
        await ExecuteAsync(conn, tx,
            """
            insert into public.totp_factors (user_id, secret) values (@u, @secret)
            on conflict (user_id) do update set secret = excluded.secret, confirmed_at = null, last_step = null, created_at = now()
            """, ct, ("u", userId), ("secret", secret));
        await tx.CommitAsync(ct);
        var base32 = Totp.Base32(secret);
        return new TotpSetup(base32, Totp.SetupUri(base32));
    }

    public async Task<Result> ConfirmTotpAsync(Guid userId, TotpCodeRequest body, CancellationToken ct)
    {
        ArgumentNullException.ThrowIfNull(body);
        await using var conn = await db.OpenConnectionAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);
        if (!await AcceptTotpAsync(conn, tx, userId, body.Code?.Trim() ?? "", confirmedOnly: false, ct)) return CodeInvalid;
        await ExecuteAsync(conn, tx, "update public.totp_factors set confirmed_at = now() where user_id = @u", ct, ("u", userId));
        await AuditLog.AppendAsync(conn, tx, new AuditEntry(userId, AuditActor.User, "security.totp_enabled", "user", userId.ToString()), ct);
        await tx.CommitAsync(ct);
        return Result.Success();
    }

    public async Task<Result> DeleteTotpAsync(Guid userId, Guid? sessionId, CancellationToken ct)
    {
        await using var conn = await db.OpenConnectionAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);
        var state = await ReadStateAsync(conn, tx, userId, sessionId, ct);
        if (state.Enforce && !state.SessionVerified) return SessionUnverified;
        await using (var cmd = new NpgsqlCommand("delete from public.totp_factors where user_id = @u", conn, tx))
        {
            cmd.Parameters.AddWithValue("u", userId);
            if (await cmd.ExecuteNonQueryAsync(ct) == 0)
                return Error.NotFound("security.totp_not_found", "Kurulu bir doğrulama uygulaman yok.");
        }
        await AuditLog.AppendAsync(conn, tx, new AuditEntry(userId, AuditActor.User, "security.totp_disabled", "user", userId.ToString()), ct);
        await tx.CommitAsync(ct);
        return Result.Success();
    }

    /// <summary>Deletes location checks and SMS records older than the retention period (§3h, Veri ve erişim).</summary>
    public async Task<int> PurgeExpiredAsync(CancellationToken ct)
    {
        await using var cmd = db.CreateCommand(
            $"""
            with checks as (delete from public.location_checks where checked_at < now() - interval '{RetentionDays} days' returning 1),
                 sends as (delete from public.sms_sends where sent_at < now() - interval '{RetentionDays} days' returning 1)
            select (select count(*) from checks) + (select count(*) from sends)
            """);
        return (int)(long)(await cmd.ExecuteScalarAsync(ct))!;
    }

    /// <summary>
    /// Bans inside the caller's transaction: suspension (Auth ban, sessions ended), the account's numbers on the
    /// ban list, the open review closed. <paramref name="actorId"/> null means the system decided.
    /// </summary>
    internal static async Task BanAsync(
        NpgsqlConnection conn, NpgsqlTransaction tx, Guid userId, string[] signals, string? attemptedPhone,
        long? checkId, Guid? actorId, CancellationToken ct, string? note = null)
    {
        // A pending deletion goes ahead; the numbers are still banned.
        var status = await ScalarAsync<string>(conn, tx, "select status from public.account_status where user_id = @u for update", ("u", userId), ct);
        if (status != "pending_deletion") await AccountService.ApplySuspensionAsync(conn, tx, userId, BanReason, null, ct);

        await ExecuteAsync(conn, tx,
            """
            insert into public.user_security (user_id, state) values (@u, 'restricted')
            on conflict (user_id) do update set state = 'restricted', exempt_until = null, updated_at = now();

            insert into public.phone_bans (phone, user_id, reason)
            select p.phone, @u, @reason from (
              select phone from public.phone_verifications where user_id = @u
              union select @attempted::text where @attempted::text is not null
            ) p
            on conflict (phone) do nothing;

            insert into public.security_reviews (user_id, signals, check_id, status, resolved_at, resolved_by, note)
            values (@u, @signals, @check, 'banned', now(), @actor, @note)
            on conflict (user_id) where status = 'open'
            do update set status = 'banned', resolved_at = now(), resolved_by = @actor, note = @note,
                          signals = array(select distinct unnest(security_reviews.signals || excluded.signals));
            """, ct, ("u", userId), ("reason", BanReason), ("attempted", (object?)attemptedPhone ?? DBNull.Value),
            ("signals", signals), ("check", checkId is { } c ? c : DBNull.Value), ("actor", actorId is { } a ? a : DBNull.Value),
            ("note", (object?)note ?? DBNull.Value));

        await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, actorId is null ? AuditActor.System : AuditActor.Staff,
            actorId is null ? "security.banned" : "security.review_banned", "user", userId.ToString(), new { signals, note }), ct);
    }

    private static async Task RestrictAsync(
        NpgsqlConnection conn, NpgsqlTransaction tx, Guid userId, string currentState, string[] signals, long? checkId, CancellationToken ct)
    {
        await ExecuteAsync(conn, tx,
            """
            update public.user_security set state = 'restricted', updated_at = now() where user_id = @u;

            insert into public.security_reviews (user_id, signals, check_id) values (@u, @signals, @check)
            on conflict (user_id) where status = 'open'
            do update set signals = array(select distinct unnest(security_reviews.signals || excluded.signals)),
                          check_id = excluded.check_id;
            """, ct, ("u", userId), ("signals", signals), ("check", checkId is { } c ? c : DBNull.Value));

        if (currentState != "restricted")
        {
            await AuditLog.AppendAsync(conn, tx, new AuditEntry(null, AuditActor.System, "security.restricted", "user",
                userId.ToString(), new { signals }), ct);
        }
    }

    /// <summary>
    /// The checks shared by starting and finishing phone verification. A number from outside the allowed country
    /// can only come from a modified app (the app locks the prefix), and a banned number from a banned person:
    /// both ban the account (staff are restricted instead).
    /// </summary>
    private async Task<Result<(ParsedPhone Phone, string Allowed)>> CheckNewPhoneAsync(Guid userId, string? input, CancellationToken ct)
    {
        await using var conn = await db.OpenConnectionAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);
        var state = await ReadStateAsync(conn, tx, userId, null, ct);
        if (Precondition(state) is { } error) return error;
        if (state.Phone is not null) return PhoneAlreadyVerified;

        var parsed = PhoneRules.Parse(input, state.AllowedCountry!);
        if (!parsed.IsSuccess) return parsed.Error;
        var phone = parsed.Value;

        var hard = phone.Country != state.AllowedCountry ? SecuritySignals.ForeignPhone
            : await ScalarAsync<string>(conn, tx, "select phone from public.phone_bans where phone = @p", ("p", phone.E164), ct) is not null
                ? SecuritySignals.BannedPhone
                : null;
        if (hard is not null)
        {
            if (await IsStaffAsync(conn, tx, userId, ct))
            {
                await RestrictAsync(conn, tx, userId, state.State, [hard], null, ct);
                await tx.CommitAsync(ct);
                return Restricted;
            }
            await BanAsync(conn, tx, userId, [hard], phone.E164, null, null, ct);
            await tx.CommitAsync(ct);
            return Banned;
        }

        var owner = await ScalarAsync<Guid?>(conn, tx, "select user_id from public.phone_verifications where phone = @p", ("p", phone.E164), ct);
        if (owner is { } other && other != userId) return PhoneInUse;
        return (phone, state.AllowedCountry!);
    }

    private async Task<Result> SendAsync(Guid userId, string phone, string country, string purpose, CancellationToken ct)
    {
        await using var conn = await db.OpenConnectionAsync(ct);
        await using (var cmd = new NpgsqlCommand(
            """
            select count(*) filter (where user_id = @u and sent_at > now() - interval '1 hour'),
                   count(*) filter (where user_id = @u),
                   count(*) filter (where phone = @p and sent_at > now() - interval '1 hour')
            from public.sms_sends
            where sent_at > now() - interval '1 day' and (user_id = @u or phone = @p)
            """, conn))
        {
            cmd.Parameters.AddWithValue("u", userId);
            cmd.Parameters.AddWithValue("p", phone);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            await r.ReadAsync(ct);
            if (r.GetInt64(0) >= SmsPerUserHour || r.GetInt64(1) >= SmsPerUserDay || r.GetInt64(2) >= SmsPerPhoneHour)
                return SmsErrors.RateLimited;
        }

        var sent = await sms.SendAsync(phone, country == "TR" ? "tr" : "en", ct);
        if (!sent.IsSuccess) return sent;

        await using (var cmd = new NpgsqlCommand(
            "insert into public.sms_sends (user_id, phone, purpose) values (@u, @p, @purpose)", conn))
        {
            cmd.Parameters.AddWithValue("u", userId);
            cmd.Parameters.AddWithValue("p", phone);
            cmd.Parameters.AddWithValue("purpose", purpose);
            await cmd.ExecuteNonQueryAsync(ct);
        }
        return Result.Success();
    }

    /// <summary>Accepts a code once: the matched step is stored, older and equal steps are refused afterwards.</summary>
    private async Task<bool> AcceptTotpAsync(
        NpgsqlConnection conn, NpgsqlTransaction tx, Guid userId, string code, bool confirmedOnly, CancellationToken ct)
    {
        byte[] secret;
        long? lastStep;
        await using (var cmd = new NpgsqlCommand(
            $"""
            select secret, last_step from public.totp_factors
            where user_id = @u and confirmed_at is {(confirmedOnly ? "not null" : "null")}
            for update
            """, conn, tx))
        {
            cmd.Parameters.AddWithValue("u", userId);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            if (!await r.ReadAsync(ct)) return false;
            secret = (byte[])r[0];
            lastStep = r.IsDBNull(1) ? null : r.GetInt64(1);
        }
        if (Totp.Verify(secret, code, time.GetUtcNow(), lastStep) is not { } step) return false;
        await ExecuteAsync(conn, tx, "update public.totp_factors set last_step = @s where user_id = @u", ct, ("u", userId), ("s", step));
        return true;
    }

    private static async Task MarkSessionVerifiedAsync(
        NpgsqlConnection conn, NpgsqlTransaction tx, Guid userId, Guid sessionId, string method, CancellationToken ct) =>
        await ExecuteAsync(conn, tx,
            """
            insert into public.verified_sessions (session_id, user_id, method) values (@s, @u, @m)
            on conflict (session_id) do nothing
            """, ct, ("s", sessionId), ("u", userId), ("m", method));

    /// <summary>A restricted account or a stale location stops every phone step.</summary>
    private static Error? Precondition(UserState state) =>
        state.State == "restricted" ? Restricted
        : !state.LocationFresh || state.AllowedCountry is null ? LocationRequired
        : null;

    private static SecurityStatus ToStatus(UserState s)
    {
        var step = !s.Enforce ? SecuritySteps.Done
            : s.State == "restricted" ? SecuritySteps.Restricted
            : !s.LocationFresh ? SecuritySteps.Location
            : s.Phone is null ? SecuritySteps.Phone
            : !s.SessionVerified ? SecuritySteps.SecondFactor
            : SecuritySteps.Done;
        return new SecurityStatus(
            s.Enforce,
            s.SessionVerified,
            step,
            s.AllowedCountry,
            s.AllowedCountry is { } c ? PhoneRules.CallingCode(c) : null,
            s.Phone is { } p ? PhoneRules.Mask(p) : null,
            s.Totp);
    }

    private static async Task<UserState> ReadStateAsync(
        NpgsqlConnection conn, NpgsqlTransaction? tx, Guid userId, Guid? sessionId, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand(
            """
            select s.enforce,
                   coalesce(us.state, 'ok'),
                   us.allowed_country,
                   coalesce(us.location_checked_at > now() - interval '24 hours', false),
                   pv.phone,
                   tf.confirmed_at is not null,
                   private.is_session_verified(@u, @s)
            from public.security_settings s
            left join public.user_security us on us.user_id = @u
            left join public.phone_verifications pv on pv.user_id = @u
            left join public.totp_factors tf on tf.user_id = @u
            """, conn, tx);
        cmd.Parameters.AddWithValue("u", userId);
        cmd.Parameters.AddWithValue("s", NpgsqlDbType.Uuid, sessionId is { } sid ? sid : DBNull.Value);
        await using var r = await cmd.ExecuteReaderAsync(ct);
        await r.ReadAsync(ct);
        return new UserState(
            r.GetBoolean(0), r.GetString(1), r.IsDBNull(2) ? null : r.GetString(2), r.GetBoolean(3),
            r.IsDBNull(4) ? null : r.GetString(4), r.GetBoolean(5), r.GetBoolean(6));
    }

    /// <summary>Creates the row on first use and locks it; returns the state and whether an exemption is running.</summary>
    private static async Task<(string State, bool Exempt)> LockUserSecurityAsync(
        NpgsqlConnection conn, NpgsqlTransaction tx, Guid userId, CancellationToken ct)
    {
        await ExecuteAsync(conn, tx, "insert into public.user_security (user_id) values (@u) on conflict do nothing", ct, ("u", userId));
        await using var cmd = new NpgsqlCommand(
            "select state, coalesce(exempt_until > now(), false) from public.user_security where user_id = @u for update", conn, tx);
        cmd.Parameters.AddWithValue("u", userId);
        await using var r = await cmd.ExecuteReaderAsync(ct);
        await r.ReadAsync(ct);
        return (r.GetString(0), r.GetBoolean(1));
    }

    /// <summary>Platform staff are never banned automatically (§3h); reads the admin module's table, read only.</summary>
    internal static async Task<bool> IsStaffAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid userId, CancellationToken ct) =>
        await ScalarAsync<int?>(conn, tx, "select 1 from public.platform_staff where user_id = @u", ("u", userId), ct) is not null;

    internal static async Task<T?> ScalarAsync<T>(
        NpgsqlConnection conn, NpgsqlTransaction? tx, string sql, (string Name, object Value) parameter, CancellationToken ct)
    {
#pragma warning disable CA2100 // sql is a constant from this class
        await using var cmd = new NpgsqlCommand(sql, conn, tx);
#pragma warning restore CA2100
        cmd.Parameters.AddWithValue(parameter.Name, parameter.Value);
        var value = await cmd.ExecuteScalarAsync(ct);
        return value is null or DBNull ? default : (T)value;
    }

    internal static async Task ExecuteAsync(
        NpgsqlConnection conn, NpgsqlTransaction tx, string sql, CancellationToken ct, params (string Name, object Value)[] parameters)
    {
#pragma warning disable CA2100 // sql is a constant from this class
        await using var cmd = new NpgsqlCommand(sql, conn, tx);
#pragma warning restore CA2100
        foreach (var (name, value) in parameters) cmd.Parameters.AddWithValue(name, value);
        await cmd.ExecuteNonQueryAsync(ct);
    }
}
