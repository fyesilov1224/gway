using System.Security.Claims;
using Fido2NetLib;
using GrupX.Modules.Identity.Contracts;
using GrupX.SharedKernel;
using GrupX.SharedKernel.Geo;
using GrupX.SharedKernel.Http;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Options;

namespace GrupX.Modules.Identity;

public static class IdentityModule
{
    private static readonly TimeSpan TwilioTimeout = TimeSpan.FromSeconds(15);

    public static IServiceCollection AddIdentityModule(this IServiceCollection services)
    {
        services.AddSingleton<AccountService>();
        services.AddSingleton<IAccountAdministration>(sp => sp.GetRequiredService<AccountService>());
        services.AddSingleton<IAccountSanctions>(sp => sp.GetRequiredService<AccountService>());
        services.AddSingleton<AccountPurger>();
        services.AddHostedService<AccountPurgeService>();

        // Security verification (docs/ARCHITECTURE.md §3h). Without Twilio keys, Development logs codes instead.
        services.AddOptions<SecurityOptions>().BindConfiguration(SecurityOptions.Section);
        services.AddGeo();
        services.TryAddSingleton(TimeProvider.System);
        services.AddHttpClient(TwilioVerifier.HttpClientName, http => http.Timeout = TwilioTimeout);
        services.AddSingleton<TwilioVerifier>();
        services.AddSingleton<DevSmsVerifier>();
        services.TryAddSingleton<ISmsVerifier>(sp =>
            !sp.GetRequiredService<IOptions<SecurityOptions>>().Value.Twilio.IsConfigured
            && sp.GetRequiredService<IHostEnvironment>().IsDevelopment()
                ? sp.GetRequiredService<DevSmsVerifier>()
                : sp.GetRequiredService<TwilioVerifier>());
        services.AddSingleton<SecurityService>();
        services.AddSingleton<PasskeyService>();
        services.AddSingleton<ISecurityAdministration, SecurityAdministration>();
        return services;
    }

