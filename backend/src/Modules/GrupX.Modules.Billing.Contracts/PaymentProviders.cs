namespace GrupX.Modules.Billing.Contracts;

/// <summary>Result of asking a payment provider whether the configured keys work (docs/PAYMENTS.md).</summary>
public sealed record ProviderCheck(bool Connected, string Message)
{
    public static readonly ProviderCheck Success = new(true, "Bağlantı başarılı; anahtarlar sağlayıcı tarafından kabul edildi.");

    public static readonly ProviderCheck NotConfigured = new(false, "Anahtarlar girilmemiş.");
}

/// <summary>An address to enter in the provider's merchant panel.</summary>
public sealed record ProviderAddress(string Label, string Url);

/// <summary>One provider's setup for the admin panel; never contains a key.</summary>
public sealed record PaymentProviderStatus(
    string Provider,
    string Market,
    bool Configured,
    bool TestMode,
    IReadOnlyList<ProviderAddress> Addresses,
    IReadOnlyList<string> Warnings);

public sealed record PaymentProvidersStatus(string AppUrl, string PublicApiUrl, IReadOnlyList<PaymentProviderStatus> Providers);
