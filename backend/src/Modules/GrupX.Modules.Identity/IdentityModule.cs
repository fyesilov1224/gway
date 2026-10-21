using System.Security.Claims;
using GrupX.Modules.Identity.Contracts;
using GrupX.SharedKernel.Http;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;

namespace GrupX.Modules.Identity;

public static class IdentityModule
{
    public static IServiceCollection AddIdentityModule(this IServiceCollection services)
    {
        services.AddSingleton<AccountService>();
        services.AddSingleton<IAccountAdministration>(sp => sp.GetRequiredService<AccountService>());
        services.AddSingleton<AccountPurger>();
        services.AddHostedService<AccountPurgeService>();
        return services;
    }

    public static IEndpointRouteBuilder MapIdentityEndpoints(this IEndpointRouteBuilder app)
    {
        var account = app.MapGroup("/account");

        account.MapGet("", async (ClaimsPrincipal user, AccountService accounts, CancellationToken ct) =>
            (await accounts.GetAsync(user.GetUserId(), ct)).ToHttpResult());

        account.MapPost("/deletion", async (ClaimsPrincipal user, AccountService accounts, CancellationToken ct) =>
            (await accounts.RequestDeletionAsync(user.GetUserId(), ct)).ToHttpResult());

        account.MapDelete("/deletion", async (ClaimsPrincipal user, AccountService accounts, CancellationToken ct) =>
            (await accounts.CancelDeletionAsync(user.GetUserId(), ct)).ToHttpResult());

        return app;
    }
}
