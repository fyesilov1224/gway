using GrupX.Modules.Billing.Contracts;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace GrupX.Modules.Billing;

/// <summary>
/// What each provider needs and what is still missing (docs/PAYMENTS.md). Keys are never part of the result.
/// </summary>
internal static class ProviderSetup
{
    public const string PaytrNotifyPath = "/billing/paytr/notify";
    public const string IyzicoWebhookPath = "/billing/iyzico/webhook";
    public const string IyzicoLiveUrl = "https://api.iyzipay.com";

    public static PaymentProvidersStatus Describe(BillingOptions o)
    {
        var api = o.PublicApiUrl.TrimEnd('/');
        var shared = new List<string>();
        if (o.AppUrl.Length == 0) shared.Add("Billing:AppUrl boş: ödemeden sonra kullanıcı uygulamaya dönemez.");
        if (api.Length == 0) shared.Add("Billing:PublicApiUrl boş: sağlayıcı bildirimleri ve iyzico dönüşü çalışmaz.");
        else if (IsLocal(api)) shared.Add("Billing:PublicApiUrl yerel bir adres: sağlayıcının bildirimi ulaşmaz. Denemek için tünel kullan (docs/PAYMENTS.md).");
        else if (!api.StartsWith("https://", StringComparison.OrdinalIgnoreCase)) shared.Add("Billing:PublicApiUrl https değil: sağlayıcılar bildirimi https adrese gönderir.");

        var paytrWarnings = new List<string>(shared);
        if (!o.Paytr.IsConfigured) paytrWarnings.Insert(0, "Mağaza no, mağaza parola (key) ve mağaza gizli anahtar (salt) girilmemiş; Türkiye'den satış kapalı.");
        else if (o.Paytr.TestMode) paytrWarnings.Add("Test modu açık: kartlardan para çekilmez. Canlıya geçince Billing:Paytr:TestMode=false yap.");

        var iyzicoTest = o.Iyzico.BaseUrl.Contains("sandbox", StringComparison.OrdinalIgnoreCase);
        var iyzicoWarnings = new List<string>(shared);
        if (!o.Iyzico.IsConfigured) iyzicoWarnings.Insert(0, "API anahtarı ve güvenlik anahtarı girilmemiş; yurt dışından satış kapalı.");
        else if (iyzicoTest) iyzicoWarnings.Add($"Sandbox adresi kullanılıyor: para çekilmez. Canlıda Billing:Iyzico:BaseUrl={IyzicoLiveUrl} ve canlı anahtarlar gerekir.");

        return new PaymentProvidersStatus(o.AppUrl, o.PublicApiUrl,
        [
            new PaymentProviderStatus(PaymentProviders.Paytr, "TR · TL", o.Paytr.IsConfigured, o.Paytr.TestMode,
                api.Length == 0 ? [] : [new ProviderAddress("Bildirim URL (PayTR paneli)", api + PaytrNotifyPath)], paytrWarnings),
            new PaymentProviderStatus(PaymentProviders.Iyzico, "Yurt dışı · USD", o.Iyzico.IsConfigured, iyzicoTest,
                api.Length == 0 ? [] : [new ProviderAddress("Webhook adresi (iyzico paneli)", api + IyzicoWebhookPath)], iyzicoWarnings),
        ]);
    }

    private static bool IsLocal(string url) =>
        Uri.TryCreate(url, UriKind.Absolute, out var uri)
        && (uri.IsLoopback || uri.Host.StartsWith("192.168.", StringComparison.Ordinal) || uri.Host.StartsWith("10.", StringComparison.Ordinal));
}

/// <summary>Logs the payment setup once at start, so a missing key or address shows up before the first customer.</summary>
internal sealed partial class ProviderSetupLog(IOptions<BillingOptions> options, ILogger<ProviderSetupLog> log) : IHostedService
{
    public Task StartAsync(CancellationToken cancellationToken)
    {
        foreach (var p in ProviderSetup.Describe(options.Value).Providers)
        {
            // Without keys purchases are closed on purpose (503); the address warnings matter only once keys exist.
            if (!p.Configured)
            {
                NotConfigured(p.Provider);
                continue;
            }
            Configured(p.Provider, p.TestMode);
            foreach (var warning in p.Warnings) Warning(p.Provider, warning);
        }
        return Task.CompletedTask;
    }

    public Task StopAsync(CancellationToken cancellationToken) => Task.CompletedTask;

    [LoggerMessage(Level = LogLevel.Information, Message = "Payments: {Provider} has no keys; its purchases are closed")]
    private partial void NotConfigured(string provider);

    [LoggerMessage(Level = LogLevel.Information, Message = "Payments: {Provider} configured (test mode: {TestMode})")]
    private partial void Configured(string provider, bool testMode);

    [LoggerMessage(Level = LogLevel.Warning, Message = "Payments: {Provider}: {Warning}")]
    private partial void Warning(string provider, string warning);
}
