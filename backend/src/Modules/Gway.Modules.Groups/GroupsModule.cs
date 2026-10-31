using System.Security.Claims;
using Gway.Modules.Groups.Contracts;
using Gway.SharedKernel.Http;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;

namespace Gway.Modules.Groups;

public static class GroupsModule
{
    public static IServiceCollection AddGroupsModule(this IServiceCollection services)
    {
        services.AddSingleton<GroupAccess>();
        services.AddSingleton<GroupService>();
        services.AddSingleton<IGroupAdministration>(sp => sp.GetRequiredService<GroupService>());
        services.AddSingleton<MembershipService>();
        services.AddSingleton<InviteLinkService>();
        services.AddSingleton<GroupSharePages>();
        services.AddSingleton<IGroupMembership>(sp => sp.GetRequiredService<MembershipService>());
        return services;
    }

    /// <summary>Every group write goes through these endpoints; clients read groups from Supabase.</summary>
    public static IEndpointRouteBuilder MapGroupsEndpoints(this IEndpointRouteBuilder app)
    {
        var groups = app.MapGroup("/groups");

        groups.MapPost("", async (CreateGroupRequest body, ClaimsPrincipal user, GroupService service, CancellationToken ct) =>
            (await service.CreateAsync(user.GetUserId(), body, ct)).ToHttpResult());

        groups.MapPatch("/{id:guid}", async (Guid id, UpdateGroupRequest body, ClaimsPrincipal user, GroupService service, CancellationToken ct) =>
            (await service.UpdateAsync(user.GetUserId(), id, body, ct)).ToHttpResult());

        groups.MapDelete("/{id:guid}", async (Guid id, ClaimsPrincipal user, GroupService service, CancellationToken ct) =>
            (await service.DeleteAsync(user.GetUserId(), id, ct)).ToHttpResult());

        groups.MapPost("/{id:guid}/ownership", async (
                Guid id, TransferOwnershipRequest body, ClaimsPrincipal user, GroupService service, CancellationToken ct) =>
            (await service.TransferOwnershipAsync(user.GetUserId(), id, body.UserId, ct)).ToHttpResult());

        groups.MapPut("/{id:guid}/case-threshold", async (
                Guid id, CaseThresholdRequest body, ClaimsPrincipal user, GroupService service, CancellationToken ct) =>
            (await service.SetCaseThresholdAsync(user.GetUserId(), id, body.Threshold, ct)).ToHttpResult());

        // The caller's own membership.
        groups.MapPost("/{id:guid}/join", async (Guid id, ClaimsPrincipal user, MembershipService members, CancellationToken ct) =>
            (await members.JoinAsync(user.GetUserId(), id, ct)).ToHttpResult());

        groups.MapDelete("/{id:guid}/join-request", async (Guid id, ClaimsPrincipal user, MembershipService members, CancellationToken ct) =>
            (await members.CancelRequestAsync(user.GetUserId(), id, ct)).ToHttpResult());

        groups.MapDelete("/{id:guid}/membership", async (Guid id, ClaimsPrincipal user, MembershipService members, CancellationToken ct) =>
            (await members.LeaveAsync(user.GetUserId(), id, ct)).ToHttpResult());

        groups.MapDelete("/{id:guid}/invitation", async (Guid id, ClaimsPrincipal user, MembershipService members, CancellationToken ct) =>
            (await members.DeclineInvitationAsync(user.GetUserId(), id, ct)).ToHttpResult());

        // Member management.
        groups.MapPost("/{id:guid}/join-requests/{userId:guid}/approval", async (
                Guid id, Guid userId, ClaimsPrincipal user, MembershipService members, CancellationToken ct) =>
            (await members.ApproveRequestAsync(user.GetUserId(), id, userId, ct)).ToHttpResult());

        groups.MapDelete("/{id:guid}/join-requests/{userId:guid}", async (
                Guid id, Guid userId, ClaimsPrincipal user, MembershipService members, CancellationToken ct) =>
            (await members.RejectRequestAsync(user.GetUserId(), id, userId, ct)).ToHttpResult());

        groups.MapPost("/{id:guid}/invitations", async (
                Guid id, InviteRequest body, ClaimsPrincipal user, MembershipService members, CancellationToken ct) =>
            (await members.InviteAsync(user.GetUserId(), id, body.Username, ct)).ToHttpResult());

        groups.MapDelete("/{id:guid}/invitations/{userId:guid}", async (
                Guid id, Guid userId, ClaimsPrincipal user, MembershipService members, CancellationToken ct) =>
            (await members.RevokeInvitationAsync(user.GetUserId(), id, userId, ct)).ToHttpResult());

        groups.MapPost("/{id:guid}/invite-links", async (
                Guid id, CreateInviteLinkRequest body, ClaimsPrincipal user, InviteLinkService links, CancellationToken ct) =>
            (await links.CreateAsync(user.GetUserId(), id, body, ct)).ToHttpResult());

        groups.MapDelete("/{id:guid}/invite-links/{linkId:guid}", async (
                Guid id, Guid linkId, ClaimsPrincipal user, InviteLinkService links, CancellationToken ct) =>
            (await links.RevokeAsync(user.GetUserId(), id, linkId, staff: false, ct)).ToHttpResult());

        app.MapPost("/invites/{code}/acceptance", async (string code, ClaimsPrincipal user, InviteLinkService links, CancellationToken ct) =>
            (await links.AcceptAsync(user.GetUserId(), code, ct)).ToHttpResult());

        // Link previews for WhatsApp and Instagram; anyone may open them.
        app.MapGet("/s/g/{handle}", async (string handle, GroupSharePages pages, CancellationToken ct) =>
                await pages.GroupAsync(handle, ct))
            .AllowAnonymous();

        app.MapGet("/s/i/{code}", async (string code, GroupSharePages pages, CancellationToken ct) =>
                await pages.InviteAsync(code, ct))
            .AllowAnonymous();

        groups.MapPut("/{id:guid}/members/{userId:guid}/roles/{role}", async (
                Guid id, Guid userId, string role, ClaimsPrincipal user, MembershipService members, CancellationToken ct) =>
            (await members.AssignRoleAsync(user.GetUserId(), id, userId, role, ct)).ToHttpResult());

        groups.MapDelete("/{id:guid}/members/{userId:guid}/roles/{role}", async (
                Guid id, Guid userId, string role, ClaimsPrincipal user, MembershipService members, CancellationToken ct) =>
            (await members.RemoveRoleAsync(user.GetUserId(), id, userId, role, ct)).ToHttpResult());

        return app;
    }
}
