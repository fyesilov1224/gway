using System.Globalization;
using Microsoft.Extensions.Caching.Memory;

namespace Gway.Api.Endpoints;

/// <summary>
/// Map tiles through the API (docs/ARCHITECTURE.md §3d, Harita ile keşif): the provider key stays on the
/// server and the provider never sees the user's address. Tiles are cached in memory.
/// </summary>
public static class MapTileEndpoints
{
    public const string PathPrefix = "/map/tiles/";
    private const int MaxZoom = 19;
    private const long CacheBytes = 64L * 1024 * 1024;

    internal sealed class TileCache : IDisposable
    {
        public MemoryCache Cache { get; } = new(new MemoryCacheOptions { SizeLimit = CacheBytes });

        public void Dispose() => Cache.Dispose();
    }

    public static IServiceCollection AddMapTiles(this IServiceCollection services)
    {
        services.AddSingleton<TileCache>();
        services.AddHttpClient(nameof(MapTileEndpoints), client =>
        {
            client.Timeout = TimeSpan.FromSeconds(10);
            client.DefaultRequestHeaders.UserAgent.ParseAdd("GWAY/1.0 (+https://gway.app)");
        });
        return services;
    }

    public static IEndpointRouteBuilder MapMapTileEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapGet(PathPrefix + "{z:int}/{x:int}/{y:int}.png", async (
            int z, int x, int y, HttpContext http, IConfiguration configuration, IHttpClientFactory clients, TileCache tiles,
            CancellationToken ct) =>
        {
            var template = configuration["Map:TileUrl"];
            var apiKey = configuration["Map:ApiKey"];
            if (string.IsNullOrWhiteSpace(template)
                || (template.Contains("{api_key}", StringComparison.Ordinal) && string.IsNullOrWhiteSpace(apiKey)))
            {
                return Results.Problem(statusCode: StatusCodes.Status503ServiceUnavailable, title: "map.unavailable",
                    detail: "Harita şu anda kullanılamıyor.");
            }
            var size = 1L << Math.Clamp(z, 0, MaxZoom);
            if (z is < 0 or > MaxZoom || x < 0 || y < 0 || x >= size || y >= size) return Results.NotFound();

            var key = $"{z}/{x}/{y}";
            if (!tiles.Cache.TryGetValue(key, out byte[]? png))
            {
                var url = template
                    .Replace("{z}", z.ToString(CultureInfo.InvariantCulture), StringComparison.Ordinal)
                    .Replace("{x}", x.ToString(CultureInfo.InvariantCulture), StringComparison.Ordinal)
                    .Replace("{y}", y.ToString(CultureInfo.InvariantCulture), StringComparison.Ordinal)
                    .Replace("{api_key}", Uri.EscapeDataString(apiKey ?? ""), StringComparison.Ordinal);
                using var response = await clients.CreateClient(nameof(MapTileEndpoints)).GetAsync(new Uri(url), ct);
                if (!response.IsSuccessStatusCode)
                {
                    return Results.Problem(statusCode: StatusCodes.Status502BadGateway, title: "map.tile_failed",
                        detail: "Harita yüklenemedi.");
                }
                png = await response.Content.ReadAsByteArrayAsync(ct);
                tiles.Cache.Set(key, png, new MemoryCacheEntryOptions { Size = png.Length, SlidingExpiration = TimeSpan.FromDays(1) });
            }

            http.Response.Headers.CacheControl = "private, max-age=86400";
            return Results.File(png!, "image/png");
        });

        return app;
    }
}
