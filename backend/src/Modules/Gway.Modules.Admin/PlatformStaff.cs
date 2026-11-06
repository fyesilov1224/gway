using Gway.SharedKernel;
using Gway.SharedKernel.Http;
using Microsoft.AspNetCore.Http;
using Npgsql;

namespace Gway.Modules.Admin;

internal static class StaffRoles
{
    public const string Admin = "admin";
    public const string Moderator = "moderator";
    public const string Support = "support";

    public static readonly string[] All = [Admin, Moderator, Support];
    public static readonly string[] CanSuspend = [Admin, Moderator];
    public static readonly string[] AdminOnly = [Admin];
    public static readonly string[] Billing = [Admin, Support];

    /// <summary>Who opens, declines and closes voice call permissions (docs/ARCHITECTURE.md §8c, Admin).</summary>
    public static readonly string[] CallPermissions = [Admin, Support];
}

/// <summary>Reads <c>public.platform_staff</c>, owned by this module.</summary>
internal sealed class PlatformStaff(NpgsqlDataSource db)
{
    public async Task<string?> GetRoleAsync(Guid userId, CancellationToken ct)
    {
        await using var cmd = db.CreateCommand("select role from public.platform_staff where user_id = @id");
        cmd.Parameters.AddWithValue("id", userId);
        return await cmd.ExecuteScalarAsync(ct) as string;
    }
}

/// <summary>Rejects callers who are not platform staff with one of the given roles.</summary>
internal sealed class RequireStaffFilter(params string[] roles) : IEndpointFilter
{
    private static readonly Error Forbidden = Error.Forbidden("admin.forbidden", "Bu işlem için yetkin yok.");

    public async ValueTask<object?> InvokeAsync(EndpointFilterInvocationContext context, EndpointFilterDelegate next)
    {
        var http = context.HttpContext;
        var staff = http.RequestServices.GetService(typeof(PlatformStaff)) as PlatformStaff
            ?? throw new InvalidOperationException("PlatformStaff is not registered.");

        var role = await staff.GetRoleAsync(http.User.GetUserId(), http.RequestAborted);
        if (role is null || !roles.Contains(role)) return Forbidden.ToProblem();

        return await next(context);
    }
}
