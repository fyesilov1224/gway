using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using Gway.Api.Endpoints;

namespace Gway.Api.Tests;

public sealed class ApiTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private static readonly Guid UserId = Guid.Parse("00000000-0000-0000-0000-0000000000b1");

    // Signed-in endpoints need an active account (docs/ARCHITECTURE.md §3a).
    private readonly TestDatabase _db = new();

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public ValueTask DisposeAsync() => _db.DisposeAsync();

    private HttpClient ClientWithToken(string token)
    {
        var client = factory.CreateClient();
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
        return client;
    }

    [Fact]
    public async Task Health_is_anonymous()
    {
        var response = await factory.CreateClient().GetAsync(new Uri("/health", UriKind.Relative), TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task Me_without_token_returns_401_problem_details()
    {
        var response = await factory.CreateClient().GetAsync(new Uri("/me", UriKind.Relative), TestContext.Current.CancellationToken);

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
        Assert.Equal("application/problem+json", response.Content.Headers.ContentType?.MediaType);
    }

    [Fact]
    public async Task Me_with_valid_token_returns_user_id()
    {
        var user = await _db.CreateUserAsync();
        var client = ClientWithToken(ApiFactory.CreateToken(user));

        var me = await client.GetFromJsonAsync<MeEndpoints.MeResponse>(new Uri("/me", UriKind.Relative), TestContext.Current.CancellationToken);

        Assert.Equal(user, me?.UserId);
    }

    public static TheoryData<string, string> InvalidTokens() => new()
    {
        { "wrong issuer", ApiFactory.CreateToken(UserId, issuer: "http://evil.test/auth/v1") },
        { "wrong audience", ApiFactory.CreateToken(UserId, audience: "anon") },
        { "wrong signature", ApiFactory.CreateToken(UserId, secret: "another-secret-that-is-at-least-32-characters") },
        { "expired", ApiFactory.CreateToken(UserId, expires: DateTime.UtcNow.AddMinutes(-5)) },
    };

    [Theory]
    [MemberData(nameof(InvalidTokens))]
    public async Task Me_rejects_invalid_tokens(string reason, string token)
    {
        var response = await ClientWithToken(token).GetAsync(new Uri("/me", UriKind.Relative), TestContext.Current.CancellationToken);

        Assert.True(response.StatusCode == HttpStatusCode.Unauthorized, reason);
    }

    [Theory]
    [InlineData("http://localhost:3000", true)]
    [InlineData("http://evil.test", false)]
    public async Task Cors_allows_only_configured_origins(string origin, bool allowed)
    {
        using var request = new HttpRequestMessage(HttpMethod.Options, new Uri("/account", UriKind.Relative));
        request.Headers.Add("Origin", origin);
        request.Headers.Add("Access-Control-Request-Method", "POST");
        request.Headers.Add("Access-Control-Request-Headers", "authorization");

        var response = await factory.CreateClient().SendAsync(request, TestContext.Current.CancellationToken);

        Assert.Equal(allowed, response.Headers.TryGetValues("Access-Control-Allow-Origin", out var values) && values.Contains(origin));
    }

    [Fact]
    public async Task Requests_over_the_limit_get_429()
    {
        // A dedicated user id gives this test its own rate limit partition.
        var client = ClientWithToken(ApiFactory.CreateToken(await _db.CreateUserAsync()));
        var uri = new Uri("/me", UriKind.Relative);

        for (var i = 0; i < ApiFactory.PermitsPerMinute; i++)
        {
            var ok = await client.GetAsync(uri, TestContext.Current.CancellationToken);
            Assert.Equal(HttpStatusCode.OK, ok.StatusCode);
        }

        var limited = await client.GetAsync(uri, TestContext.Current.CancellationToken);
        Assert.Equal(HttpStatusCode.TooManyRequests, limited.StatusCode);
        Assert.Equal("application/problem+json", limited.Content.Headers.ContentType?.MediaType);
    }
}
