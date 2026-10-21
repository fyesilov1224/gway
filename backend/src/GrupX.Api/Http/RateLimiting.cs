using System.Threading.RateLimiting;
using GrupX.SharedKernel.Http;

namespace GrupX.Api.Http;

public static class RateLimiting
{
    public static IServiceCollection AddApiRateLimiting(this IServiceCollection services, IConfiguration configuration)
    {
        var permitsPerMinute = configuration.GetValue("RateLimiting:PermitsPerMinute", 120);
        var sensitivePermits = configuration.GetValue("RateLimiting:SensitivePermitsPer10Minutes", 10);

        services.AddRateLimiter(options =>
        {
            options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;

            // Signed-in users are limited by user id, anonymous callers by IP.
            options.GlobalLimiter = PartitionedRateLimiter.Create<HttpContext, string>(context =>
            {
                var key = context.User.Identity?.IsAuthenticated == true
                    ? $"user:{context.User.Identity.Name}"
                    : $"ip:{context.Connection.RemoteIpAddress}";

                return RateLimitPartition.GetFixedWindowLimiter(key, _ => new FixedWindowRateLimiterOptions
                {
                    PermitLimit = permitsPerMinute,
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
