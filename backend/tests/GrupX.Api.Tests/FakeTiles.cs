using System.Collections.Concurrent;
using System.Net;

namespace GrupX.Api.Tests;

/// <summary>Stands in for the map tile provider and records what the API asked for.</summary>
public sealed class FakeTiles
{
    public const string Url = "https://tiles.test/{z}/{x}/{y}.png?api_key={api_key}";
    public const string ApiKey = "tile-test-key";

    public ConcurrentQueue<Uri> Requests { get; } = new();

    public HttpMessageHandler Handler() => new TileHandler(this);

    private sealed class TileHandler(FakeTiles tiles) : HttpMessageHandler
    {
        protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
        {
            tiles.Requests.Enqueue(request.RequestUri!);
            return Task.FromResult(new HttpResponseMessage(HttpStatusCode.OK) { Content = new ByteArrayContent([0x89, 0x50, 0x4E, 0x47]) });
        }
    }
}
