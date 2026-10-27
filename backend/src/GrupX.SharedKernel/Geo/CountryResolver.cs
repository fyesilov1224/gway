using System.Net;
using MaxMind.Db;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.Extensions.Options;

namespace GrupX.SharedKernel.Geo;

/// <summary><c>Geo</c> configuration (docs/ARCHITECTURE.md §7, Pazar; §3h). Used by billing and security checks.</summary>
public sealed class GeoOptions
{
    public const string Section = "Geo";

    /// <summary>Country header set by a trusted proxy in front of the API (e.g. <c>CF-IPCountry</c>).</summary>
    public string? CountryHeader { get; set; }

    /// <summary>MaxMind DB country database (DB-IP Lite or GeoLite2 Country).</summary>
    public string? DatabasePath { get; set; }

    /// <summary>Used when the country cannot be found (local and private addresses).</summary>
    public string FallbackCountry { get; set; } = "TR";
}

/// <summary>
/// Finds the country of a request: trusted proxy header, then the country database, then the fallback
/// (docs/ARCHITECTURE.md §7, Pazar). Never trusts anything the client sends about itself.
/// </summary>
public sealed class CountryResolver : IDisposable
{
    private readonly GeoOptions _options;
    private readonly Reader? _database;

    public CountryResolver(IOptions<GeoOptions> options)
    {
        ArgumentNullException.ThrowIfNull(options);
        _options = options.Value;
        if (!string.IsNullOrWhiteSpace(_options.DatabasePath)) _database = new Reader(_options.DatabasePath, FileAccessMode.Memory);
    }

    public string Resolve(HttpContext http) => TryResolve(http) ?? Normalize(_options.FallbackCountry) ?? "TR";

    /// <summary>The request's country, or null when only the fallback would answer (local and private addresses).</summary>
    public string? TryResolve(HttpContext http)
    {
        ArgumentNullException.ThrowIfNull(http);
        if (!string.IsNullOrWhiteSpace(_options.CountryHeader)
            && Normalize(http.Request.Headers[_options.CountryHeader].ToString()) is { } fromHeader)
            return fromHeader;

        if (_database is not null && http.Connection.RemoteIpAddress is { } ip && Lookup(ip) is { } fromDatabase)
            return fromDatabase;

        return null;
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
    public static string? Normalize(string? code)
    {
        code = code?.Trim().ToUpperInvariant();
        return code is { Length: 2 } && char.IsAsciiLetterUpper(code[0]) && char.IsAsciiLetterUpper(code[1]) && code is not "XX" and not "T1"
            ? code
            : null;
    }

    public void Dispose() => _database?.Dispose();
}

public static class GeoServiceCollectionExtensions
{
    /// <summary>Registers <see cref="CountryResolver"/> once, whichever modules ask for it.</summary>
    public static IServiceCollection AddGeo(this IServiceCollection services)
    {
        services.AddOptions<GeoOptions>().BindConfiguration(GeoOptions.Section);
        services.TryAddSingleton<CountryResolver>();
        return services;
    }
}
