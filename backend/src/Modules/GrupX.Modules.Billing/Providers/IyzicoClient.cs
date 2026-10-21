using System.Globalization;
using System.Net.Http.Json;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using GrupX.SharedKernel;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace GrupX.Modules.Billing.Providers;

internal sealed record IyzicoBuyer(
    Guid Id, string FirstName, string LastName, string Email, string Phone, string Address, string City, string Country, string Ip);

internal sealed record IyzicoCheckout(Guid OrderId, int AmountMinor, string Currency, string ItemName, IyzicoBuyer Buyer, Uri CallbackUrl);

/// <summary>Result of a Checkout Form, as iyzico reports it to us.</summary>
internal sealed record IyzicoPayment(string PaymentStatus, int? FraudStatus, int PaidMinor, string Currency, string BasketId, string? PaymentId);

/// <summary>Fields of an iyzico webhook that its signature covers.</summary>
internal sealed record IyzicoWebhook(string EventType, string PaymentId, string Token, string ConversationId, string Status);

/// <summary>iyzico Checkout Form with IYZWSv2 authentication (docs/ARCHITECTURE.md §7).</summary>
internal sealed class IyzicoClient(HttpClient http, IOptions<BillingOptions> options, ILogger<IyzicoClient> log)
{
    public const string InitializePath = "/payment/iyzipos/checkoutform/initialize/auth/ecom";
    public const string DetailPath = "/payment/iyzipos/checkoutform/auth/ecom/detail";

    // iyzico's documented placeholder for buyers without a Turkish identity number.
    private const string ForeignIdentityNumber = "11111111111";

    private IyzicoOptions Options => options.Value.Iyzico;

    public bool IsConfigured => Options.IsConfigured;

    /// <summary>Opens a Checkout Form; returns its token and hosted payment page.</summary>
    public async Task<Result<(string Token, Uri PaymentUrl)>> StartAsync(IyzicoCheckout checkout, CancellationToken ct)
    {
        var price = Money.Major(checkout.AmountMinor);
        var buyer = checkout.Buyer;
        var response = await SendAsync(InitializePath, new
        {
            locale = "en",
            conversationId = checkout.OrderId.ToString(),
            price,
            paidPrice = price,
            currency = checkout.Currency,
            basketId = checkout.OrderId.ToString(),
            paymentGroup = "SUBSCRIPTION",
            callbackUrl = checkout.CallbackUrl.ToString(),
            enabledInstallments = new[] { 1 },
            buyer = new
            {
                id = buyer.Id.ToString(),
                name = buyer.FirstName,
                surname = buyer.LastName,
                gsmNumber = buyer.Phone,
                email = buyer.Email,
                identityNumber = ForeignIdentityNumber,
                registrationAddress = buyer.Address,
                ip = buyer.Ip,
                city = buyer.City,
                country = buyer.Country,
            },
            billingAddress = new
            {
                contactName = $"{buyer.FirstName} {buyer.LastName}",
                city = buyer.City,
                country = buyer.Country,
                address = buyer.Address,
            },
            basketItems = new[]
            {
                new { id = "plan", name = checkout.ItemName, category1 = "Subscription", itemType = "VIRTUAL", price },
            },
        }, ct);

        if (Text(response, "status") == "success"
            && Text(response, "token") is { Length: > 0 } token
            && Uri.TryCreate(Text(response, "paymentPageUrl"), UriKind.Absolute, out var page))
            return (token, page);

        log.LogWarning("iyzico rejected checkout {OrderId}: {Code} {Message}",
            checkout.OrderId, Text(response, "errorCode"), Text(response, "errorMessage"));
        return BillingErrors.ProviderFailed;
    }

