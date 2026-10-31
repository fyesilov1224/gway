using System.Collections.Concurrent;
using System.Net;
using System.Net.Http.Headers;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using Gway.SharedKernel;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace Gway.Modules.Identity;

/// <summary>Sends and checks one-time SMS codes (docs/ARCHITECTURE.md §3h, Telefon).</summary>
internal interface ISmsVerifier
{
    bool IsConfigured { get; }

    Task<Result> SendAsync(string phone, string locale, CancellationToken ct);

    /// <summary>False for a wrong or expired code.</summary>
    Task<Result<bool>> CheckAsync(string phone, string code, CancellationToken ct);

    /// <summary>The carrier's line type (<c>mobile</c>, <c>nonFixedVoip</c>…), or null when lookup is off or unknown.</summary>
    Task<string?> LineTypeAsync(string phone, CancellationToken ct);
}

internal static class SmsErrors
{
    public static readonly Error NotConfigured = Error.Unavailable(
        "security.sms_not_configured", "Telefon doğrulaması şu anda kullanılamıyor. Lütfen daha sonra tekrar dene.");

    public static readonly Error RateLimited = Error.RuleViolation(
        "security.sms_rate_limited", "Çok fazla kod istedin. Biraz bekleyip tekrar dene.");

    public static readonly Error Failed = Error.Unavailable(
        "security.sms_failed", "Kod gönderilemedi. Lütfen biraz sonra tekrar dene.");
}

/// <summary>Twilio Verify (codes) and Lookup v2 (line type), over plain HTTPS.</summary>
internal sealed partial class TwilioVerifier(IHttpClientFactory httpFactory, IOptions<SecurityOptions> options, ILogger<TwilioVerifier> logger)
    : ISmsVerifier
{
    public const string HttpClientName = "twilio";

    private TwilioOptions Twilio => options.Value.Twilio;

    public bool IsConfigured => Twilio.IsConfigured;

    public async Task<Result> SendAsync(string phone, string locale, CancellationToken ct)
    {
        if (!IsConfigured) return SmsErrors.NotConfigured;
        using var response = await PostAsync($"{Twilio.VerifyBaseUrl}/v2/Services/{Twilio.VerifyServiceSid}/Verifications",
            [new("To", phone), new("Channel", "sms"), new("Locale", locale)], ct);
        if (response.IsSuccessStatusCode) return Result.Success();

        var code = await ErrorCodeAsync(response, ct);
        LogTwilioError(logger, "verification", (int)response.StatusCode, code);
        // 60203: too many sends to this number; 60410: Twilio fraud guard blocked the prefix.
        return response.StatusCode == HttpStatusCode.TooManyRequests || code is 60203 or 60410
            ? SmsErrors.RateLimited
            : SmsErrors.Failed;
    }

    public async Task<Result<bool>> CheckAsync(string phone, string code, CancellationToken ct)
    {
        if (!IsConfigured) return SmsErrors.NotConfigured;
        using var response = await PostAsync($"{Twilio.VerifyBaseUrl}/v2/Services/{Twilio.VerifyServiceSid}/VerificationCheck",
            [new("To", phone), new("Code", code)], ct);
        // 404: no pending verification (expired, used up or never sent).
        if (response.StatusCode == HttpStatusCode.NotFound) return false;
        if (!response.IsSuccessStatusCode)
        {
            var error = await ErrorCodeAsync(response, ct);
            LogTwilioError(logger, "check", (int)response.StatusCode, error);
            return response.StatusCode == HttpStatusCode.TooManyRequests || error == 60202 ? SmsErrors.RateLimited : SmsErrors.Failed;
        }
        using var json = await JsonDocument.ParseAsync(await response.Content.ReadAsStreamAsync(ct), cancellationToken: ct);
        return json.RootElement.TryGetProperty("status", out var status) && status.GetString() == "approved";
    }

    public async Task<string?> LineTypeAsync(string phone, CancellationToken ct)
    {
        if (!IsConfigured || !Twilio.LookupLineType) return null;
        using var request = new HttpRequestMessage(HttpMethod.Get,
            $"{Twilio.LookupBaseUrl}/v2/PhoneNumbers/{Uri.EscapeDataString(phone)}?Fields=line_type_intelligence");
        Authorize(request);
        using var response = await httpFactory.CreateClient(HttpClientName).SendAsync(request, ct);
        if (!response.IsSuccessStatusCode)
        {
            LogTwilioError(logger, "lookup", (int)response.StatusCode, await ErrorCodeAsync(response, ct));
            return null;
        }
        using var json = await JsonDocument.ParseAsync(await response.Content.ReadAsStreamAsync(ct), cancellationToken: ct);
        return json.RootElement.TryGetProperty("line_type_intelligence", out var info)
               && info.ValueKind == JsonValueKind.Object
               && info.TryGetProperty("type", out var type)
            ? type.GetString()
            : null;
    }

    private async Task<HttpResponseMessage> PostAsync(string url, KeyValuePair<string, string>[] form, CancellationToken ct)
    {
        using var request = new HttpRequestMessage(HttpMethod.Post, url) { Content = new FormUrlEncodedContent(form) };
        Authorize(request);
        return await httpFactory.CreateClient(HttpClientName).SendAsync(request, ct);
    }

    private void Authorize(HttpRequestMessage request) =>
        request.Headers.Authorization = new AuthenticationHeaderValue("Basic",
            Convert.ToBase64String(Encoding.ASCII.GetBytes($"{Twilio.AccountSid}:{Twilio.AuthToken}")));

    private static async Task<int?> ErrorCodeAsync(HttpResponseMessage response, CancellationToken ct)
    {
        try
        {
            using var json = await JsonDocument.ParseAsync(await response.Content.ReadAsStreamAsync(ct), cancellationToken: ct);
            return json.RootElement.TryGetProperty("code", out var code) && code.TryGetInt32(out var value) ? value : null;
        }
        catch (JsonException)
        {
            return null;
        }
    }

    [LoggerMessage(Level = LogLevel.Warning, Message = "Twilio {Operation} failed with HTTP {Status}, code {Code}")]
    private static partial void LogTwilioError(ILogger logger, string operation, int status, int? code);
}

