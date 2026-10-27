using GrupX.SharedKernel.Geo;
using Microsoft.AspNetCore.Http;

namespace GrupX.Modules.Billing;

internal static class PaymentProviders
{
    public const string Paytr = "paytr";
    public const string Iyzico = "iyzico";
}

internal static class Currencies
{
    public const string Try = "TRY";
    public const string Usd = "USD";
}

/// <summary>Where a buyer pays: Türkiye through PayTR in TRY, everywhere else through iyzico in USD.</summary>
public sealed record Market(string Country, string Provider, string Currency)
{
    public static Market For(string country) => country == "TR"
        ? new Market(country, PaymentProviders.Paytr, Currencies.Try)
        : new Market(country, PaymentProviders.Iyzico, Currencies.Usd);
}

internal static class CountryResolverMarkets
{
    public static Market MarketOf(this CountryResolver geo, HttpContext http) => Market.For(geo.Resolve(http));
}
