using System.Buffers.Text;
using System.Net;
using System.Net.Http.Json;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Options;

namespace Gway.Modules.Notifications;

/// <summary><c>Push</c> configuration (docs/ARCHITECTURE.md §3c, Push). The key file stays out of the repository.</summary>
public sealed class PushOptions
{
    public const string Section = "Push";

    /// <summary>The Firebase service account key (JSON). Empty turns push off.</summary>
    public string CredentialsPath { get; set; } = "";

    public bool IsConfigured => CredentialsPath.Length > 0;
}

/// <summary>What the phone shows; <see cref="Data"/> tells the app what to open on a tap.</summary>
/// <summary>
/// What the phone shows; <see cref="Data"/> tells the app what to open on a tap. <see cref="Channel"/> is the Android channel
/// (default: general); notifications with the same <see cref="Tag"/> replace each other on the phone.
/// With <see cref="AppHandlesFor"/> Android gets a data-only message, valid that long, that the app turns into its own
/// screen (the incoming call, docs/ARCHITECTURE.md §8c); <see cref="Silent"/> shows nothing on iOS either.
/// </summary>
internal sealed record PushMessage(
    string Title, string Body, IReadOnlyDictionary<string, string> Data, string? Channel = null, string? Tag = null,
    TimeSpan? AppHandlesFor = null, bool Silent = false);

internal enum PushResult
{
    Sent,

    /// <summary>The app was removed or signed out; the token is dropped.</summary>
    Unregistered,
    Failed,
}

/// <summary>Sends one message to one device. Tests replace it with a fake.</summary>
internal interface IPushSender
{
    bool IsConfigured { get; }

    Task<PushResult> SendAsync(string token, PushMessage message, CancellationToken ct);

    /// <summary>Asks FCM whether the token still reaches an app, without showing anything on the phone.</summary>
    Task<PushResult> ProbeAsync(string token, CancellationToken ct);
}

/// <summary>FCM HTTP v1 with a service account token signed here (RS256; no SDK needed).</summary>
internal sealed class FcmClient(HttpClient http, IOptions<PushOptions> options, TimeProvider time) : IPushSender
{
    private const string Scope = "https://www.googleapis.com/auth/firebase.messaging";
    private static readonly TimeSpan TokenLifetime = TimeSpan.FromHours(1);

    private readonly SemaphoreSlim _tokenLock = new(1, 1);
    private ServiceAccount? _account;
    private (string Value, DateTimeOffset Expires)? _token;

    private sealed record ServiceAccount(string ProjectId, string ClientEmail, string PrivateKey, string TokenUri);

    public bool IsConfigured => options.Value.IsConfigured;

    /// <summary>Android channels the app creates (MainActivity); all ring with the phone's sound and pop up.</summary>
    internal const string MessagesChannel = "gway_messages";
    internal const string GeneralChannel = "gway_general";
    internal const string CallsChannel = "gway_calls";

    /// <summary>FCM refuses explicit nulls in some fields (e.g. <c>tag</c>); unset ones are left out.</summary>
    private static readonly JsonSerializerOptions OmitNulls = new() { DefaultIgnoreCondition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingNull };

    public Task<PushResult> SendAsync(string token, PushMessage message, CancellationToken ct)
    {
        if (message.AppHandlesFor is { } validFor)
        {
            return PostAsync(new
            {
                message = new
                {
                    token,
                    data = new Dictionary<string, string>(message.Data) { ["title"] = message.Title, ["body"] = message.Body },
                    android = new
                    {
                        priority = "HIGH",
                        ttl = $"{(int)validFor.TotalSeconds}s",
                    },
                    apns = message.Silent
                        ? null
                        : new { payload = new { aps = new { alert = new { title = message.Title, body = message.Body }, sound = "default" } } },
                },
            }, ct);
        }
        return PostAsync(new
        {
            message = new
            {
                token,
                notification = new { title = message.Title, body = message.Body },
                data = message.Data,
                android = new
                {
                    priority = "HIGH",
                    notification = new
                    {
                        sound = "default",
                        channel_id = message.Channel ?? GeneralChannel,
                        tag = message.Tag,
                    },
                },
                apns = new { payload = new { aps = new { sound = "default" } } },
            },
        }, ct);
    }