/// <summary>
/// Development only, when Twilio is not configured: writes the code to the API log instead of sending it.
/// Codes last ten minutes and allow five attempts, like Twilio Verify.
/// </summary>
internal sealed partial class DevSmsVerifier(TimeProvider time, ILogger<DevSmsVerifier> logger) : ISmsVerifier
{
    private sealed record Pending(string Code, DateTimeOffset Expires, int Attempts);

    private readonly ConcurrentDictionary<string, Pending> _pending = new();

    public bool IsConfigured => true;

    public Task<Result> SendAsync(string phone, string locale, CancellationToken ct)
    {
        var code = RandomNumberGenerator.GetInt32(0, 1_000_000).ToString("D6", System.Globalization.CultureInfo.InvariantCulture);
        _pending[phone] = new Pending(code, time.GetUtcNow().AddMinutes(10), 0);
        LogCode(logger, phone, code);
        return Task.FromResult(Result.Success());
    }

    public Task<Result<bool>> CheckAsync(string phone, string code, CancellationToken ct)
    {
        if (!_pending.TryGetValue(phone, out var pending) || pending.Expires < time.GetUtcNow() || pending.Attempts >= 5)
            return Task.FromResult<Result<bool>>(false);
        if (pending.Code != code)
        {
            _pending[phone] = pending with { Attempts = pending.Attempts + 1 };
            return Task.FromResult<Result<bool>>(false);
        }
        _pending.TryRemove(phone, out _);
        return Task.FromResult<Result<bool>>(true);
    }

    public Task<string?> LineTypeAsync(string phone, CancellationToken ct) => Task.FromResult<string?>(null);

    [LoggerMessage(Level = LogLevel.Warning, Message = "DEVELOPMENT SMS code for {Phone}: {Code}")]
    private static partial void LogCode(ILogger logger, string phone, string code);
}
