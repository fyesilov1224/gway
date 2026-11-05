using System.Net;
using Gway.Api.Auth;
using Gway.Api.Endpoints;
using Gway.Api.Http;
using Gway.Modules.Admin;
using Gway.Modules.Billing;
using Gway.Modules.Events;
using Gway.Modules.Feed;
using Gway.Modules.Games;
using Gway.Modules.Groups;
using Gway.Modules.Identity;
using Gway.Modules.Messaging;
using Gway.Modules.Live;
using Gway.Modules.Matching;
using Gway.Modules.Moderation;
using Gway.Modules.Notifications;
using Gway.Modules.Profile;
using Gway.Modules.Support;
using Gway.SharedKernel.Localization;
using Gway.SharedKernel.Supabase;
using Microsoft.AspNetCore.HttpOverrides;
using Npgsql;

var builder = WebApplication.CreateBuilder(args);

// Problem titles in the request's language (docs/ARCHITECTURE.md §11, Sunucu).
builder.Services.AddProblemDetails(options => options.CustomizeProblemDetails = ServerText.LocalizeProblem);
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
builder.Services.AddMatchingModule();
builder.Services.AddGamesModule();
builder.Services.AddNotificationsModule();
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
app.MapCallEndpoints();
app.MapModerationEndpoints();
app.MapMessagingEndpoints();
app.MapMatchingEndpoints();
app.MapGamesEndpoints();
app.MapAdminEndpoints();
app.MapMapTileEndpoints();

app.Run();

public partial class Program;