    public static IEndpointRouteBuilder MapIdentityEndpoints(this IEndpointRouteBuilder app)
    {
        var account = app.MapGroup("/account");

        // A suspended or unverified session still needs its account state to show the right screen.
        account.MapGet("", async (ClaimsPrincipal user, AccountService accounts, CancellationToken ct) =>
                (await accounts.GetAsync(user.GetUserId(), ct)).ToHttpResult())
            .RequireAuthorization(AuthPolicies.AllowUnverified);

        account.MapPost("/deletion", async (ClaimsPrincipal user, AccountService accounts, CancellationToken ct) =>
            (await accounts.RequestDeletionAsync(user.GetUserId(), ct)).ToHttpResult());

        account.MapDelete("/deletion", async (ClaimsPrincipal user, AccountService accounts, CancellationToken ct) =>
            (await accounts.CancelDeletionAsync(user.GetUserId(), ct)).ToHttpResult());

        // The verification steps themselves: reachable before the session is verified.
        var security = app.MapGroup("/security").RequireAuthorization(AuthPolicies.AllowUnverified);

        security.MapGet("/status", async (ClaimsPrincipal user, SecurityService service, CancellationToken ct) =>
            TypedResults.Ok(await service.GetStatusAsync(user.GetUserId(), user.GetSessionId(), ct)));

        security.MapPost("/location", async (
                LocationSignals body, HttpContext http, ClaimsPrincipal user, SecurityService service, CancellationToken ct) =>
            (await service.RecordLocationAsync(user.GetUserId(), user.GetSessionId(), body, http, ct)).ToHttpResult());

        security.MapPost("/phone/start", async (PhoneStartRequest body, ClaimsPrincipal user, SecurityService service, CancellationToken ct) =>
                (await service.StartPhoneAsync(user.GetUserId(), body, ct)).ToHttpResult())
            .RequireRateLimiting(RateLimitPolicies.Sensitive);

        security.MapPost("/phone/verify", async (PhoneVerifyRequest body, ClaimsPrincipal user, SecurityService service, CancellationToken ct) =>
                (await service.VerifyPhoneAsync(user.GetUserId(), user.GetSessionId(), body, ct)).ToHttpResult())
            .RequireRateLimiting(RateLimitPolicies.Sensitive);

        security.MapPost("/second-factor/start", async (ClaimsPrincipal user, SecurityService service, CancellationToken ct) =>
                (await service.StartSecondFactorAsync(user.GetUserId(), ct)).ToHttpResult())
            .RequireRateLimiting(RateLimitPolicies.Sensitive);

        security.MapPost("/second-factor/verify", async (
                SecondFactorRequest body, ClaimsPrincipal user, SecurityService service, CancellationToken ct) =>
                (await service.VerifySecondFactorAsync(user.GetUserId(), user.GetSessionId(), body, ct)).ToHttpResult())
            .RequireRateLimiting(RateLimitPolicies.Sensitive);

        security.MapPost("/totp", async (ClaimsPrincipal user, SecurityService service, CancellationToken ct) =>
            (await service.BeginTotpAsync(user.GetUserId(), user.GetSessionId(), ct)).ToHttpResult());

        security.MapPost("/totp/confirm", async (TotpCodeRequest body, ClaimsPrincipal user, SecurityService service, CancellationToken ct) =>
                (await service.ConfirmTotpAsync(user.GetUserId(), body, ct)).ToHttpResult())
            .RequireRateLimiting(RateLimitPolicies.Sensitive);

        security.MapDelete("/totp", async (ClaimsPrincipal user, SecurityService service, CancellationToken ct) =>
            (await service.DeleteTotpAsync(user.GetUserId(), user.GetSessionId(), ct)).ToHttpResult());

        // Passkeys (fingerprint, face or screen lock through WebAuthn), docs/ARCHITECTURE.md §3h.
        security.MapPost("/passkeys/options", async (ClaimsPrincipal user, PasskeyService passkeys, CancellationToken ct) =>
                WebAuthnJson(await passkeys.RegistrationOptionsAsync(user.GetUserId(), user.GetSessionId(), ct)))
            .RequireRateLimiting(RateLimitPolicies.Sensitive);

        security.MapPost("/passkeys", async (PasskeyRegistration body, ClaimsPrincipal user, PasskeyService passkeys, CancellationToken ct) =>
                (await passkeys.RegisterAsync(user.GetUserId(), user.GetSessionId(), body, ct)).ToHttpResult())
            .RequireRateLimiting(RateLimitPolicies.Sensitive);

        security.MapGet("/passkeys", async (ClaimsPrincipal user, PasskeyService passkeys, CancellationToken ct) =>
            TypedResults.Ok(await passkeys.ListAsync(user.GetUserId(), ct)));

        security.MapDelete("/passkeys/{id}", async (string id, ClaimsPrincipal user, PasskeyService passkeys, CancellationToken ct) =>
            (await passkeys.DeleteAsync(user.GetUserId(), user.GetSessionId(), id, ct)).ToHttpResult());

        security.MapPost("/second-factor/passkey/options", async (ClaimsPrincipal user, PasskeyService passkeys, CancellationToken ct) =>
                WebAuthnJson(await passkeys.AssertionOptionsAsync(user.GetUserId(), ct)))
            .RequireRateLimiting(RateLimitPolicies.Sensitive);

        security.MapPost("/second-factor/passkey", async (
                AuthenticatorAssertionRawResponse body, ClaimsPrincipal user, PasskeyService passkeys, CancellationToken ct) =>
                (await passkeys.VerifyAsync(user.GetUserId(), user.GetSessionId(), body, ct)).ToHttpResult())
            .RequireRateLimiting(RateLimitPolicies.Sensitive);

        return app;
    }

    /// <summary>WebAuthn options are already JSON in the shape browsers expect; they go out as they are.</summary>
    private static IResult WebAuthnJson(Result<string> options) =>
        options.IsSuccess ? Results.Text(options.Value, "application/json") : options.Error.ToProblem();
}
