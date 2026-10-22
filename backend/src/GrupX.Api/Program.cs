using System.Net;
using GrupX.Api.Auth;
using GrupX.Api.Endpoints;
using GrupX.Api.Http;
using GrupX.Modules.Admin;
using GrupX.Modules.Billing;
using GrupX.Modules.Events;
using GrupX.Modules.Feed;
using GrupX.Modules.Groups;
using GrupX.Modules.Identity;
using GrupX.Modules.Messaging;
using GrupX.Modules.Live;
using GrupX.Modules.Moderation;
using GrupX.Modules.Profile;
using GrupX.Modules.Support;
using GrupX.SharedKernel.Supabase;
using Microsoft.AspNetCore.HttpOverrides;
using Npgsql;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddProblemDetails();
builder.Services.AddSupabaseAuthentication(builder.Configuration);
builder.Services.AddApiRateLimiting(builder.Configuration);
builder.Services.AddHealthChecks();

// Behind a reverse proxy, only the listed proxies may name the client IP (rate limits, payment country).
var knownProxies = builder.Configuration.GetSection("ReverseProxy:KnownProxies").Get<string[]>() ?? [];
var knownNetworks = builder.Configuration.GetSection("ReverseProxy:KnownNetworks").Get<string[]>() ?? [];
builder.Services.Configure<ForwardedHeadersOptions>(options =>
{
    options.ForwardedHeaders = ForwardedHeaders.XForwardedFor;
    options.KnownProxies.Clear();
    options.KnownIPNetworks.Clear();
    foreach (var proxy in knownProxies) options.KnownProxies.Add(IPAddress.Parse(proxy));
    foreach (var network in knownNetworks) options.KnownIPNetworks.Add(System.Net.IPNetwork.Parse(network));
});

// Web clients (social app, admin panel) call the API from their own origins.
var allowedOrigins = builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>() ?? [];
builder.Services.AddCors(options => options.AddDefaultPolicy(policy => policy
    .WithOrigins(allowedOrigins)
    .WithMethods("GET", "POST", "PUT", "PATCH", "DELETE")
    .WithHeaders("Authorization", "Content-Type", "Accept")));

builder.Services.AddSingleton(sp => NpgsqlDataSource.Create(
    sp.GetRequiredService<IConfiguration>().GetConnectionString("Database")
    ?? throw new InvalidOperationException("ConnectionStrings:Database is not configured.")));
builder.Services.AddHttpClient<ISupabaseStorage, SupabaseStorage>();
builder.Services.AddMapTiles();

builder.Services.AddIdentityModule();
builder.Services.AddGroupsModule();
builder.Services.AddBillingModule();
builder.Services.AddSupportModule();
builder.Services.AddProfileModule();
builder.Services.AddFeedModule();
builder.Services.AddEventsModule();
builder.Services.AddLiveModule();
builder.Services.AddModerationModule();
builder.Services.AddMessagingModule();
builder.Services.AddAdminModule();

var app = builder.Build();

if (knownProxies.Length > 0 || knownNetworks.Length > 0) app.UseForwardedHeaders();

app.UseExceptionHandler();
app.UseStatusCodePages();

app.UseCors();
app.UseAuthentication();
app.UseRateLimiter();
app.UseAuthorization();

app.MapHealthChecks("/health").AllowAnonymous().DisableRateLimiting();
app.MapMeEndpoints();
app.MapIdentityEndpoints();
app.MapGroupsEndpoints();
app.MapBillingEndpoints();
app.MapProfileEndpoints();
app.MapFeedEndpoints();
app.MapEventsEndpoints();
app.MapLiveEndpoints();
app.MapModerationEndpoints();
app.MapMessagingEndpoints();
app.MapAdminEndpoints();
app.MapMapTileEndpoints();

app.Run();

public partial class Program;
