using System.Security.Claims;

namespace Gway.Api.Endpoints;

public static class MeEndpoints
{
    public sealed record MeResponse(Guid UserId);

    /// <summary>Returns the caller's Supabase user id; verifies the JWT pipeline end to end.</summary>
    public static IEndpointRouteBuilder MapMeEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapGet("/me", (ClaimsPrincipal user) =>
            Guid.TryParse(user.Identity?.Name, out var id)
                ? Results.Ok(new MeResponse(id))
                : Results.Unauthorized());

        return app;
    }
}
