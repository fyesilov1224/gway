namespace GrupX.Modules.Billing;

/// <summary><c>Billing</c> configuration (docs/ARCHITECTURE.md §7, Yapılandırma). Keys come from the environment.</summary>
public sealed class BillingOptions
{
    public const string Section = "Billing";

    /// <summary>Web app base URL for return links, e.g. <c>https://grupx.app</c>.</summary>
    public string AppUrl { get; set; } = "";

    /// <summary>Public base URL of this API, for the iyzico callback.</summary>
    public string PublicApiUrl { get; set; } = "";

    public PaytrOptions Paytr { get; set; } = new();

    public IyzicoOptions Iyzico { get; set; } = new();
}

public sealed class PaytrOptions
{
    public string MerchantId { get; set; } = "";

    public string MerchantKey { get; set; } = "";

    public string MerchantSalt { get; set; } = "";

    public bool TestMode { get; set; } = true;

    public string BaseUrl { get; set; } = "https://www.paytr.com";

    public bool IsConfigured => MerchantId.Length > 0 && MerchantKey.Length > 0 && MerchantSalt.Length > 0;
}

public sealed class IyzicoOptions
{
    public string ApiKey { get; set; } = "";

    public string SecretKey { get; set; } = "";

    public string BaseUrl { get; set; } = "https://sandbox-api.iyzipay.com";

    public bool IsConfigured => ApiKey.Length > 0 && SecretKey.Length > 0;
}
