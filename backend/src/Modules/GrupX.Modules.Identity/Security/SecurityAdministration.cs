using GrupX.Modules.Identity.Contracts;
using GrupX.SharedKernel;
using GrupX.SharedKernel.Auditing;
using Microsoft.Extensions.Options;
using Npgsql;
using NpgsqlTypes;

namespace GrupX.Modules.Identity;

/// <summary>Staff side of security verification: the enforcement switch and reviews (docs/ARCHITECTURE.md §3h).</summary>
internal sealed class SecurityAdministration(NpgsqlDataSource db, ISmsVerifier sms, IOptions<SecurityOptions> options)
    : ISecurityAdministration
{
    public const int MaxExemptDays = 90;
    private const int PageSize = 50;
    private const int MaxNoteLength = 1000;

    private static readonly HashSet<string> Statuses = ["open", "approved", "banned"];

    private static readonly Error ReviewNotFound = Error.NotFound("security.review_not_found", "İnceleme bulunamadı.");

    private static readonly Error ReviewClosed = Error.Conflict("security.review_closed", "Bu inceleme zaten sonuçlandırıldı.");

    private const string CheckColumns =
        "c.checked_at, c.platform, c.gps_country, c.ip_country, c.sim_country, c.phone_country, c.is_mocked, c.vpn, c.vpn_apps, c.signals, c.verdict";

    public async Task<SecuritySettingsView> GetSettingsAsync(CancellationToken ct)
    {
        await using var cmd = db.CreateCommand(
            "select enforce, detect_vpn, warn_installed_vpn, detect_phone_mismatch, updated_at from public.security_settings");
        await using var r = await cmd.ExecuteReaderAsync(ct);
        await r.ReadAsync(ct);
        return new SecuritySettingsView(r.GetBoolean(0), r.GetBoolean(1), r.GetBoolean(2), r.GetBoolean(3),
            sms.IsConfigured, options.Value.Twilio.LookupLineType && sms.IsConfigured, r.GetFieldValue<DateTimeOffset>(4));
    }

    public async Task<Result<SecuritySettingsView>> UpdateSettingsAsync(Guid actorId, SecuritySettingsRequest body, CancellationToken ct)
    {
        ArgumentNullException.ThrowIfNull(body);
        // Without SMS nobody could finish verification: everyone would be locked out.
        if (body.Enforce == true && !sms.IsConfigured) return SmsErrors.NotConfigured;

        await using (var conn = await db.OpenConnectionAsync(ct))
        await using (var tx = await conn.BeginTransactionAsync(ct))
        {
            await using (var cmd = new NpgsqlCommand(
                """
                update public.security_settings
                set enforce = coalesce(@enforce, enforce),
                    detect_vpn = coalesce(@vpn, detect_vpn),
                    warn_installed_vpn = coalesce(@installed, warn_installed_vpn),
                    detect_phone_mismatch = coalesce(@phone, detect_phone_mismatch),
                    updated_at = now(), updated_by = @a
                """, conn, tx))
            {
                cmd.Parameters.AddWithValue("enforce", NpgsqlDbType.Boolean, (object?)body.Enforce ?? DBNull.Value);
                cmd.Parameters.AddWithValue("vpn", NpgsqlDbType.Boolean, (object?)body.DetectVpn ?? DBNull.Value);
                cmd.Parameters.AddWithValue("installed", NpgsqlDbType.Boolean, (object?)body.WarnInstalledVpn ?? DBNull.Value);
                cmd.Parameters.AddWithValue("phone", NpgsqlDbType.Boolean, (object?)body.DetectPhoneMismatch ?? DBNull.Value);
                cmd.Parameters.AddWithValue("a", actorId);
                await cmd.ExecuteNonQueryAsync(ct);
            }
            await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.Staff, "security.settings_changed",
                "security_settings", null, body), ct);
            await tx.CommitAsync(ct);
        }
        return await GetSettingsAsync(ct);
    }

    public async Task<Result<IReadOnlyList<SecurityReviewItem>>> ListReviewsAsync(string? status, int page, CancellationToken ct)
    {
        if (status is not null && !Statuses.Contains(status))
            return Error.Validation("security.status_invalid", "Geçersiz inceleme durumu.");

        await using var cmd = db.CreateCommand(
            $"""
            select r.id, r.user_id, p.username, p.display_name, r.signals, r.status, r.opened_at, r.resolved_at, r.note,
                   c.id is not null, {CheckColumns}
            from public.security_reviews r
            left join public.profiles p on p.id = r.user_id
            left join public.location_checks c on c.id = r.check_id
            where (@status::text is null or r.status = @status::text)
            order by r.opened_at desc
            limit {PageSize} offset @offset
            """);
        cmd.Parameters.AddWithValue("status", NpgsqlDbType.Text, (object?)status ?? DBNull.Value);
        cmd.Parameters.AddWithValue("offset", Math.Max(0, page - 1) * PageSize);
        await using var r = await cmd.ExecuteReaderAsync(ct);
        var items = new List<SecurityReviewItem>();
        while (await r.ReadAsync(ct))
        {
            items.Add(new SecurityReviewItem(
                r.GetGuid(0), r.GetGuid(1), r.IsDBNull(2) ? null : r.GetString(2), r.IsDBNull(3) ? null : r.GetString(3),
                r.GetFieldValue<string[]>(4), r.GetString(5), r.GetFieldValue<DateTimeOffset>(6),
                r.IsDBNull(7) ? null : r.GetFieldValue<DateTimeOffset>(7), r.IsDBNull(8) ? null : r.GetString(8),
                r.GetBoolean(9) ? ReadCheck(r, 10) : null));
        }
        return items;
    }

    public async Task<Result> ApproveAsync(Guid actorId, Guid reviewId, ReviewApprovalRequest body, CancellationToken ct)
    {
        ArgumentNullException.ThrowIfNull(body);
        var days = body.ExemptDays ?? 0;
        if (days is < 0 or > MaxExemptDays)
            return Error.Validation("security.exempt_days", $"Muafiyet 0–{MaxExemptDays} gün olabilir.");
        if (ValidateNote(body.Note) is { } invalid) return invalid;

        await using var conn = await db.OpenConnectionAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);
        var review = await LockOpenReviewAsync(conn, tx, reviewId, ct);
        if (!review.IsSuccess) return review.Error;
        var userId = review.Value;

        await SecurityService.ExecuteAsync(conn, tx,
            """
            update public.security_reviews
            set status = 'approved', resolved_at = now(), resolved_by = @a, note = @note
            where id = @id;

            update public.user_security
            set state = 'ok',
                exempt_until = case when @days > 0 then now() + make_interval(days => @days) else exempt_until end,
                updated_at = now()
            where user_id = @u;
            """, ct, ("id", reviewId), ("a", actorId), ("note", (object?)body.Note?.Trim() ?? DBNull.Value), ("days", days), ("u", userId));
        await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.Staff, "security.review_approved", "user",
            userId.ToString(), new { reviewId, exemptDays = days, note = body.Note?.Trim() }), ct);
        await tx.CommitAsync(ct);
        return Result.Success();
    }

    public async Task<Result> BanAsync(Guid actorId, Guid reviewId, ReviewBanRequest body, CancellationToken ct)
    {
        ArgumentNullException.ThrowIfNull(body);
        if (ValidateNote(body.Note) is { } invalid) return invalid;

        await using var conn = await db.OpenConnectionAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);
        var review = await LockOpenReviewAsync(conn, tx, reviewId, ct);
        if (!review.IsSuccess) return review.Error;
        var userId = review.Value;
        if (await SecurityService.IsStaffAsync(conn, tx, userId, ct))
            return Error.RuleViolation("security.cannot_ban_staff", "Platform ekibi üyeleri banlanamaz.");

        var signals = await SecurityService.ScalarAsync<string[]>(conn, tx,
            "select signals from public.security_reviews where id = @id", ("id", reviewId), ct) ?? [];
        await SecurityService.BanAsync(conn, tx, userId, signals, null, null, actorId, ct, body.Note?.Trim());
        await tx.CommitAsync(ct);
        return Result.Success();
    }

    public async Task<Result<UserSecurityView>> GetUserAsync(Guid userId, CancellationToken ct)
    {
        await using var conn = await db.OpenConnectionAsync(ct);
        UserSecurityView? view = null;
        await using (var cmd = new NpgsqlCommand(
            """
            select coalesce(us.state, 'ok'), pv.phone, pv.country, pv.verified_at, tf.confirmed_at is not null,
                   us.allowed_country, us.location_checked_at, us.exempt_until,
                   (select count(*)::int from public.passkeys k where k.user_id = u.id),
                   coalesce(us.review_exempt, false)
            from auth.users u
            left join public.user_security us on us.user_id = u.id
            left join public.phone_verifications pv on pv.user_id = u.id
            left join public.totp_factors tf on tf.user_id = u.id
            where u.id = @u
            """, conn))
        {
            cmd.Parameters.AddWithValue("u", userId);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            if (!await r.ReadAsync(ct)) return Error.NotFound("account.not_found", "Hesap bulunamadı.");
            view = new UserSecurityView(
                r.GetString(0), r.IsDBNull(1) ? null : PhoneRules.Mask(r.GetString(1)), r.IsDBNull(2) ? null : r.GetString(2),
                r.IsDBNull(3) ? null : r.GetFieldValue<DateTimeOffset>(3), r.GetBoolean(4), r.GetInt32(8), r.IsDBNull(5) ? null : r.GetString(5),
                r.IsDBNull(6) ? null : r.GetFieldValue<DateTimeOffset>(6), r.IsDBNull(7) ? null : r.GetFieldValue<DateTimeOffset>(7),
                r.GetBoolean(9), []);
        }

        var checks = new List<LocationCheckView>();
        await using (var cmd = new NpgsqlCommand(
            $"select {CheckColumns} from public.location_checks c where c.user_id = @u order by c.checked_at desc limit 20", conn))
        {
            cmd.Parameters.AddWithValue("u", userId);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            while (await r.ReadAsync(ct)) checks.Add(ReadCheck(r, 0));
        }
        return view with { Checks = checks };
    }

    public async Task<Result> SetReviewExemptAsync(Guid actorId, Guid userId, ReviewExemptRequest body, CancellationToken ct)
    {
        ArgumentNullException.ThrowIfNull(body);
        var note = body.Note?.Trim() ?? "";
        if (note.Length is < 3 or > 500)
            return Error.Validation("security.review_exempt_note", "Gerekçe 3–500 karakter olmalı.");

        await using var conn = await db.OpenConnectionAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);
        if (await SecurityService.ScalarAsync<Guid?>(conn, tx, "select id from auth.users where id = @u", ("u", userId), ct) is null)
            return Error.NotFound("account.not_found", "Hesap bulunamadı.");
        await SecurityService.ExecuteAsync(conn, tx,
            """
            insert into public.user_security (user_id, review_exempt) values (@u, @e)
            on conflict (user_id) do update set review_exempt = excluded.review_exempt, updated_at = now()
            """, ct, ("u", userId), ("e", body.Exempt));
        await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.Staff, "security.review_exempt_changed", "user",
            userId.ToString(), new { exempt = body.Exempt, note }), ct);
        await tx.CommitAsync(ct);
        return Result.Success();
    }

    private static async Task<Result<Guid>> LockOpenReviewAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid reviewId, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand("select user_id, status from public.security_reviews where id = @id for update", conn, tx);
        cmd.Parameters.AddWithValue("id", reviewId);
        await using var r = await cmd.ExecuteReaderAsync(ct);
        if (!await r.ReadAsync(ct)) return ReviewNotFound;
        return r.GetString(1) == "open" ? r.GetGuid(0) : ReviewClosed;
    }

    private static Error? ValidateNote(string? note) =>
        note?.Trim().Length > MaxNoteLength ? Error.Validation("security.note_too_long", $"Not en fazla {MaxNoteLength} karakter olabilir.") : null;

    private static LocationCheckView ReadCheck(NpgsqlDataReader r, int o) => new(
        r.GetFieldValue<DateTimeOffset>(o), r.GetString(o + 1),
        r.IsDBNull(o + 2) ? null : r.GetString(o + 2), r.IsDBNull(o + 3) ? null : r.GetString(o + 3),
        r.IsDBNull(o + 4) ? null : r.GetString(o + 4), r.IsDBNull(o + 5) ? null : r.GetString(o + 5),
        r.GetBoolean(o + 6), r.GetBoolean(o + 7), r.GetFieldValue<string[]>(o + 8), r.GetFieldValue<string[]>(o + 9),
        r.GetString(o + 10));
}
