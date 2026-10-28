using System.Collections.Concurrent;
using System.Globalization;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;

namespace GrupX.Api.Tests;

/// <summary>
/// Stands in for PayTR and iyzico. Records what the API sent and answers like the providers do.
/// Shared by every client the factory creates; <see cref="FakePaymentHandler"/> is the per-client wrapper.
/// </summary>
public sealed class FakePaymentProviders
{
    public const string PaytrUrl = "https://paytr.test";
    public const string IyzicoUrl = "https://iyzico.test";

    /// <summary>PayTR get-token forms, by merchant_oid.</summary>
    public ConcurrentDictionary<string, Dictionary<string, string>> PaytrForms { get; } = new();

    /// <summary>iyzico requests: (path, Authorization header, x-iyzi-rnd, body).</summary>
    public ConcurrentBag<(string Path, string Authorization, string RandomKey, string Body)> IyzicoRequests { get; } = [];

    /// <summary>What iyzico's detail call answers for a token; unknown tokens answer a failure status.</summary>
    public ConcurrentDictionary<string, object> IyzicoDetails { get; } = new();

    /// <summary>When true, providers refuse to open a payment.</summary>
    public bool Refuse { get; set; }

    /// <summary>A PayTR notification for <paramref name="order"/>, signed with the test merchant key.</summary>
    public static FormUrlEncodedContent PaytrNotification(Guid order, string status, int totalAmount)
    {
        var oid = order.ToString("N");
        var amount = totalAmount.ToString(CultureInfo.InvariantCulture);
        var hash = Convert.ToBase64String(HMACSHA256.HashData(
            Encoding.UTF8.GetBytes(ApiFactory.PaytrKey), Encoding.UTF8.GetBytes(oid + ApiFactory.PaytrSalt + status + amount)));
        return new FormUrlEncodedContent(new Dictionary<string, string>
        {
            ["merchant_oid"] = oid,
            ["status"] = status,
            ["total_amount"] = amount,
            ["hash"] = hash,
            ["failed_reason_code"] = status == "success" ? "" : "6",
            ["currency"] = "TL",
            ["test_mode"] = "1",
        });
    }

    internal async Task<HttpResponseMessage> HandleAsync(HttpRequestMessage request, CancellationToken ct)
    {
        var path = request.RequestUri!.AbsolutePath;
        var body = request.Content is null ? "" : await request.Content.ReadAsStringAsync(ct);

        if (request.RequestUri.GetLeftPart(UriPartial.Authority) == PaytrUrl && path == "/odeme/api/get-token")
        {
            var form = body.Split('&').Select(p => p.Split('=', 2))
                .ToDictionary(p => WebUtility.UrlDecode(p[0]), p => WebUtility.UrlDecode(p[1]));
            PaytrForms[form["merchant_oid"]] = form;
            return Json(Refuse
                ? new { status = "failed", reason = "test refusal" }
                : (object)new { status = "success", token = $"tok-{form["merchant_oid"]}" });
        }

        if (request.RequestUri.GetLeftPart(UriPartial.Authority) == IyzicoUrl)
        {
            IyzicoRequests.Add((path, request.Headers.Authorization?.ToString() ?? "",
                request.Headers.TryGetValues("x-iyzi-rnd", out var rnd) ? rnd.Single() : "", body));
            using var doc = JsonDocument.Parse(body);
            var conversation = doc.RootElement.GetProperty("conversationId").GetString();

            if (path == "/payment/iyzipos/checkoutform/initialize/auth/ecom")
            {
                return Json(Refuse
                    ? new { status = "failure", errorCode = "10051", errorMessage = "test refusal" }
                    : (object)new { status = "success", token = $"iyz-{conversation}", paymentPageUrl = $"{IyzicoUrl}/pay/iyz-{conversation}" });
            }
            if (path == "/payment/iyzipos/installment")
            {
                return Json(Refuse
                    ? new { status = "failure", errorCode = "1001", errorMessage = "api bilgileri bulunamadı" }
                    : (object)new { status = "success", installmentDetails = Array.Empty<object>() });
            }
            if (path == "/payment/iyzipos/checkoutform/auth/ecom/detail")
            {
                var token = doc.RootElement.GetProperty("token").GetString()!;
                return Json(IyzicoDetails.TryGetValue(token, out var detail) ? detail : new { status = "failure", errorCode = "5", errorMessage = "not found" });
            }
        }

        return new HttpResponseMessage(HttpStatusCode.NotFound);
    }

    private static HttpResponseMessage Json(object value) => new(HttpStatusCode.OK)
    {
        Content = new StringContent(JsonSerializer.Serialize(value), Encoding.UTF8, "application/json"),
    };
}

/// <summary>A fresh handler per HttpClient, so the factory can dispose it freely.</summary>
public sealed class FakePaymentHandler(FakePaymentProviders providers) : HttpMessageHandler
{
    protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken) =>
        providers.HandleAsync(request, cancellationToken);
}
