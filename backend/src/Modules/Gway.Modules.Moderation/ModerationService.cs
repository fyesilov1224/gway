using System.Security.Claims;
using Gway.Modules.Feed.Contracts;
using Gway.Modules.Groups.Contracts;
using Gway.Modules.Identity.Contracts;
using Gway.Modules.Live.Contracts;
using Gway.Modules.Messaging.Contracts;
using Gway.Modules.Moderation.Contracts;
using Gway.SharedKernel;
using Gway.SharedKernel.Auditing;
using Gway.SharedKernel.Database;
using Gway.SharedKernel.Http;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Npgsql;

namespace Gway.Modules.Moderation;

public sealed record RemoveReportedRequest(string Reason);

/// <param name="IllegalCategory">Marks a ban case as illegal activity; once approved it goes to the platform team (§3e).</param>
public sealed record OpenCaseRequest(
    Guid SubjectId, string? Sanction, int? DurationDays, string? Reason, Guid? ReportId, bool MuteNow, string? IllegalCategory = null);

public sealed record CreatedCase(Guid Id);

public sealed record CaseVoteRequest(bool Approve);

/// <summary>The case after the vote: <c>voting</c>, <c>approved</c> or <c>rejected</c>.</summary>
public sealed record CaseVoteResult(string Status);

public sealed record AppealDecisionRequest(bool Overturn, string? Note);

public static class ModerationModule
{
    public static IServiceCollection AddModerationModule(this IServiceCollection services)
    {
        services.AddSingleton<ModerationService>();
        services.AddSingleton<IModerationAdministration>(sp => sp.GetRequiredService<ModerationService>());
        services.AddHostedService<ModerationMonitor>();
        return services;
    }

    /// <summary>Group moderation (docs/ARCHITECTURE.md §3e). Reports and appeals are written through Supabase.</summary>
    public static IEndpointRouteBuilder MapModerationEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapPost("/reports/{id:guid}/dismissal", async (Guid id, ClaimsPrincipal user, ModerationService moderation, CancellationToken ct) =>
            (await moderation.DismissAsync(user.GetUserId(), id, ct)).ToHttpResult());

        app.MapPost("/reports/{id:guid}/removal", async (
                Guid id, RemoveReportedRequest body, ClaimsPrincipal user, ModerationService moderation, CancellationToken ct) =>
            (await moderation.RemoveContentAsync(user.GetUserId(), id, body.Reason, ct)).ToHttpResult());

        app.MapPost("/groups/{id:guid}/cases", async (Guid id, OpenCaseRequest body, ClaimsPrincipal user, ModerationService moderation, CancellationToken ct) =>
            (await moderation.OpenCaseAsync(user.GetUserId(), id, body, ct)).ToHttpResult());

        app.MapPut("/cases/{id:guid}/vote", async (Guid id, CaseVoteRequest body, ClaimsPrincipal user, ModerationService moderation, CancellationToken ct) =>
            (await moderation.VoteAsync(user.GetUserId(), id, body.Approve, ct)).ToHttpResult());

        app.MapPost("/appeals/{id:guid}/decision", async (
                Guid id, AppealDecisionRequest body, ClaimsPrincipal user, ModerationService moderation, CancellationToken ct) =>
            (await moderation.DecideAppealAsOwnerAsync(user.GetUserId(), id, body.Overturn, body.Note, ct)).ToHttpResult());

        return app;
    }
}

