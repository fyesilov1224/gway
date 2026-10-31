using System.Threading.RateLimiting;
using Gway.Api.Endpoints;
using Gway.SharedKernel.Http;

namespace Gway.Api.Http;

public static class RateLimiting
{
    public static IServiceCollection AddApiRateLimiting(this IServiceCollection services, IConfiguration configuration)
    {
        var permitsPerMinute = configuration.GetValue("RateLimiting:PermitsPerMinute", 120);
        var sensitivePermits = configuration.GetValue("RateLimiting:SensitivePermitsPer10Minutes", 10);
        var tilePermits = configuration.GetValue("RateLimiting:MapTilesPerMinute", 600);

        services.AddRateLimiter(options =>
        {
            options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;

            // Signed-in users are limited by user id, anonymous callers by IP. A map view loads dozens of
            // tiles at once, so tiles have their own, larger allowance.
            options.GlobalLimiter = PartitionedRateLimiter.Create<HttpContext, string>(context =>
            {
                var key = context.User.Identity?.IsAuthenticated == true
                    ? $"user:{context.User.Identity.Name}"
                    : $"ip:{context.Connection.RemoteIpAddress}";
                var tiles = context.Request.Path.StartsWithSegments(MapTileEndpoints.PathPrefix.TrimEnd('/'), StringComparison.Ordinal);

                return RateLimitPartition.GetFixedWindowLimiter(tiles ? $"tiles:{key}" : key, _ => new FixedWindowRateLimiterOptions
                {
                    PermitLimit = tiles ? tilePermits : permitsPerMinute,
                    Window = TimeSpan.FromMinutes(1),
                    QueueLimit = 0,
                });
            });

            // Checkout and similar calls: a handful per user every ten minutes.
            options.AddPolicy(RateLimitPolicies.Sensitive, context =>
                RateLimitPartition.GetFixedWindowLimiter($"user:{context.User.Identity?.Name ?? context.Connection.RemoteIpAddress?.ToString()}", _ =>
                    new FixedWindowRateLimiterOptions
                    {
                        PermitLimit = sensitivePermits,
                        Window = TimeSpan.FromMinutes(10),
                        QueueLimit = 0,
                    }));
        });

        return services;
    }
}