    /// <summary>Asks iyzico for the result of a Checkout Form. This, not the caller, decides the outcome.</summary>
    public async Task<IyzicoPayment?> RetrieveAsync(string token, Guid orderId, CancellationToken ct)
    {
        var r = await SendAsync(DetailPath, new { locale = "en", conversationId = orderId.ToString(), token }, ct);
        if (Text(r, "status") != "success")
        {
            log.LogWarning("iyzico detail failed for {OrderId}: {Code} {Message}", orderId, Text(r, "errorCode"), Text(r, "errorMessage"));
            return null;
        }

        var paid = decimal.TryParse(Text(r, "paidPrice"), NumberStyles.Number, CultureInfo.InvariantCulture, out var p) ? p : 0;
        return new IyzicoPayment(
            Text(r, "paymentStatus") ?? "",
            int.TryParse(Text(r, "fraudStatus"), CultureInfo.InvariantCulture, out var fraud) ? fraud : null,
            (int)Math.Round(paid * 100, MidpointRounding.AwayFromZero),
            Text(r, "currency") ?? "",
            Text(r, "basketId") ?? "",
            Text(r, "paymentId"));
    }

    /// <summary>Checks <c>X-IYZ-SIGNATURE-V3</c> of a Checkout Form webhook.</summary>
    public bool VerifyWebhook(string? signature, IyzicoWebhook webhook)
    {
        var o = Options;
        if (!o.IsConfigured || string.IsNullOrEmpty(signature)) return false;
        var expected = Convert.ToHexStringLower(HMACSHA256.HashData(
            Encoding.UTF8.GetBytes(o.SecretKey),
            Encoding.UTF8.GetBytes(o.SecretKey + webhook.EventType + webhook.PaymentId + webhook.Token + webhook.ConversationId + webhook.Status)));
        return CryptographicOperations.FixedTimeEquals(Encoding.UTF8.GetBytes(expected), Encoding.UTF8.GetBytes(signature.ToLowerInvariant()));
    }

    /// <summary>Reads a webhook body; null when a signed field is missing.</summary>
    public static IyzicoWebhook? ParseWebhook(string body)
    {
        try
        {
            using var doc = JsonDocument.Parse(body);
            var root = doc.RootElement;
            return Text(root, "iyziEventType") is { } type && Text(root, "iyziPaymentId") is { } paymentId
                && Text(root, "token") is { } token && Text(root, "paymentConversationId") is { } conversation
                && Text(root, "status") is { } status
                ? new IyzicoWebhook(type, paymentId, token, conversation, status)
                : null;
        }
        catch (JsonException)
        {
            return null;
        }
    }

    /// <summary><c>IYZWSv2</c> header: HMAC-SHA256 over random key, path and body.</summary>
    public static string Authorization(string apiKey, string secretKey, string randomKey, string path, string body)
    {
        var signature = Convert.ToHexStringLower(
            HMACSHA256.HashData(Encoding.UTF8.GetBytes(secretKey), Encoding.UTF8.GetBytes(randomKey + path + body)));
        return "IYZWSv2 " + Convert.ToBase64String(Encoding.UTF8.GetBytes($"apiKey:{apiKey}&randomKey:{randomKey}&signature:{signature}"));
    }

    private async Task<JsonElement> SendAsync(string path, object body, CancellationToken ct)
    {
        var o = Options;
        // The signed text must be exactly the body that is sent.
        var payload = JsonSerializer.Serialize(body);
        var randomKey = $"{DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()}{RandomNumberGenerator.GetInt32(100_000, 1_000_000)}";

        using var request = new HttpRequestMessage(HttpMethod.Post, new Uri(new Uri(o.BaseUrl), path))
        {
            Content = new StringContent(payload, Encoding.UTF8, "application/json"),
        };
        request.Headers.TryAddWithoutValidation("Authorization", Authorization(o.ApiKey, o.SecretKey, randomKey, path, payload));
        request.Headers.Add("x-iyzi-rnd", randomKey);

        using var response = await http.SendAsync(request, ct);
        return await response.Content.ReadFromJsonAsync<JsonElement>(ct);
    }

    /// <summary>A property as text, whether iyzico sent it as a string or a number.</summary>
    private static string? Text(JsonElement element, string name) =>
        element.ValueKind == JsonValueKind.Object && element.TryGetProperty(name, out var value)
            ? value.ValueKind switch
            {
                JsonValueKind.String => value.GetString(),
                JsonValueKind.Number => value.GetRawText(),
                _ => null,
            }
            : null;
}
