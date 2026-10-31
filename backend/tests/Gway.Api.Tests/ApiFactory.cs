using System.Collections.Concurrent;
using System.Security.Claims;
using System.Text;
using Gway.Modules.Billing.Providers;
using Gway.Modules.Identity;
using Gway.Modules.Live;
using Gway.Modules.Notifications;
using Gway.SharedKernel.Supabase;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.IdentityModel.JsonWebTokens;
using Microsoft.IdentityModel.Tokens;

namespace Gway.Api.Tests;

public sealed class ApiFactory : WebApplicationFactory<Program>
{
    public const string SupabaseUrl = "http://supabase.test";
    public const string Issuer = SupabaseUrl + "/auth/v1";
    public const string JwtSecret = "test-only-secret-that-is-at-least-32-characters";
    public const int PermitsPerMinute = 20;

    public FakeStorage Storage { get; } = new();

    public FakePaymentProviders Payments { get; } = new();

    internal FakeLiveKit LiveKit { get; } = new();

    internal FakePush Push { get; } = new();

    internal FakeSms Sms { get; } = new();

    public FakeTiles Tiles { get; } = new();

    /// <summary>The web app origin passkeys are created on in tests.</summary>
    public const string PasskeyOrigin = "http://localhost:3000";

    public const string LiveKitSecret = "livekit-test-secret-that-is-long-enough";

    /// <summary>Request header that sets the buyer's country in tests (a trusted proxy header in production).</summary>
    public const string CountryHeader = "X-Test-Country";

    public const string PaytrKey = "paytr-test-key";
    public const string PaytrSalt = "paytr-test-salt";
    public const string IyzicoSecret = "iyzico-test-secret";

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Testing");
        builder.UseSetting("Supabase:Url", SupabaseUrl);
        builder.UseSetting("Supabase:JwtSecret", JwtSecret);
        builder.UseSetting("Supabase:ServiceRoleKey", "test-service-role-key");
        builder.UseSetting("ConnectionStrings:Database", TestDatabase.ConnectionString);
        builder.UseSetting("Identity:PurgeInterval", "00:00:00");
        builder.UseSetting("Cors:AllowedOrigins:0", "http://localhost:3000");
        builder.UseSetting("RateLimiting:PermitsPerMinute", PermitsPerMinute.ToString(System.Globalization.CultureInfo.InvariantCulture));
        builder.UseSetting("RateLimiting:SensitivePermitsPer10Minutes", "1000");
        builder.UseSetting("Billing:AppUrl", "http://localhost:3000");
        builder.UseSetting("Share:AppUrl", "http://localhost:3000");
        builder.UseSetting("Billing:PublicApiUrl", "http://api.test");
        builder.UseSetting("Geo:CountryHeader", CountryHeader);
        builder.UseSetting("Billing:Paytr:MerchantId", "123456");
        builder.UseSetting("Billing:Paytr:MerchantKey", PaytrKey);
        builder.UseSetting("Billing:Paytr:MerchantSalt", PaytrSalt);
        builder.UseSetting("Billing:Paytr:BaseUrl", FakePaymentProviders.PaytrUrl);
        builder.UseSetting("Billing:Iyzico:ApiKey", "iyzico-test-key");
        builder.UseSetting("Billing:Iyzico:SecretKey", IyzicoSecret);
        builder.UseSetting("Billing:Iyzico:BaseUrl", FakePaymentProviders.IyzicoUrl);
        builder.UseSetting("LiveKit:Url", "wss://livekit.test");
        builder.UseSetting("LiveKit:ApiKey", "livekit-test-key");
        builder.UseSetting("LiveKit:ApiSecret", LiveKitSecret);
        builder.UseSetting("Live:MonitorInterval", "00:00:00");
        builder.UseSetting("Events:ReminderInterval", "00:00:00");
        builder.UseSetting("Moderation:MonitorInterval", "00:00:00");
        builder.UseSetting("Messaging:ArchivePurgeInterval", "00:00:00");
        builder.UseSetting("Push:DispatchInterval", "00:00:00");
        builder.UseSetting("Map:TileUrl", FakeTiles.Url);
        builder.UseSetting("Security:Passkeys:RelyingPartyId", "localhost");
        builder.UseSetting("Security:Passkeys:Origins:0", PasskeyOrigin);
        builder.UseSetting("Map:ApiKey", FakeTiles.ApiKey);

