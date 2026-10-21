using System.Text;
using GrupX.SharedKernel.Supabase;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

namespace GrupX.Api.Auth;

public static class SupabaseAuthentication
{
    public const string Audience = "authenticated";

    public static IServiceCollection AddSupabaseAuthentication(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddOptions<SupabaseOptions>()
            .Bind(configuration.GetSection(SupabaseOptions.SectionName))
            .ValidateDataAnnotations()
            .ValidateOnStart();

        services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme).AddJwtBearer();

        services.AddOptions<JwtBearerOptions>(JwtBearerDefaults.AuthenticationScheme)
            .Configure<IOptions<SupabaseOptions>>((jwt, supabaseOptions) =>
            {
                var supabase = supabaseOptions.Value;

                jwt.MapInboundClaims = false;
                jwt.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidIssuer = supabase.Issuer,
                    ValidAudience = Audience,
                    NameClaimType = "sub",
                    RoleClaimType = "role",
                    ClockSkew = TimeSpan.FromSeconds(30),
                };

                if (!string.IsNullOrEmpty(supabase.JwtSecret))
                {
                    jwt.TokenValidationParameters.IssuerSigningKey =
                        new SymmetricSecurityKey(Encoding.UTF8.GetBytes(supabase.JwtSecret));
                    jwt.TokenValidationParameters.ValidAlgorithms = [SecurityAlgorithms.HmacSha256];
                }
                else
                {
                    jwt.Authority = supabase.Issuer;
                    jwt.RequireHttpsMetadata = supabase.Issuer.StartsWith("https://", StringComparison.Ordinal);
                }
            });

        services.AddAuthorizationBuilder()
            .SetFallbackPolicy(new Microsoft.AspNetCore.Authorization.AuthorizationPolicyBuilder()
                .RequireAuthenticatedUser()
                .Build());

        return services;
    }
}
