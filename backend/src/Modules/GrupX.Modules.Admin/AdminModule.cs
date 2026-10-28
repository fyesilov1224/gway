using System.Security.Claims;
using GrupX.Modules.Billing.Contracts;
using GrupX.Modules.Events.Contracts;
using GrupX.Modules.Feed.Contracts;
using GrupX.Modules.Groups.Contracts;
using GrupX.Modules.Identity.Contracts;
using GrupX.Modules.Live.Contracts;
using GrupX.Modules.Matching.Contracts;
using GrupX.Modules.Messaging.Contracts;
using GrupX.Modules.Moderation.Contracts;
using GrupX.Modules.Notifications.Contracts;
using GrupX.Modules.Support.Contracts;
using GrupX.SharedKernel;
using GrupX.SharedKernel.Http;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;

namespace GrupX.Modules.Admin;

public sealed record SuspendUserRequest(string Reason, DateTimeOffset? Until);

public sealed record SuspendGroupRequest(string Reason);

public sealed record CancelSubscriptionRequest(string Reason, bool Refunded);

public sealed record SupportReplyRequest(string Body);

public sealed record SupportStatusRequest(string Status);

public sealed record RemoveContentRequest(string Reason);

public sealed record EndLiveRequest(string Reason);

public sealed record CancelAdminEventRequest(string Reason);

public sealed record AdminAppealDecision(bool Overturn, string? Note);

/// <param name="BanDays">Null with <paramref name="Ban"/> closes the account for good.</param>
public sealed record AdminReferralDecision(bool Ban, int? BanDays, bool LawEnforcement, string Note);

public sealed record AdminReferralNote(string Note);

/// <summary>A decided referral and, after a ban, how many paid slices ended and which groups were suspended.</summary>
public sealed record AdminReferralOutcome(bool Banned, DateTimeOffset? Until, int CanceledPlans, IReadOnlyList<Guid> SuspendedGroups);

public sealed record SuspendMatchProfileRequest(string Reason, DateTimeOffset? Until);

public sealed record GrantPackageRequest(string Username, string Slug, int Days, string Reason);

public sealed record GrantUserPackageRequest(string Slug, int Days, string Reason);

public sealed record GrantGroupPlanRequest(string Slug, int Days, string Reason);

public static class AdminModule
{
    private static readonly TimeZoneInfo Turkey = TimeZoneInfo.FindSystemTimeZoneById("Europe/Istanbul");

    public static IServiceCollection AddAdminModule(this IServiceCollection services)
    {
        services.AddSingleton<PlatformStaff>();
        services.AddSingleton<AdminUsers>();
        services.AddSingleton<AdminGroups>();
        services.AddSingleton<AdminBilling>();
        services.AddSingleton<AdminSupport>();
        services.AddSingleton<AdminContent>();
        services.AddSingleton<AdminLive>();
        services.AddSingleton<AdminEvents>();
        services.AddSingleton<AdminModeration>();
        services.AddSingleton<AdminGoals>();
        services.AddSingleton<AdminLeagues>();
        services.AddSingleton<AdminAnalytics>();
        services.AddSingleton<AdminLegal>();
        services.TryAddSingleton(TimeProvider.System);
        return services;
    }