        builder.ConfigureTestServices(services =>
        {
            services.RemoveAll<ISupabaseStorage>();
            services.AddSingleton<ISupabaseStorage>(Storage);
            services.RemoveAll<ISmsVerifier>();
            services.AddSingleton<ISmsVerifier>(Sms);
            services.RemoveAll<ILiveKit>();
            services.AddSingleton<ILiveKit>(LiveKit);
            services.RemoveAll<IPushSender>();
            services.AddSingleton<IPushSender>(Push);
            services.AddHttpClient<PaytrClient>().ConfigurePrimaryHttpMessageHandler(() => new FakePaymentHandler(Payments));
            services.AddHttpClient<IyzicoClient>().ConfigurePrimaryHttpMessageHandler(() => new FakePaymentHandler(Payments));
            services.AddHttpClient(nameof(Endpoints.MapTileEndpoints)).ConfigurePrimaryHttpMessageHandler(Tiles.Handler);
        });
    }

    public HttpClient ClientFor(Guid userId)
    {
        var client = CreateClient();
        client.DefaultRequestHeaders.Authorization = new("Bearer", CreateToken(userId));
        return client;
    }

    /// <summary>A client for one Supabase Auth session, with the role the token hook gave it (docs/ARCHITECTURE.md §3h).</summary>
    public HttpClient ClientFor(Guid userId, Guid sessionId, string role = "authenticated")
    {
        var client = CreateClient();
        client.DefaultRequestHeaders.Authorization = new("Bearer", CreateToken(userId, sessionId: sessionId, role: role));
        return client;
    }

    public static string CreateToken(
        Guid userId,
        string issuer = Issuer,
        string audience = "authenticated",
        string secret = JwtSecret,
        DateTime? expires = null,
        Guid? sessionId = null,
        string role = "authenticated")
    {
        var now = DateTime.UtcNow;
        var descriptor = new SecurityTokenDescriptor
        {
            Issuer = issuer,
            Audience = audience,
            Subject = new ClaimsIdentity([
                new Claim("sub", userId.ToString()),
                new Claim("role", role),
                .. sessionId is { } sid ? new[] { new Claim("session_id", sid.ToString()) } : [],
            ]),
            NotBefore = now.AddMinutes(-10),
            IssuedAt = now.AddMinutes(-10),
            Expires = expires ?? now.AddMinutes(10),
            SigningCredentials = new SigningCredentials(
                new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secret)),
                SecurityAlgorithms.HmacSha256),
        };
        return new JsonWebTokenHandler().CreateToken(descriptor);
    }
}

public sealed class FakeStorage : ISupabaseStorage
{
    public ConcurrentBag<(string Bucket, string Folder)> DeletedFolders { get; } = [];

    public ConcurrentBag<(string Bucket, string Path)> DeletedObjects { get; } = [];

    public Task DeleteFolderAsync(string bucket, string folder, CancellationToken ct)
    {
        DeletedFolders.Add((bucket, folder));
        return Task.CompletedTask;
    }

    public Task DeleteObjectsAsync(string bucket, IReadOnlyList<string> paths, CancellationToken ct)
    {
        foreach (var path in paths) DeletedObjects.Add((bucket, path));
        return Task.CompletedTask;
    }

    public Task<IReadOnlyDictionary<string, string>> CreateSignedUrlsAsync(
        string bucket, IReadOnlyList<string> paths, TimeSpan lifetime, CancellationToken ct) =>
        Task.FromResult<IReadOnlyDictionary<string, string>>(paths.ToDictionary(p => p, p => $"https://storage.test/{bucket}/{p}?signed"));
}
