using System.IO.Compression;
using System.Text.Json;

namespace GrupX.Modules.Identity;

/// <summary>
/// Country of a coordinate, from Natural Earth 1:50m borders embedded in this assembly (public domain,
/// docs/ARCHITECTURE.md §3h). The client's own idea of its country is never used. Null at sea and in the
/// coarse strip along some borders; callers then fall back to the IP country.
/// </summary>
internal sealed class CountryLocator
{
    private sealed record Polygon(string Country, double MinLon, double MinLat, double MaxLon, double MaxLat, double[][] Rings);

    private readonly Polygon[] _polygons;

    private CountryLocator(Polygon[] polygons) => _polygons = polygons;

    public static CountryLocator Load()
    {
        using var stream = typeof(CountryLocator).Assembly.GetManifestResourceStream("countries.json.gz")
            ?? throw new InvalidOperationException("Embedded country borders are missing.");
        using var gzip = new GZipStream(stream, CompressionMode.Decompress);
        var data = JsonSerializer.Deserialize<Dictionary<string, double[][][]>>(gzip)
            ?? throw new InvalidOperationException("Embedded country borders are empty.");

        var polygons = new List<Polygon>();
        foreach (var (country, parts) in data)
        {
            foreach (var rings in parts)
            {
                // Rings are flat [lon, lat, lon, lat, ...]; the first is the outline, the rest are holes.
                var outer = rings[0];
                double minLon = double.MaxValue, minLat = double.MaxValue, maxLon = double.MinValue, maxLat = double.MinValue;
                for (var i = 0; i < outer.Length; i += 2)
                {
                    minLon = Math.Min(minLon, outer[i]);
                    maxLon = Math.Max(maxLon, outer[i]);
                    minLat = Math.Min(minLat, outer[i + 1]);
                    maxLat = Math.Max(maxLat, outer[i + 1]);
                }
                polygons.Add(new Polygon(country, minLon, minLat, maxLon, maxLat, rings));
            }
        }
        return new CountryLocator([.. polygons]);
    }

    /// <summary>
    /// The 1:50m coastline cuts off harbours and straits (the Golden Horn, the tip of Manhattan), so a point inside
    /// no country takes the country of the nearest border within about 11 km.
    /// </summary>
    private const double CoastToleranceDegrees = 0.1;

    public string? CountryAt(double latitude, double longitude)
    {
        foreach (var p in _polygons)
        {
            if (longitude < p.MinLon || longitude > p.MaxLon || latitude < p.MinLat || latitude > p.MaxLat) continue;
            // Even-odd rule over the outline and its holes.
            var inside = false;
            foreach (var ring in p.Rings)
                if (Contains(ring, longitude, latitude)) inside = !inside;
            if (inside) return p.Country;
        }
        return Nearest(latitude, longitude);
    }

    private string? Nearest(double latitude, double longitude)
    {
        // Longitude degrees shrink towards the poles; scale them so distances compare fairly.
        var scale = Math.Cos(latitude * Math.PI / 180);
        var best = CoastToleranceDegrees * CoastToleranceDegrees;
        string? country = null;
        foreach (var p in _polygons)
        {
            if (longitude < p.MinLon - (CoastToleranceDegrees / Math.Max(scale, 0.01)) || longitude > p.MaxLon + (CoastToleranceDegrees / Math.Max(scale, 0.01))
                || latitude < p.MinLat - CoastToleranceDegrees || latitude > p.MaxLat + CoastToleranceDegrees) continue;
            foreach (var ring in p.Rings)
            {
                for (int i = 0, j = ring.Length - 2; i < ring.Length; j = i, i += 2)
                {
                    var d = SegmentDistanceSquared(
                        (ring[j] - longitude) * scale, ring[j + 1] - latitude, (ring[i] - longitude) * scale, ring[i + 1] - latitude);
                    if (d < best)
                    {
                        best = d;
                        country = p.Country;
                    }
                }
            }
        }
        return country;
    }

    /// <summary>Squared distance from the origin to the segment (ax, ay)–(bx, by).</summary>
    private static double SegmentDistanceSquared(double ax, double ay, double bx, double by)
    {
        double dx = bx - ax, dy = by - ay;
        var length = (dx * dx) + (dy * dy);
        var t = length == 0 ? 0 : Math.Clamp(-((ax * dx) + (ay * dy)) / length, 0, 1);
        double x = ax + (t * dx), y = ay + (t * dy);
        return (x * x) + (y * y);
    }

    private static bool Contains(double[] ring, double x, double y)
    {
        var inside = false;
        for (int i = 0, j = ring.Length - 2; i < ring.Length; j = i, i += 2)
        {
            double xi = ring[i], yi = ring[i + 1], xj = ring[j], yj = ring[j + 1];
            if ((yi > y) != (yj > y) && x < ((xj - xi) * (y - yi) / (yj - yi)) + xi) inside = !inside;
        }
        return inside;
    }
}
