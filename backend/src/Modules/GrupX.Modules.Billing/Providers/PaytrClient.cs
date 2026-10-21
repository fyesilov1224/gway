using System.Globalization;
using System.Net.Http.Json;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using GrupX.SharedKernel;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace GrupX.Modules.Billing.Providers;

internal sealed record PaytrCheckout(
    string MerchantOid,
    string UserIp,
    string Email,
    int AmountMinor,
    string ItemName,
    string UserName,
    string UserAddress,
    string UserPhone,
    Uri ReturnUrl);

/// <summary>PayTR iFrame API: payment token and notification hash (docs/ARCHITECTURE.md §7).</summary>
internal sealed class PaytrClient(HttpClient http, IOptions<BillingOptions> options, ILogger<PaytrClient> log)
{
    private sealed record TokenResponse(string? Status, string? Token, string? Reason);

    // Single payment in TL; the order amount is exactly what is charged.
    private const string NoInstallment = "1";
    private const string MaxInstallment = "0";
    private const string Currency = "TL";

    private PaytrOptions Options => options.Value.Paytr;

    public bool IsConfigured => Options.IsConfigured;

    /// <summary>Opens a payment session; returns the hosted payment page.</summary>
    public async Task<Result<(string Token, Uri PaymentUrl)>> StartAsync(PaytrCheckout checkout, CancellationToken ct)
    {
        var o = Options;
        var amount = checkout.AmountMinor.ToString(CultureInfo.InvariantCulture);
        var basket = Convert.ToBase64String(JsonSerializer.SerializeToUtf8Bytes(
            new object[] { new object[] { checkout.ItemName, Money.Major(checkout.AmountMinor), 1 } }));
        var testMode = o.TestMode ? "1" : "0";
        var token = Sign(o.MerchantKey,
            o.MerchantId + checkout.UserIp + checkout.MerchantOid + checkout.Email + amount + basket
            + NoInstallment + MaxInstallment + Currency + testMode + o.MerchantSalt);

        using var form = new FormUrlEncodedContent(new Dictionary<string, string>
        {
            ["merchant_id"] = o.MerchantId,
            ["user_ip"] = checkout.UserIp,
            ["merchant_oid"] = checkout.MerchantOid,
            ["email"] = checkout.Email,
            ["payment_amount"] = amount,
            ["paytr_token"] = token,
            ["user_basket"] = basket,
            ["debug_on"] = "0",
            ["no_installment"] = NoInstallment,
            ["max_installment"] = MaxInstallment,
            ["user_name"] = checkout.UserName,
            ["user_address"] = checkout.UserAddress,
            ["user_phone"] = checkout.UserPhone,
            ["merchant_ok_url"] = checkout.ReturnUrl.ToString(),
            ["merchant_fail_url"] = checkout.ReturnUrl.ToString(),
            ["timeout_limit"] = "30",
            ["currency"] = Currency,
            ["test_mode"] = testMode,
            ["lang"] = "tr",
        });

        using var response = await http.PostAsync(new Uri(new Uri(o.BaseUrl), "/odeme/api/get-token"), form, ct);
        var body = await response.Content.ReadFromJsonAsync<TokenResponse>(JsonSerializerOptions.Web, ct);
        if (body is { Status: "success", Token.Length: > 0 })
            return (body.Token, new Uri(new Uri(o.BaseUrl), $"/odeme/guvenli/{body.Token}"));

        log.LogWarning("PayTR rejected checkout {MerchantOid}: {Reason}", checkout.MerchantOid, body?.Reason);
        return BillingErrors.ProviderFailed;
    }

    /// <summary>Checks the <c>hash</c> of a payment notification.</summary>
    public bool Verify(string merchantOid, string status, string totalAmount, string hash)
    {
        var o = Options;
        if (!o.IsConfigured) return false;
        var expected = Sign(o.MerchantKey, merchantOid + o.MerchantSalt + status + totalAmount);
        return CryptographicOperations.FixedTimeEquals(Encoding.UTF8.GetBytes(expected), Encoding.UTF8.GetBytes(hash));
    }

    /// <summary>base64(HMAC-SHA256(key, message)), PayTR's token and hash format.</summary>
    public static string Sign(string key, string message) =>
        Convert.ToBase64String(HMACSHA256.HashData(Encoding.UTF8.GetBytes(key), Encoding.UTF8.GetBytes(message)));
}
