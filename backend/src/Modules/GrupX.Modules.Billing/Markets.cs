using System.Net;
using MaxMind.Db;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Options;

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

/// <summary>
/// Finds the country of a request: trusted proxy header, then the country database, then the fallback
/// (docs/ARCHITECTURE.md §7, Pazar). Never trusts anything the client sends about itself.
/// </summary>
internal sealed class CountryResolver : IDisposable
{
    private readonly GeoOptions _options;
    private readonly Reader? _database;

    public CountryResolver(IOptions<BillingOptions> options)
    {
        _options = options.Value.Geo;
        if (!string.IsNullOrWhiteSpace(_options.DatabasePath)) _database = new Reader(_options.DatabasePath, FileAccessMode.Memory);
    }

    public Market MarketOf(HttpContext http) => Market.For(Resolve(http));

    public string Resolve(HttpContext http)
    {
        if (!string.IsNullOrWhiteSpace(_options.CountryHeader)
            && Normalize(http.Request.Headers[_options.CountryHeader].ToString()) is { } fromHeader)
            return fromHeader;

        if (_database is not null && http.Connection.RemoteIpAddress is { } ip && Lookup(ip) is { } fromDatabase)
            return fromDatabase;

        return Normalize(_options.FallbackCountry) ?? "TR";
    }

    private string? Lookup(IPAddress ip)
    {
        if (ip.IsIPv4MappedToIPv6) ip = ip.MapToIPv4();
        var record = _database!.Find<Dictionary<string, object>>(ip);
        return record?.GetValueOrDefault("country") is Dictionary<string, object> country
            ? Normalize(country.GetValueOrDefault("iso_code") as string)
            : null;
    }

    /// <summary>ISO 3166-1 alpha-2, upper case; null for empty or placeholder values (Cloudflare sends XX and T1).</summary>
    internal static string? Normalize(string? code)
    {
        code = code?.Trim().ToUpperInvariant();
        return code is { Length: 2 } && char.IsAsciiLetterUpper(code[0]) && char.IsAsciiLetterUpper(code[1]) && code is not "XX" and not "T1"
            ? code
            : null;
    }

    public void Dispose() => _database?.Dispose();
}