/// <summary>Pre-review, cases, votes, sanctions and appeal decisions; the triggers re-check every rule.</summary>
internal sealed partial class ModerationService(
    NpgsqlDataSource db, IGroupMembership membership, IFeedModeration feed, ILiveModeration live, IMessagingModeration messages,
    IAccountSanctions accounts, ILogger<ModerationService> log)
    : IModerationAdministration
{
    public static readonly string[] Sanctions = ["warning", "mute", "kick", "ban"];

    /// <summary>What counts as illegal activity (docs/ARCHITECTURE.md §3e, Yasa dışı faaliyet).</summary>
    public static readonly string[] IllegalCategories = ["violence", "threat", "insult", "hate", "sexual", "fraud", "drugs", "terror", "other_crime"];

    /// <summary>Shown to the person while the platform team reviews the referral.</summary>
    public const string ReviewSuspensionReason = "Yasa dışı faaliyet bildirimi platform ekibince inceleniyor.";

    private static readonly Error ReportNotFound = Error.NotFound("report.not_found", "Şikayet bulunamadı.");
    private static readonly Error ReportReviewed = Error.Conflict("report.reviewed", "Bu şikayet zaten incelendi.");
    private static readonly Error CaseNotFound = Error.NotFound("case.not_found", "Dosya bulunamadı.");
    private static readonly Error AppealNotFound = Error.NotFound("appeal.not_found", "İtiraz bulunamadı.");
    private static readonly Error Forbidden = Error.Forbidden("moderation.forbidden", "Bu grupta bu işlem için yetkin yok.");
    private static readonly Error RankViolation = Error.RuleViolation(
        "moderation.rank_violation", "Kendinle eşit ya da senden yüksek rütbeli birine bu işlemi uygulayamazsın.");
    private static readonly Error BoardRank = Error.RuleViolation(
        "moderation.board_rank", "Disiplin kurulu, kendisiyle eşit ya da daha yüksek rütbeli birine karar veremez. Önce kişinin rolünü almalısın.");

    private static Error RuleError(string code) => code switch
    {
        "rank_violation" => RankViolation,
        "case_forbidden" or "report_review_forbidden" or "sanction_forbidden" or "vote_forbidden" or "appeal_forbidden"
            or "comment_immutable" or "live_forbidden" => Forbidden,
        "subject_not_member" => Error.NotFound("case.subject_not_member", "Bu kişi grubun üyesi değil."),
        _ => Error.RuleViolation($"moderation.{code}", "Bu işlem şu anda yapılamıyor. Sayfayı yenileyip tekrar dene."),
    };

    private sealed record ReportRow(Guid Id, Guid? GroupId, string TargetType, string TargetId, Guid? SubjectId, string Status);

    private static async Task<ReportRow?> LoadReportAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid id, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand(
            "select id, group_id, target_type, target_id, subject_id, status from public.reports where id = @id for update", conn, tx);
        cmd.Parameters.AddWithValue("id", id);
        await using var r = await cmd.ExecuteReaderAsync(ct);
        return await r.ReadAsync(ct)
            ? new ReportRow(r.GetGuid(0), r.IsDBNull(1) ? null : r.GetGuid(1), r.GetString(2), r.GetString(3),
                r.IsDBNull(4) ? null : r.GetGuid(4), r.GetString(5))
            : null;
    }

    /// <summary>Closes every open report of the same target in the same scope; returns how many.</summary>
    private static Task<int> CloseReportsAsync(NpgsqlConnection conn, NpgsqlTransaction tx, ReportRow report, string status, Guid? caseId, CancellationToken ct) =>
        ActingTransaction.ExecuteAsync(conn, tx,
            """
            update public.reports set status = @status, case_id = @case
            where status = 'open' and target_type = @type and target_id = @target and group_id is not distinct from @group
            """, ct, ("status", status), ("case", caseId), ("type", report.TargetType), ("target", report.TargetId), ("group", report.GroupId));

    private static async Task<bool> HasPermissionAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid actor, Guid groupId, string permission, CancellationToken ct) =>
        await ActingTransaction.ScalarAsync(conn, tx, "select private.user_has_group_permission(@a, @g, @p)", ct,
            ("a", actor), ("g", groupId), ("p", permission)) is true;

    private static async Task<int> RankAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid groupId, Guid userId, CancellationToken ct) =>
        (int)(await ActingTransaction.ScalarAsync(conn, tx, "select private.group_rank(@g, @u)", ct, ("g", groupId), ("u", userId)))!;

    private static Task AuditAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid? actor, string actorKind, string action, string type, Guid target,
        Guid? groupId, object? data, CancellationToken ct) =>
        AuditLog.AppendAsync(conn, tx, new AuditEntry(actor, actorKind, action, type, target.ToString(), data, groupId), ct);

    // Pre-review ---------------------------------------------------------------------------------

    /// <summary>The group's open report the actor may review; platform reports belong to the platform team.</summary>
    private static async Task<Result<ReportRow>> ReviewableAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid actor, Guid id, CancellationToken ct)
    {
        var report = await LoadReportAsync(conn, tx, id, ct);
        if (report is null) return ReportNotFound;
        if (report.GroupId is not { } groupId || !await HasPermissionAsync(conn, tx, actor, groupId, "reports.review", ct)) return Forbidden;
        return report.Status == "open" ? report : ReportReviewed;
    }

    public Task<Result> DismissAsync(Guid actor, Guid id, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            var loaded = await ReviewableAsync(conn, tx, actor, id, ct);
            if (!loaded.IsSuccess) return loaded.Error;
            var report = loaded.Value;
            var closed = await CloseReportsAsync(conn, tx, report, "dismissed", null, ct);
            await AuditAsync(conn, tx, actor, AuditActor.User, "report.dismissed", "report", id, report.GroupId,
                new { report.TargetType, report.TargetId, reports = closed }, ct);
            return Result.Success();
        }, RuleError, ct);

    public Task<Result> RemoveContentAsync(Guid actor, Guid id, string reason, CancellationToken ct)
    {
        reason = reason?.Trim() ?? "";
        if (reason.Length is < 3 or > 500)
            return Task.FromResult<Result>(Error.Validation("report.invalid_reason", "Gerekçe 3–500 karakter olmalı."));

        return ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            var loaded = await ReviewableAsync(conn, tx, actor, id, ct);
            if (!loaded.IsSuccess) return loaded.Error;
            var report = loaded.Value;
            if (report.TargetType is not ("comment" or "live_comment" or "message"))
                return Error.RuleViolation("report.not_removable",
                    "Grup gönderilerini ve organizasyonları grubun yöneticileri kendi ekranlarından kaldırır.");
            var groupId = report.GroupId!.Value;
            if (report.SubjectId is { } subject && await RankAsync(conn, tx, groupId, actor, ct) <= await RankAsync(conn, tx, groupId, subject, ct))
                return RankViolation;

            var removed = report.TargetType switch
            {
                "comment" => await feed.RemoveCommentAsync(conn, tx, Guid.Parse(report.TargetId), reason, ct),
                "message" => await messages.RemoveMessageAsync(conn, tx, Guid.Parse(report.TargetId), reason, ct),
                _ => await live.RemoveCommentAsync(conn, tx, long.Parse(report.TargetId, System.Globalization.CultureInfo.InvariantCulture), ct),
            };
            var closed = await CloseReportsAsync(conn, tx, report, "actioned", null, ct);
            await AuditAsync(conn, tx, actor, AuditActor.User, "report.content_removed", "report", id, groupId,
                new { report.TargetType, report.TargetId, reason, removed, reports = closed }, ct);
            return Result.Success();
        }, RuleError, ct);
    }

    // Cases --------------------------------------------------------------------------------------

    private static Error? Validate(OpenCaseRequest r, out string reason)
    {
        reason = r.Reason?.Trim() ?? "";
        if (r.Sanction is null || !Sanctions.Contains(r.Sanction)) return Error.Validation("case.invalid_sanction", "Önerilen yaptırımı seç.");
        var durationOk = r.Sanction switch
        {
            "mute" => r.DurationDays is >= 1 and <= 90,
            "ban" => r.DurationDays is null or (>= 1 and <= 365),
            _ => r.DurationDays is null,
        };
        if (!durationOk)
            return Error.Validation("case.invalid_duration", "Susturma 1–90 gün, ban 1–365 gün ya da kalıcı olur; uyarı ve çıkarmanın süresi yoktur.");
        if (r.IllegalCategory is { } category && (r.Sanction != "ban" || !IllegalCategories.Contains(category)))
            return Error.Validation("case.invalid_illegal", "Yasa dışı faaliyet yalnızca ban önerisiyle ve listedeki bir kategoriyle işaretlenir.");
        return reason.Length is < 10 or > 1000 ? Error.Validation("case.invalid_reason", "Gerekçe 10–1000 karakter olmalı.") : null;
    }

    public async Task<Result<CreatedCase>> OpenCaseAsync(Guid actor, Guid groupId, OpenCaseRequest request, CancellationToken ct)
    {
        ArgumentNullException.ThrowIfNull(request);
        if (Validate(request, out var reason) is { } invalid) return invalid;
        if (request.SubjectId == actor) return Error.Validation("case.self", "Kendin hakkında dosya açamazsın.");

        var opened = await ActingTransaction.RunAsync<CreatedCase>(db, actor, async (conn, tx) =>
        {
            // One open case per person: the lock orders concurrent openings of the group.
            await ActingTransaction.ExecuteAsync(conn, tx, "select 1 from public.groups where id = @g for update", ct, ("g", groupId));
            if (!await HasPermissionAsync(conn, tx, actor, groupId, "reports.review", ct)) return Forbidden;
            if (request.MuteNow && !await HasPermissionAsync(conn, tx, actor, groupId, "members.mute", ct)) return Forbidden;
            if (await ActingTransaction.ScalarAsync(conn, tx,
                    "select exists (select 1 from public.group_members where group_id = @g and user_id = @u)", ct,
                    ("g", groupId), ("u", request.SubjectId)) is not true)
                return RuleError("subject_not_member");

            var subjectRank = await RankAsync(conn, tx, groupId, request.SubjectId, ct);
            if (await RankAsync(conn, tx, groupId, actor, ct) <= subjectRank) return RankViolation;
            if ((int)(await ActingTransaction.ScalarAsync(conn, tx, "select private.case_decider_rank(@g, @u)", ct,
                    ("g", groupId), ("u", request.SubjectId)))! <= subjectRank)
                return BoardRank;
            if (await ActingTransaction.ScalarAsync(conn, tx,
                    "select exists (select 1 from public.moderation_cases where group_id = @g and subject_id = @u and status = 'voting')", ct,
                    ("g", groupId), ("u", request.SubjectId)) is true)
                return Error.Conflict("case.already_open", "Bu kişi hakkında karar bekleyen bir dosya var.");

            ReportRow? report = null;
            if (request.ReportId is { } reportId)
            {
                report = await LoadReportAsync(conn, tx, reportId, ct);
                if (report is null || report.GroupId != groupId || report.SubjectId != request.SubjectId) return ReportNotFound;
                if (report.Status != "open") return ReportReviewed;
            }

            var id = (Guid)(await ActingTransaction.ScalarAsync(conn, tx,
                """
                insert into public.moderation_cases
                  (group_id, subject_id, opened_by, sanction, duration_days, reason, threshold, voting_ends_at, illegal_category)
                values (@g, @u, @actor, @sanction, @days, @reason, 'majority', now(), @illegal)
                returning id
                """, ct, ("g", groupId), ("u", request.SubjectId), ("actor", actor), ("sanction", request.Sanction),
                ("days", request.DurationDays), ("reason", reason), ("illegal", request.IllegalCategory)))!;
            await AuditAsync(conn, tx, actor, AuditActor.User, "case.opened", "moderation_case", id, groupId,
                new { userId = request.SubjectId, request.Sanction, request.DurationDays, request.IllegalCategory }, ct);
            if (report is not null) await CloseReportsAsync(conn, tx, report, "actioned", id, ct);
            if (request.MuteNow)
            {
                await ActingTransaction.ExecuteAsync(conn, tx,
                    "insert into public.sanctions (case_id, type, interim) values (@c, 'mute', true)", ct, ("c", id));
                await AuditAsync(conn, tx, actor, AuditActor.User, "sanction.applied", "moderation_case", id, groupId,
                    new { userId = request.SubjectId, type = "mute", interim = true }, ct);
            }
            return new CreatedCase(id);
        }, RuleError, ct);

        if (opened.IsSuccess && request.MuteNow) await live.EnforceSanctionAsync(groupId, request.SubjectId, ct);
        return opened;
    }

    private sealed record CaseRow(Guid Id, Guid GroupId, Guid SubjectId, string Sanction, string Status, string? IllegalCategory);

    private static async Task<CaseRow?> LoadCaseAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid id, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand(
            "select id, group_id, subject_id, sanction, status, illegal_category from public.moderation_cases where id = @id for update", conn, tx);
        cmd.Parameters.AddWithValue("id", id);
        await using var r = await cmd.ExecuteReaderAsync(ct);
        return await r.ReadAsync(ct)
            ? new CaseRow(r.GetGuid(0), r.GetGuid(1), r.GetGuid(2), r.GetString(3), r.GetString(4), r.IsDBNull(5) ? null : r.GetString(5))
            : null;
    }

    public async Task<Result<CaseVoteResult>> VoteAsync(Guid actor, Guid id, bool approve, CancellationToken ct)
    {
        CaseRow? decided = null;
        var voted = await ActingTransaction.RunAsync<CaseVoteResult>(db, actor, async (conn, tx) =>
        {
            var c = await LoadCaseAsync(conn, tx, id, ct);
            if (c is null) return CaseNotFound;
            if (c.Status != "voting") return Error.Conflict("case.closed", "Bu dosya karara bağlandı.");
            if (await ActingTransaction.ExecuteAsync(conn, tx,
                    "update public.case_votes set vote = @vote where case_id = @c and voter_id = @u", ct,
                    ("vote", approve ? "approve" : "reject"), ("c", id), ("u", actor)) == 0)
                return Error.Forbidden("case.not_voter", "Bu dosyada oy hakkın yok.");

            var status = await DecideAsync(conn, tx, c, actor, AuditActor.User, ct);
            if (status != "voting") decided = c;
            return new CaseVoteResult(status);
        }, RuleError, ct);

        if (decided is not null) await live.EnforceSanctionAsync(decided.GroupId, decided.SubjectId, ct);
        return voted;
    }

    /// <summary>
    /// Writes the decision of <c>private.case_outcome</c> if there is one: the emergency mute ends, an approved case's
    /// sanction starts, and a kick or ban removes the membership. Returns the case status afterwards.
    /// </summary>
    private async Task<string> DecideAsync(NpgsqlConnection conn, NpgsqlTransaction tx, CaseRow c, Guid? actor, string actorKind, CancellationToken ct)
    {
        if (await ActingTransaction.ScalarAsync(conn, tx, "select private.case_outcome(@c)", ct, ("c", c.Id)) is not string outcome) return "voting";

        await ActingTransaction.ExecuteAsync(conn, tx, "update public.moderation_cases set status = @s where id = @c", ct, ("s", outcome), ("c", c.Id));
        await AuditAsync(conn, tx, actor, actorKind, "case.decided", "moderation_case", c.Id, c.GroupId, new { outcome }, ct);
        if (await ActingTransaction.ExecuteAsync(conn, tx,
                "update public.sanctions set lifted_at = now(), lift_reason = 'decided' where case_id = @c and interim and lifted_at is null",
                ct, ("c", c.Id)) > 0)
            await AuditAsync(conn, tx, actor, actorKind, "sanction.lifted", "moderation_case", c.Id, c.GroupId,
                new { userId = c.SubjectId, reason = "decided", interim = true }, ct);
        if (outcome != "approved") return outcome;

        await ActingTransaction.ExecuteAsync(conn, tx, "insert into public.sanctions (case_id, type) values (@c, @type)", ct,
            ("c", c.Id), ("type", c.Sanction));
        var removed = c.Sanction is "kick" or "ban" && await membership.RemoveAsync(conn, tx, c.GroupId, c.SubjectId, ct);
        await AuditAsync(conn, tx, actor, actorKind, "sanction.applied", "moderation_case", c.Id, c.GroupId,
            new { userId = c.SubjectId, type = c.Sanction, removed }, ct);
        if (c.IllegalCategory is not null) await OpenReferralAsync(conn, tx, c, actor, actorKind, ct);
        return outcome;
    }

    /// <summary>
    /// An approved illegal-activity case: the platform team gets a referral with the evidence, and the account is suspended
    /// until it decides (docs/ARCHITECTURE.md §3e, Yasa dışı faaliyet).
    /// </summary>
    private async Task OpenReferralAsync(NpgsqlConnection conn, NpgsqlTransaction tx, CaseRow c, Guid? actor, string actorKind, CancellationToken ct)
    {
        var id = (Guid)(await ActingTransaction.ScalarAsync(conn, tx,
            """
            insert into public.platform_referrals (case_id, group_id, group_name, subject_id, subject_username, category, reason, evidence)
            select c.id, c.group_id, g.name, c.subject_id, p.username, c.illegal_category, c.reason,
                   coalesce((select jsonb_agg(jsonb_build_object(
                               'targetType', r.target_type, 'reason', r.reason, 'excerpt', case when r.target_type = 'message' then '' else r.excerpt end, 'note', r.note, 'reportedAt', r.created_at)
                             order by r.created_at)
                             from public.reports r where r.case_id = c.id), '[]'::jsonb)
            from public.moderation_cases c
            join public.groups g on g.id = c.group_id
            left join public.profiles p on p.id = c.subject_id
            where c.id = @c
            returning id
            """, ct, ("c", c.Id)))!;
        var suspended = await accounts.SuspendAsync(conn, tx, c.SubjectId, ReviewSuspensionReason, null, ct);
        await AuditAsync(conn, tx, actor, actorKind, "referral.opened", "platform_referral", id, c.GroupId,
            new { userId = c.SubjectId, caseId = c.Id, category = c.IllegalCategory, accountSuspended = suspended }, ct);
    }

    // Platform referrals -------------------------------------------------------------------------

    private static readonly Error ReferralNotFound = Error.NotFound("referral.not_found", "Bildirim bulunamadı.");

    public Task<Result<ReferralDecision>> DecideReferralAsync(
        Guid actorId, Guid referralId, bool ban, int? banDays, bool notifyAuthorities, string note, CancellationToken ct)
    {
        note = note?.Trim() ?? "";
        if (note.Length is < 3 or > 1000)
            return Task.FromResult<Result<ReferralDecision>>(Error.Validation("referral.invalid_note", "Karar notu 3–1000 karakter olmalı."));
        if (ban && banDays is not null and (< 1 or > 3650))
            return Task.FromResult<Result<ReferralDecision>>(Error.Validation("referral.invalid_days", "Ban 1–3650 gün ya da kalıcı olur."));

        return ActingTransaction.RunAsync<ReferralDecision>(db, actorId, async (conn, tx) =>
        {
            Guid subject;
            string status, category;
            await using (var cmd = new NpgsqlCommand(
                "select subject_id, status, category from public.platform_referrals where id = @id for update", conn, tx))
            {
                cmd.Parameters.AddWithValue("id", referralId);
                await using var r = await cmd.ExecuteReaderAsync(ct);
                if (!await r.ReadAsync(ct)) return ReferralNotFound;
                (subject, status, category) = (r.GetGuid(0), r.GetString(1), r.GetString(2));
            }
            if (status != "pending") return Error.Conflict("referral.decided", "Bu bildirim karara bağlandı.");

            DateTimeOffset? until = ban && banDays is { } days ? DateTimeOffset.UtcNow.AddDays(days) : null;
            await ActingTransaction.ExecuteAsync(conn, tx,
                """
                update public.platform_referrals
                set status = @status, ban_until = @until, law_enforcement = @authorities, decision_note = @note, decided_by = @actor
                where id = @id
                """, ct, ("status", ban ? "banned" : "cleared"), ("until", until?.UtcDateTime), ("authorities", notifyAuthorities ? "to_notify" : "none"),
                ("note", note), ("actor", actorId), ("id", referralId));

            var accountChanged = ban
                ? await accounts.SuspendAsync(conn, tx, subject,
                    until is null ? $"Yasa dışı faaliyet nedeniyle hesap kalıcı olarak kapatıldı: {note}" : $"Yasa dışı faaliyet nedeniyle hesap kapatıldı: {note}",
                    until, ct)
                : await accounts.UnsuspendAsync(conn, tx, subject, ct);
            await AuditAsync(conn, tx, actorId, AuditActor.Staff, "referral.decided", "platform_referral", referralId, null,
                new { userId = subject, ban, banDays, notifyAuthorities, note, category, accountChanged }, ct);
            return new ReferralDecision(subject, ban, until);
        }, RuleError, ct);
    }

    public Task<Result> MarkAuthoritiesNotifiedAsync(Guid actorId, Guid referralId, string note, CancellationToken ct)
    {
        note = note?.Trim() ?? "";
        if (note.Length is < 3 or > 1000)
            return Task.FromResult<Result>(Error.Validation("referral.invalid_note", "Bildirim notu 3–1000 karakter olmalı (ör. başvuru yeri, evrak no)."));

        return ActingTransaction.RunAsync(db, actorId, async (conn, tx) =>
        {
            var current = await ActingTransaction.ScalarAsync(conn, tx,
                "select law_enforcement from public.platform_referrals where id = @id for update", ct, ("id", referralId));
            if (current is not string state) return ReferralNotFound;
            if (state != "to_notify") return Error.Conflict("referral.not_to_notify", "Bu bildirim kolluğa bildirilecek olarak işaretli değil.");
            await ActingTransaction.ExecuteAsync(conn, tx,
                "update public.platform_referrals set law_enforcement = 'notified', authorities_note = @note where id = @id", ct,
                ("note", note), ("id", referralId));
            await AuditAsync(conn, tx, actorId, AuditActor.Staff, "referral.authorities_notified", "platform_referral", referralId, null,
                new { note }, ct);
            return Result.Success();
        }, RuleError, ct);
    }

    /// <summary>Decides the cases whose 72 hours are over (system job); returns how many were decided.</summary>
    public async Task<int> DecideDueCasesAsync(CancellationToken ct)
    {
        var due = new List<Guid>();
        await using (var cmd = db.CreateCommand(
            "select id from public.moderation_cases where status = 'voting' and voting_ends_at <= now() order by voting_ends_at limit 100"))
        await using (var r = await cmd.ExecuteReaderAsync(ct))
        {
            while (await r.ReadAsync(ct)) due.Add(r.GetGuid(0));
        }

        var decided = 0;
        foreach (var id in due)
        {
            CaseRow? c;
            try
            {
                await using var conn = await db.OpenConnectionAsync(ct);
                await using var tx = await conn.BeginTransactionAsync(ct);
                c = await LoadCaseAsync(conn, tx, id, ct);
                if (c is null || c.Status != "voting" || await DecideAsync(conn, tx, c, null, AuditActor.System, ct) == "voting") continue;
                await tx.CommitAsync(ct);
            }
            catch (PostgresException ex)
            {
                // One broken case must not hold back the others.
                LogDecideFailed(log, ex, id);
                continue;
            }
            decided++;
            await live.EnforceSanctionAsync(c.GroupId, c.SubjectId, ct);
        }
        return decided;
    }

    // Appeals ------------------------------------------------------------------------------------

    public Task<Result> DecideAppealAsOwnerAsync(Guid actor, Guid id, bool overturn, string? note, CancellationToken ct) =>
        DecideAppealCoreAsync(actor, id, overturn, note, staff: false, ct);

    public Task<Result> DecideAppealAsync(Guid actorId, Guid appealId, bool overturn, string? note, CancellationToken ct) =>
        DecideAppealCoreAsync(actorId, appealId, overturn, note, staff: true, ct);

    private Task<Result> DecideAppealCoreAsync(Guid actor, Guid id, bool overturn, string? note, bool staff, CancellationToken ct)
    {
        note = string.IsNullOrWhiteSpace(note) ? null : note.Trim();
        if (note is { Length: > 500 }) return Task.FromResult<Result>(Error.Validation("appeal.invalid_note", "Not en fazla 500 karakter olabilir."));

        return ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            Guid sanctionId, groupId, owner, userId;
            string handler, status;
            bool lifted;
            await using (var cmd = new NpgsqlCommand(
                """
                select a.sanction_id, a.handler, a.status, s.group_id, g.owner_id, s.user_id, s.lifted_at is not null
                from public.sanction_appeals a
                join public.sanctions s on s.id = a.sanction_id
                join public.groups g on g.id = s.group_id
                where a.id = @id
                for update of a, s
                """, conn, tx))
            {
                cmd.Parameters.AddWithValue("id", id);
                await using var r = await cmd.ExecuteReaderAsync(ct);
                if (!await r.ReadAsync(ct)) return AppealNotFound;
                (sanctionId, handler, status, groupId, owner, userId, lifted) =
                    (r.GetGuid(0), r.GetString(1), r.GetString(2), r.GetGuid(3), r.GetGuid(4), r.GetGuid(5), r.GetBoolean(6));
            }
            if (staff ? handler != "platform" : handler != "owner" || owner != actor)
                return Error.Forbidden("appeal.forbidden", handler == "platform"
                    ? "Bu itirazı platform ekibi karara bağlar."
                    : "Bu itirazı grup sahibi karara bağlar.");
            if (status != "pending") return Error.Conflict("appeal.decided", "Bu itiraz zaten karara bağlandı.");

            await ActingTransaction.ExecuteAsync(conn, tx,
                "update public.sanction_appeals set status = @s, decision_note = @note where id = @id", ct,
                ("s", overturn ? "overturned" : "upheld"), ("note", note), ("id", id));
            var kind = staff ? AuditActor.Staff : AuditActor.User;
            await AuditAsync(conn, tx, actor, kind, "appeal.decided", "sanction", sanctionId, groupId, new { overturn, userId }, ct);
            if (overturn && !lifted)
            {
                await ActingTransaction.ExecuteAsync(conn, tx,
                    "update public.sanctions set lifted_at = now(), lift_reason = 'appeal' where id = @id", ct, ("id", sanctionId));
                await AuditAsync(conn, tx, actor, kind, "sanction.lifted", "sanction", sanctionId, groupId, new { userId, reason = "appeal" }, ct);
            }
            return Result.Success();
        }, RuleError, ct);
    }

    // Platform team ------------------------------------------------------------------------------

    public Task<Result> ReviewReportAsync(Guid actorId, Guid reportId, bool actioned, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actorId, async (conn, tx) =>
        {
            var report = await LoadReportAsync(conn, tx, reportId, ct);
            if (report is null) return ReportNotFound;
            if (report.Status != "open") return ReportReviewed;
            var closed = await CloseReportsAsync(conn, tx, report, actioned ? "actioned" : "dismissed", null, ct);
            await AuditAsync(conn, tx, actorId, AuditActor.Staff, actioned ? "report.resolved" : "report.dismissed", "report", reportId,
                report.GroupId, new { report.TargetType, report.TargetId, reports = closed }, ct);
            return Result.Success();
        }, RuleError, ct);

    [LoggerMessage(Level = LogLevel.Error, Message = "Could not decide case {CaseId}; will retry on the next run")]
    private static partial void LogDecideFailed(ILogger logger, Exception ex, Guid caseId);
}

/// <summary>Decides due cases every <c>Moderation:MonitorInterval</c> (default 1 minute; zero turns it off).</summary>
internal sealed partial class ModerationMonitor(ModerationService moderation, IConfiguration configuration, ILogger<ModerationMonitor> logger)
    : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var interval = configuration.GetValue("Moderation:MonitorInterval", TimeSpan.FromMinutes(1));
        if (interval <= TimeSpan.Zero) return;

        using var timer = new PeriodicTimer(interval);
        do
        {
            // A database outage must not stop the API; the next run retries.
            try
            {
                await moderation.DecideDueCasesAsync(stoppingToken);
            }
            catch (Exception ex) when (ex is not OperationCanceledException)
            {
                LogRunFailed(logger, ex);
            }
        }
        while (await timer.WaitForNextTickAsync(stoppingToken));
    }

    [LoggerMessage(Level = LogLevel.Error, Message = "Moderation monitor run failed; will retry on the next run")]
    private static partial void LogRunFailed(ILogger logger, Exception ex);
}
