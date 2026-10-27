using System.Security.Claims;
using GrupX.Modules.Billing.Contracts;
using GrupX.Modules.Billing.Providers;
using GrupX.SharedKernel.Geo;
using GrupX.SharedKernel.Http;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.Extensions.Options;

namespace GrupX.Modules.Billing;

public static class BillingModule
{
    private static readonly TimeSpan ProviderTimeout = TimeSpan.FromSeconds(20);

    public static IServiceCollection AddBillingModule(this IServiceCollection services)
    {
        services.AddOptions<BillingOptions>().BindConfiguration(BillingOptions.Section);
        services.TryAddSingleton(TimeProvider.System);
        services.AddGeo();
        services.AddHttpClient<PaytrClient>(http => http.Timeout = ProviderTimeout);
        services.AddHttpClient<IyzicoClient>(http => http.Timeout = ProviderTimeout);
        services.AddScoped<CheckoutService>();
        services.AddScoped<PaymentService>();
        services.AddScoped<IBillingAdministration, BillingAdministration>();
        services.AddSingleton<IGroupPlanLimits, GroupPlanLimitsReader>();
        return services;
    }

    /// <summary>Checkout for group owners and the providers' notifications. Plans are read from Supabase.</summary>
    public static IEndpointRouteBuilder MapBillingEndpoints(this IEndpointRouteBuilder app)
    {
        var billing = app.MapGroup("/billing");

        billing.MapGet("/groups/{id:guid}/offer", async (
                Guid id, HttpContext http, ClaimsPrincipal user, CheckoutService checkout, CountryResolver geo, CancellationToken ct) =>
            (await checkout.GetOfferAsync(user.GetUserId(), id, geo.MarketOf(http), ct)).ToHttpResult());

        billing.MapPost("/groups/{id:guid}/orders", async (
                Guid id, CreateOrderRequest body, HttpContext http, ClaimsPrincipal user,
                CheckoutService checkout, CountryResolver geo, CancellationToken ct) =>
            (await checkout.CreateOrderAsync(user.GetUserId(), id, body, geo.MarketOf(http), http.Connection.RemoteIpAddress, ct)).ToHttpResult())
            .RequireRateLimiting(RateLimitPolicies.Sensitive);

        // Personal plans (Eşleşme Premium): the buyer is the signed-in person.
        billing.MapGet("/me/plans/{slug}/offer", async (
                string slug, HttpContext http, ClaimsPrincipal user, CheckoutService checkout, CountryResolver geo, CancellationToken ct) =>
            (await checkout.GetPersonalOfferAsync(user.GetUserId(), slug, geo.MarketOf(http), ct)).ToHttpResult());

        billing.MapPost("/me/plans/{slug}/orders", async (
                string slug, CreatePersonalOrderRequest body, HttpContext http, ClaimsPrincipal user,
                CheckoutService checkout, CountryResolver geo, CancellationToken ct) =>
            (await checkout.CreatePersonalOrderAsync(user.GetUserId(), slug, body, geo.MarketOf(http), http.Connection.RemoteIpAddress, ct))
                .ToHttpResult())
            .RequireRateLimiting(RateLimitPolicies.Sensitive);

        // PayTR retries until it reads a plain "OK".
        billing.MapPost("/paytr/notify", async (HttpRequest request, PaymentService payments, CancellationToken ct) =>
                request.HasFormContentType && await payments.HandlePaytrAsync(await request.ReadFormAsync(ct), ct)
                    ? Results.Text("OK")
                    : Results.BadRequest())
            .AllowAnonymous()
            .DisableRateLimiting();

        // The buyer's browser comes back here; the answer comes from iyzico, not from this request.
        billing.MapPost("/iyzico/callback", async (
                Guid? order, HttpRequest request, PaymentService payments, IOptions<BillingOptions> options, CancellationToken ct) =>
            {
                var token = request.HasFormContentType ? (await request.ReadFormAsync(ct))["token"].ToString() : "";
                var settled = token.Length > 0 ? await payments.HandleIyzicoAsync(order, token, ct) : null;
                var target = settled switch
                {
                    { PersonalPlan: { } personal } => BillingLinks.Personal(options.Value, personal, settled.Id),
                    { GroupHandle: { } handle } => BillingLinks.Plan(options.Value, handle, settled.Id),
                    _ => new Uri(options.Value.AppUrl.TrimEnd('/') + "/"),
                };
                request.HttpContext.Response.Headers.Location = target.ToString();
                return Results.StatusCode(StatusCodes.Status303SeeOther);
            })
            .AllowAnonymous();

        billing.MapPost("/iyzico/webhook", async (HttpRequest request, IyzicoClient iyzico, PaymentService payments, CancellationToken ct) =>
            {
                using var reader = new StreamReader(request.Body);
                var webhook = IyzicoClient.ParseWebhook(await reader.ReadToEndAsync(ct));
                if (webhook is null || !iyzico.VerifyWebhook(request.Headers["X-IYZ-SIGNATURE-V3"], webhook)) return Results.Unauthorized();
                await payments.HandleIyzicoAsync(null, webhook.Token, ct);
                return Results.Ok();
            })
            .AllowAnonymous()
            .DisableRateLimiting();

        return app;
    }
}