    /// <summary>FCM's dry run (<c>validate_only</c>) checks the token and delivers nothing.</summary>
    public Task<PushResult> ProbeAsync(string token, CancellationToken ct) =>
        PostAsync(new { validate_only = true, message = new { token } }, ct);

    private async Task<PushResult> PostAsync(object body, CancellationToken ct)
    {
        var account = await AccountAsync(ct);
        using var request = new HttpRequestMessage(HttpMethod.Post,
            new Uri($"https://fcm.googleapis.com/v1/projects/{account.ProjectId}/messages:send"));
        request.Headers.Authorization = new("Bearer", await AccessTokenAsync(account, ct));
        request.Content = JsonContent.Create(body, options: OmitNulls);
        using var response = await http.SendAsync(request, ct);
        if (response.IsSuccessStatusCode) return PushResult.Sent;
        var error = await response.Content.ReadAsStringAsync(ct);
        return response.StatusCode == HttpStatusCode.NotFound || error.Contains("\"UNREGISTERED\"", StringComparison.Ordinal)
            ? PushResult.Unregistered
            : PushResult.Failed;
    }

    private async Task<ServiceAccount> AccountAsync(CancellationToken ct)
    {
        if (_account is { } account) return account;
        await using var file = File.OpenRead(options.Value.CredentialsPath);
        using var json = await JsonDocument.ParseAsync(file, cancellationToken: ct);
        var root = json.RootElement;
        return _account = new ServiceAccount(
            root.GetProperty("project_id").GetString()!,
            root.GetProperty("client_email").GetString()!,
            root.GetProperty("private_key").GetString()!,
            root.GetProperty("token_uri").GetString()!);
    }

    /// <summary>One OAuth token an hour, renewed five minutes early.</summary>
    private async Task<string> AccessTokenAsync(ServiceAccount account, CancellationToken ct)
    {
        await _tokenLock.WaitAsync(ct);
        try
        {
            if (_token is { } cached && cached.Expires > time.GetUtcNow().AddMinutes(5)) return cached.Value;

            using var form = new FormUrlEncodedContent(new Dictionary<string, string>
            {
                ["grant_type"] = "urn:ietf:params:oauth:grant-type:jwt-bearer",
                ["assertion"] = Assertion(account),
            });
            using var response = await http.PostAsync(new Uri(account.TokenUri), form, ct);
            response.EnsureSuccessStatusCode();
            using var json = await JsonDocument.ParseAsync(await response.Content.ReadAsStreamAsync(ct), cancellationToken: ct);
            var value = json.RootElement.GetProperty("access_token").GetString()!;
            var expires = time.GetUtcNow().AddSeconds(json.RootElement.GetProperty("expires_in").GetInt32());
            _token = (value, expires);
            return value;
        }
        finally
        {
            _tokenLock.Release();
        }
    }

    private string Assertion(ServiceAccount account)
    {
        var now = time.GetUtcNow().ToUnixTimeSeconds();
        var header = Base64Url.EncodeToString("""{"alg":"RS256","typ":"JWT"}"""u8);
        var payload = Base64Url.EncodeToString(JsonSerializer.SerializeToUtf8Bytes(new Dictionary<string, object>
        {
            ["iss"] = account.ClientEmail,
            ["scope"] = Scope,
            ["aud"] = account.TokenUri,
            ["iat"] = now,
            ["exp"] = now + (long)TokenLifetime.TotalSeconds,
        }));
        using var rsa = RSA.Create();
        rsa.ImportFromPem(account.PrivateKey);
        var signature = rsa.SignData(Encoding.ASCII.GetBytes($"{header}.{payload}"), HashAlgorithmName.SHA256, RSASignaturePadding.Pkcs1);
        return $"{header}.{payload}.{Base64Url.EncodeToString(signature)}";
    }
}
