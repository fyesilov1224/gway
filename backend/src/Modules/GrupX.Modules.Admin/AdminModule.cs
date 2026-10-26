using System.Security.Claims;
using GrupX.Modules.Billing.Contracts;
using GrupX.Modules.Events.Contracts;
using GrupX.Modules.Feed.Contracts;
using GrupX.Modules.Groups.Contracts;
using GrupX.Modules.Identity.Contracts;
using GrupX.Modules.Live.Contracts;
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

public static class AdminModule
{
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
        return services;
    }

    public static IEndpointRouteBuilder MapAdminEndpoints(this IEndpointRouteBuilder app)
    {
        var users = app.MapGroup("/admin/users");

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

        return app;
    }
}