    public static IEndpointRouteBuilder MapAdminEndpoints(this IEndpointRouteBuilder app)
    {
        // The overview page (docs/ARCHITECTURE.md §8b); revenue only for the roles that see billing.
        app.MapGet("/admin/analytics/overview", async (
                int? days, ClaimsPrincipal user, PlatformStaff staff, AdminAnalytics analytics, TimeProvider time, CancellationToken ct) =>
            {
                var range = days ?? 30;
                if (!AdminAnalytics.Ranges.Contains(range))
                    return Error.Validation("admin.invalid_range", "Aralık 7, 30, 90 ya da 365 gün olmalı.").ToProblem();
                var role = await staff.GetRoleAsync(user.GetUserId(), ct);
                var today = DateOnly.FromDateTime(TimeZoneInfo.ConvertTime(time.GetUtcNow(), Turkey).DateTime);
                return TypedResults.Ok(await analytics.OverviewAsync(range, StaffRoles.Billing.Contains(role), today, ct));
            })
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.All));

        // Legal texts (docs/ARCHITECTURE.md §8b, Hukuki metin yönetimi): admin only, even to read.
        var legal = app.MapGroup("/admin/legal").AddEndpointFilter(new RequireStaffFilter(StaffRoles.AdminOnly));

        legal.MapGet("", async (AdminLegal admin, CancellationToken ct) => TypedResults.Ok(await admin.ListAsync(ct)));

        legal.MapGet("/{kind}/{version:int}", async (string kind, int version, AdminLegal admin, CancellationToken ct) =>
            (await admin.GetAsync(kind, version, ct)).ToHttpResult());

        legal.MapPost("/{kind}", async (string kind, LegalVersionRequest body, ClaimsPrincipal user, AdminLegal admin, CancellationToken ct) =>
            AdminLegal.IsKind(kind)
                ? (await admin.PublishAsync(user.GetUserId(), kind, body, ct)).ToHttpResult()
                : Results.NotFound());

        legal.MapPut("/{kind}/{version:int}", async (
                string kind, int version, LegalVersionRequest body, ClaimsPrincipal user, AdminLegal admin, CancellationToken ct) =>
            (await admin.UpdateAsync(user.GetUserId(), kind, version, body, ct)).ToHttpResult());

        legal.MapDelete("/{kind}/{version:int}", async (
                string kind, int version, ClaimsPrincipal user, AdminLegal admin, CancellationToken ct) =>
            (await admin.DeleteAsync(user.GetUserId(), kind, version, ct)).ToHttpResult());

        // Security verification (docs/ARCHITECTURE.md §3h): the switch is admin only, reviews admin and moderator.
        var security = app.MapGroup("/admin/security");

        security.MapGet("/settings", async (ISecurityAdministration admin, CancellationToken ct) =>
                TypedResults.Ok(await admin.GetSettingsAsync(ct)))
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.AdminOnly));

        security.MapPut("/settings", async (
                SecuritySettingsRequest body, ClaimsPrincipal user, ISecurityAdministration admin, CancellationToken ct) =>
                (await admin.UpdateSettingsAsync(user.GetUserId(), body, ct)).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.AdminOnly));

        security.MapGet("/reviews", async (string? status, int? page, ISecurityAdministration admin, CancellationToken ct) =>
                (await admin.ListReviewsAsync(status, page ?? 1, ct)).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.CanSuspend));

        security.MapPost("/reviews/{id:guid}/approval", async (
                Guid id, ReviewApprovalRequest body, ClaimsPrincipal user, ISecurityAdministration admin, CancellationToken ct) =>
                (await admin.ApproveAsync(user.GetUserId(), id, body, ct)).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.CanSuspend));

        security.MapPost("/reviews/{id:guid}/ban", async (
                Guid id, ReviewBanRequest body, ClaimsPrincipal user, ISecurityAdministration admin, CancellationToken ct) =>
                (await admin.BanAsync(user.GetUserId(), id, body, ct)).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.CanSuspend));

        var users = app.MapGroup("/admin/users");

        users.MapGet("/{id:guid}/security", async (Guid id, ISecurityAdministration admin, CancellationToken ct) =>
                (await admin.GetUserAsync(id, ct)).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.All));

        // Store review accounts (docs/ARCHITECTURE.md §3h, İnceleme hesabı muafiyeti): admin only.
        users.MapPut("/{id:guid}/security/review-exempt", async (
                Guid id, ReviewExemptRequest body, ClaimsPrincipal user, ISecurityAdministration admin, CancellationToken ct) =>
                (await admin.SetReviewExemptAsync(user.GetUserId(), id, body, ct)).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.AdminOnly));

        users.MapGet("", async (string? q, string? status, int? page, AdminUsers admin, CancellationToken ct) =>
                status is not null && !AdminUsers.Statuses.Contains(status)
                    ? Error.Validation("admin.invalid_status", "Geçersiz durum filtresi.").ToProblem()
                    : TypedResults.Ok(await admin.SearchAsync(q, status, page ?? 1, ct)))
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.All));

        users.MapGet("/stats", async (AdminUsers admin, CancellationToken ct) =>
                TypedResults.Ok(await admin.StatsAsync(ct)))
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.All));

        users.MapGet("/{id:guid}", async (Guid id, AdminUsers admin, CancellationToken ct) =>
                (await admin.GetAsync(id, ct)).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.All));

        users.MapPost("/{id:guid}/suspension", async (
                Guid id, SuspendUserRequest body, ClaimsPrincipal user,
                PlatformStaff staff, IAccountAdministration accounts, CancellationToken ct) =>
            {
                if (await staff.GetRoleAsync(id, ct) is not null)
                    return Error.RuleViolation("admin.cannot_suspend_staff", "Platform ekibi üyeleri askıya alınamaz.").ToProblem();

                return (await accounts.SuspendAsync(user.GetUserId(), id, body.Reason, body.Until, ct)).ToHttpResult();
            })
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.CanSuspend));

        users.MapDelete("/{id:guid}/suspension", async (
                Guid id, ClaimsPrincipal user, IAccountAdministration accounts, CancellationToken ct) =>
                (await accounts.UnsuspendAsync(user.GetUserId(), id, ct)).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.CanSuspend));

        // The person's personal packages (docs/ARCHITECTURE.md §3g, Kullanıcının paketleri).
        users.MapGet("/{id:guid}/packages", async (Guid id, IBillingAdministration billingAdmin, CancellationToken ct) =>
                TypedResults.Ok(await billingAdmin.PersonalSubscriptionsAsync(id, ct)))
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.All));

        users.MapPost("/{id:guid}/packages", async (
                Guid id, GrantUserPackageRequest body, ClaimsPrincipal user, IBillingAdministration billingAdmin, CancellationToken ct) =>
                PersonalPlans.Matching.Contains(body.Slug)
                    ? (await billingAdmin.GrantPersonalPlanAsync(user.GetUserId(), id, body.Slug, body.Days, body.Reason, ct)).ToHttpResult()
                    : Results.NotFound())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.AdminOnly));

        users.MapPost("/{id:guid}/packages/{slug}/cancellation", async (
                Guid id, string slug, CancelSubscriptionRequest body, ClaimsPrincipal user, IBillingAdministration billingAdmin,
                CancellationToken ct) =>
                PersonalPlans.Matching.Contains(slug)
                    ? (await billingAdmin.CancelPersonalPlanAsync(user.GetUserId(), id, slug, body.Reason, body.Refunded, ct)).ToHttpResult()
                    : Results.NotFound())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.AdminOnly));

        var groups = app.MapGroup("/admin/groups");

        groups.MapGet("", async (string? q, string? status, int? page, AdminGroups admin, CancellationToken ct) =>
                status is not null && !AdminGroups.Statuses.Contains(status)
                    ? Error.Validation("admin.invalid_status", "Geçersiz durum filtresi.").ToProblem()
                    : TypedResults.Ok(await admin.SearchAsync(q, status, page ?? 1, ct)))
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.All));

        groups.MapGet("/stats", async (AdminGroups admin, CancellationToken ct) =>
                TypedResults.Ok(await admin.StatsAsync(ct)))
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.All));

        groups.MapGet("/{id:guid}", async (Guid id, AdminGroups admin, CancellationToken ct) =>
                (await admin.GetAsync(id, ct)).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.All));

        groups.MapPost("/{id:guid}/suspension", async (
                Guid id, SuspendGroupRequest body, ClaimsPrincipal user, IGroupAdministration admin, CancellationToken ct) =>
                (await admin.SuspendAsync(user.GetUserId(), id, body.Reason, ct)).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.CanSuspend));

        groups.MapDelete("/{id:guid}/suspension", async (
                Guid id, ClaimsPrincipal user, IGroupAdministration admin, CancellationToken ct) =>
                (await admin.UnsuspendAsync(user.GetUserId(), id, ct)).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.CanSuspend));

        // The group's plan (docs/ARCHITECTURE.md §7, Yönetici işlemleri).
        groups.MapPost("/{id:guid}/plan", async (
                Guid id, GrantGroupPlanRequest body, ClaimsPrincipal user, IBillingAdministration billingAdmin, CancellationToken ct) =>
                (await billingAdmin.GrantGroupPlanAsync(user.GetUserId(), id, body.Slug, body.Days, body.Reason, ct)).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.AdminOnly));

        groups.MapPost("/{id:guid}/plan/cancellation", async (
                Guid id, CancelSubscriptionRequest body, ClaimsPrincipal user, IBillingAdministration billingAdmin, CancellationToken ct) =>
                (await billingAdmin.CancelGroupPlanAsync(user.GetUserId(), id, body.Reason, body.Refunded, ct)).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.AdminOnly));

        var billing = app.MapGroup("/admin/billing");

        billing.MapGet("/stats", async (AdminBilling admin, CancellationToken ct) =>
                TypedResults.Ok(await admin.StatsAsync(ct)))
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.AdminOnly));

        billing.MapGet("/orders", async (string? q, string? status, string? provider, int? page, AdminBilling admin, CancellationToken ct) =>
                (status is not null && !AdminBilling.OrderStatuses.Contains(status)) || (provider is not null && !AdminBilling.Providers.Contains(provider))
                    ? Error.Validation("admin.invalid_filter", "Geçersiz filtre.").ToProblem()
                    : TypedResults.Ok(await admin.OrdersAsync(q, status, provider, page ?? 1, ct)))
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.Billing));

        billing.MapGet("/subscriptions", async (string? q, int? page, AdminBilling admin, CancellationToken ct) =>
                TypedResults.Ok(await admin.SubscriptionsAsync(q, page ?? 1, ct)))
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.Billing));

        // Payment provider setup (docs/PAYMENTS.md). Never returns a key.
        billing.MapGet("/providers", (IBillingAdministration billingAdmin) => TypedResults.Ok(billingAdmin.ProvidersStatus()))
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.AdminOnly));

        billing.MapPost("/providers/{provider}/check", async (
                string provider, HttpContext http, IBillingAdministration billingAdmin, CancellationToken ct) =>
                (await billingAdmin.CheckProviderAsync(provider, http.Connection.RemoteIpAddress?.ToString() ?? "127.0.0.1", ct)).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.AdminOnly))
            .RequireRateLimiting(RateLimitPolicies.Sensitive);

        app.MapGet("/admin/plans", async (AdminBilling admin, CancellationToken ct) =>
                TypedResults.Ok(await admin.PlansAsync(ct)))
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.Billing));

        app.MapPut("/admin/plans/{slug}", async (
                string slug, PlanUpdate body, ClaimsPrincipal user, IBillingAdministration billingAdmin, CancellationToken ct) =>
                (await billingAdmin.UpdatePlanAsync(user.GetUserId(), slug, body, ct)).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.AdminOnly));

        app.MapPost("/admin/subscriptions/{id:guid}/cancellation", async (
                Guid id, CancelSubscriptionRequest body, ClaimsPrincipal user, IBillingAdministration billingAdmin, CancellationToken ct) =>
                (await billingAdmin.CancelSubscriptionAsync(user.GetUserId(), id, body.Reason, body.Refunded, ct)).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.AdminOnly));

        var support = app.MapGroup("/admin/support").AddEndpointFilter(new RequireStaffFilter(StaffRoles.All));

        support.MapGet("/stats", async (AdminSupport admin, CancellationToken ct) => TypedResults.Ok(await admin.StatsAsync(ct)));

        support.MapGet("/tickets", async (string? q, string? kind, string? status, int? page, AdminSupport admin, CancellationToken ct) =>
            (kind is not null && !SupportKinds.All.Contains(kind)) || (status is not null && !SupportStatuses.All.Contains(status))
                ? Error.Validation("admin.invalid_filter", "Geçersiz filtre.").ToProblem()
                : TypedResults.Ok(await admin.SearchAsync(q, kind, status, page ?? 1, ct)));

        support.MapGet("/tickets/{id:guid}", async (Guid id, AdminSupport admin, CancellationToken ct) =>
            (await admin.GetAsync(id, ct)).ToHttpResult());

        support.MapPost("/tickets/{id:guid}/messages", async (
                Guid id, SupportReplyRequest body, ClaimsPrincipal user, ISupportAdministration tickets, CancellationToken ct) =>
            (await tickets.ReplyAsync(user.GetUserId(), id, body.Body, ct)).ToHttpResult());

        support.MapPut("/tickets/{id:guid}/status", async (
                Guid id, SupportStatusRequest body, ClaimsPrincipal user, ISupportAdministration tickets, CancellationToken ct) =>
            (await tickets.SetStatusAsync(user.GetUserId(), id, body.Status, ct)).ToHttpResult());

        var content = app.MapGroup("/admin");

        content.MapGet("/posts", async (string? q, bool? removed, int? page, AdminContent admin, CancellationToken ct) =>
                TypedResults.Ok(await admin.SearchAsync(q, removed, page ?? 1, ct)))
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.All));

        content.MapGet("/posts/{id:guid}", async (Guid id, AdminContent admin, CancellationToken ct) =>
                (await admin.GetAsync(id, ct)).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.All));

        content.MapPost("/posts/{id:guid}/removal", async (
                Guid id, RemoveContentRequest body, ClaimsPrincipal user, IFeedAdministration feed, CancellationToken ct) =>
                (await feed.RemovePostAsync(user.GetUserId(), id, body.Reason, ct)).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.CanSuspend));

        content.MapDelete("/posts/{id:guid}/removal", async (Guid id, ClaimsPrincipal user, IFeedAdministration feed, CancellationToken ct) =>
                (await feed.RestorePostAsync(user.GetUserId(), id, ct)).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.CanSuspend));

        content.MapPost("/comments/{id:guid}/removal", async (
                Guid id, RemoveContentRequest body, ClaimsPrincipal user, IFeedAdministration feed, CancellationToken ct) =>
                (await feed.RemoveCommentAsync(user.GetUserId(), id, body.Reason, ct)).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.CanSuspend));

        content.MapGet("/live", async (string? status, int? page, AdminLive admin, CancellationToken ct) =>
                TypedResults.Ok(await admin.SearchAsync(status, page ?? 1, ct)))
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.All));

        content.MapGet("/notifications/stats", async (INotificationsAdministration notifications, CancellationToken ct) =>
                TypedResults.Ok(await notifications.PushStatsAsync(ct)))
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.All));

        content.MapGet("/matching/stats", async (IMatchingAdministration matching, CancellationToken ct) =>
                TypedResults.Ok(await matching.StatsAsync(ct)))
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.All));

        content.MapPost("/matching/profiles/{userId:guid}/suspension", async (
                Guid userId, SuspendMatchProfileRequest body, ClaimsPrincipal user, IMatchingAdministration matching, CancellationToken ct) =>
                (await matching.SuspendAsync(user.GetUserId(), userId, body.Reason, body.Until, ct)).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.CanSuspend));

        content.MapDelete("/matching/profiles/{userId:guid}/suspension", async (
                Guid userId, ClaimsPrincipal user, IMatchingAdministration matching, CancellationToken ct) =>
                (await matching.LiftSuspensionAsync(user.GetUserId(), userId, ct)).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.CanSuspend));

        content.MapPost("/matching/photos/{id:guid}/removal", async (
                Guid id, RemoveContentRequest body, ClaimsPrincipal user, IMatchingAdministration matching, CancellationToken ct) =>
                (await matching.RemovePhotoAsync(user.GetUserId(), id, body.Reason, ct)).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.CanSuspend));

        content.MapPut("/matching/settings", async (
                MatchingSettings body, ClaimsPrincipal user, IMatchingAdministration matching, CancellationToken ct) =>
                (await matching.UpdateSettingsAsync(user.GetUserId(), body, ct)).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.AdminOnly));

        content.MapGet("/matching/packages", async (IBillingAdministration billingAdmin, CancellationToken ct) =>
            {
                var packages = new List<PersonalPlanSummary>();
                foreach (var slug in PersonalPlans.Matching) packages.Add(await billingAdmin.PersonalPlanAsync(slug, ct));
                return TypedResults.Ok(packages);
            })
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.All));

        content.MapPut("/matching/packages/{slug}", async (
                string slug, PersonalPlanUpdate body, ClaimsPrincipal user, IBillingAdministration billingAdmin, CancellationToken ct) =>
                PersonalPlans.Matching.Contains(slug)
                    ? (await billingAdmin.UpdatePersonalPlanAsync(user.GetUserId(), slug, body, ct)).ToHttpResult()
                    : Results.NotFound())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.AdminOnly));

        content.MapPost("/matching/packages/grants", async (
                GrantPackageRequest body, ClaimsPrincipal user, IBillingAdministration billingAdmin, CancellationToken ct) =>
                PersonalPlans.Matching.Contains(body.Slug)
                    ? (await billingAdmin.GrantPersonalPlanAsync(user.GetUserId(), body.Username, body.Slug, body.Days, body.Reason, ct)).ToHttpResult()
                    : Results.NotFound())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.AdminOnly));

        content.MapPost("/live/{id:guid}/end", async (
                Guid id, EndLiveRequest body, ClaimsPrincipal user, ILiveAdministration live, CancellationToken ct) =>
                (await live.ForceEndAsync(user.GetUserId(), id, body.Reason, ct)).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.CanSuspend));

        content.MapGet("/events", async (string? q, string? status, int? page, AdminEvents admin, CancellationToken ct) =>
                TypedResults.Ok(await admin.SearchAsync(q, status, page ?? 1, ct)))
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.All));

        content.MapPost("/events/{id:guid}/cancellation", async (
                Guid id, CancelAdminEventRequest body, ClaimsPrincipal user, IEventsAdministration events, CancellationToken ct) =>
                (await events.CancelAsync(user.GetUserId(), id, body.Reason, ct)).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.CanSuspend));

        content.MapDelete("/events/{id:guid}/meeting-point", async (Guid id, ClaimsPrincipal user, IEventsAdministration events, CancellationToken ct) =>
                (await events.RemoveMeetingPointAsync(user.GetUserId(), id, ct)).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.CanSuspend));

        // The groups league (docs/ARCHITECTURE.md §3d, Gruplar Ligi).
        content.MapGet("/leagues", async (string? month, AdminLeagues admin, TimeProvider time, CancellationToken ct) =>
                AdminLeagues.ParseMonth(month, time.GetUtcNow()) is { } m
                    ? Results.Ok(await admin.LeaguesAsync(m, ct))
                    : Results.Problem(statusCode: StatusCodes.Status400BadRequest, title: "Ay YYYY-MM biçiminde olmalı."))
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.All));

        content.MapGet("/leagues/table", async (string? month, string category, short province, AdminLeagues admin, TimeProvider time, CancellationToken ct) =>
                AdminLeagues.ParseMonth(month, time.GetUtcNow()) is { } m
                    ? Results.Ok(await admin.TableAsync(m, category, province, ct))
                    : Results.Problem(statusCode: StatusCodes.Status400BadRequest, title: "Ay YYYY-MM biçiminde olmalı."))
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.All));

        content.MapPut("/leagues/{month}/exclusions/{groupId:guid}", async (
                string month, Guid groupId, AdminLeagueExclusionRequest body, ClaimsPrincipal user, IEventsAdministration events,
                CancellationToken ct) =>
                AdminLeagues.ParseMonth(month, DateTimeOffset.UtcNow) is { } m && !string.IsNullOrWhiteSpace(month)
                    ? (await events.ExcludeFromLeagueAsync(user.GetUserId(), m, groupId, body.Reason, ct)).ToHttpResult()
                    : Results.Problem(statusCode: StatusCodes.Status400BadRequest, title: "Ay YYYY-MM biçiminde olmalı."))
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.CanSuspend));

        content.MapDelete("/leagues/{month}/exclusions/{groupId:guid}", async (
                string month, Guid groupId, ClaimsPrincipal user, IEventsAdministration events, CancellationToken ct) =>
                AdminLeagues.ParseMonth(month, DateTimeOffset.UtcNow) is { } m && !string.IsNullOrWhiteSpace(month)
                    ? (await events.RestoreToLeagueAsync(user.GetUserId(), m, groupId, ct)).ToHttpResult()
                    : Results.Problem(statusCode: StatusCodes.Status400BadRequest, title: "Ay YYYY-MM biçiminde olmalı."))
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.CanSuspend));

        content.MapGet("/goals", async (string? status, int? page, AdminGoals admin, CancellationToken ct) =>
                TypedResults.Ok(await admin.SearchAsync(status, page ?? 1, ct)))
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.All));

        content.MapPost("/goals/{id:guid}/cancellation", async (Guid id, ClaimsPrincipal user, IEventsAdministration events, CancellationToken ct) =>
                (await events.CancelGoalAsync(user.GetUserId(), id, ct)).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.CanSuspend));

        content.MapGet("/reports", async (string? scope, string? status, string? type, int? page, AdminModeration admin, CancellationToken ct) =>
                TypedResults.Ok(await admin.ReportsAsync(scope, status, type, page ?? 1, ct)))
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.All));

        // Phase 15: the reported message and the five before it; every viewing is audited.
        content.MapGet("/reports/{id:guid}/message-context", async (
                Guid id, ClaimsPrincipal user, AdminModeration admin, IMessagingAdministration messaging, CancellationToken ct) =>
                await admin.ReportedMessageAsync(id, ct) is { } message
                    ? (await messaging.ContextAsync(user.GetUserId(), message, id, ct)).ToHttpResult()
                    : ((Result)Error.NotFound("admin.not_a_message_report", "Bu şikayet bir mesaj hakkında değil.")).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.CanSuspend));

        content.MapPost("/messages/{id:guid}/removal", async (
                Guid id, RemoveContentRequest body, ClaimsPrincipal user, IMessagingAdministration messaging, CancellationToken ct) =>
                (await messaging.RemoveMessageAsync(user.GetUserId(), id, body.Reason, ct)).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.CanSuspend));

        content.MapPost("/reports/{id:guid}/dismissal", async (Guid id, ClaimsPrincipal user, IModerationAdministration moderation, CancellationToken ct) =>
                (await moderation.ReviewReportAsync(user.GetUserId(), id, actioned: false, ct)).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.CanSuspend));

        content.MapPost("/reports/{id:guid}/resolution", async (Guid id, ClaimsPrincipal user, IModerationAdministration moderation, CancellationToken ct) =>
                (await moderation.ReviewReportAsync(user.GetUserId(), id, actioned: true, ct)).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.CanSuspend));

        content.MapGet("/appeals", async (string? status, int? page, AdminModeration admin, CancellationToken ct) =>
                TypedResults.Ok(await admin.AppealsAsync(status, page ?? 1, ct)))
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.All));

        content.MapPost("/appeals/{id:guid}/decision", async (
                Guid id, AdminAppealDecision body, ClaimsPrincipal user, IModerationAdministration moderation, CancellationToken ct) =>
                (await moderation.DecideAppealAsync(user.GetUserId(), id, body.Overturn, body.Note, ct)).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.CanSuspend));

        // Illegal-activity referrals (docs/ARCHITECTURE.md §3e): the team sees them, only an admin decides.
        var referrals = app.MapGroup("/admin/referrals");

        referrals.MapGet("", async (string? status, int? page, AdminModeration admin, CancellationToken ct) =>
                TypedResults.Ok(await admin.ReferralsAsync(status, page ?? 1, ct)))
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.CanSuspend));

        referrals.MapPost("/{id:guid}/decision", async (
                Guid id, AdminReferralDecision body, ClaimsPrincipal user, IModerationAdministration moderation,
                IBillingAdministration billingAdmin, IGroupAdministration groupAdmin, CancellationToken ct) =>
            {
                var actor = user.GetUserId();
                var decided = await moderation.DecideReferralAsync(actor, id, body.Ban, body.BanDays, body.LawEnforcement, body.Note, ct);
                if (!decided.IsSuccess) return ((Result<AdminReferralOutcome>)decided.Error).ToHttpResult();

                var d = decided.Value;
                if (!d.Banned) return Result<AdminReferralOutcome>.Success(new AdminReferralOutcome(false, null, 0, [])).ToHttpResult();
                const string Reason = "Yasa dışı faaliyet nedeniyle platform banı";
                var canceled = await billingAdmin.CancelForViolationAsync(actor, d.SubjectId, Reason, ct);
                var groups = await groupAdmin.SuspendOwnedAsync(actor, d.SubjectId, Reason, ct);
                return Result<AdminReferralOutcome>.Success(new AdminReferralOutcome(true, d.Until, canceled, groups)).ToHttpResult();
            })
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.AdminOnly));

        referrals.MapPost("/{id:guid}/authorities", async (
                Guid id, AdminReferralNote body, ClaimsPrincipal user, IModerationAdministration moderation, CancellationToken ct) =>
                (await moderation.MarkAuthoritiesNotifiedAsync(user.GetUserId(), id, body.Note, ct)).ToHttpResult())
            .AddEndpointFilter(new RequireStaffFilter(StaffRoles.AdminOnly));

        return app;
    }
}
