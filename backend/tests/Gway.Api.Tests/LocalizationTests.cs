using System.Net;
using System.Net.Http.Json;
using Gway.Modules.Groups;
using Gway.SharedKernel.Localization;
using Microsoft.AspNetCore.Mvc;

namespace Gway.Api.Tests;

/// <summary>Server sentences in the person's language (docs/ARCHITECTURE.md §11, Sunucu).</summary>
public sealed class LocalizationTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public ValueTask DisposeAsync() => _db.DisposeAsync();

    private static string Unique(string prefix) => $"{prefix}{Guid.NewGuid():N}"[..20];

    private static Uri Path(string path) => new(path, UriKind.Relative);

    [Theory]
    [InlineData(null, "Zaten bu grubun üyesisin.")]
    [InlineData("tr", "Zaten bu grubun üyesisin.")]
    [InlineData("en", "You're already a member of this group.")]
    [InlineData("de-DE,de;q=0.9", "Du bist bereits Mitglied dieser Gruppe.")]
    [InlineData("ar", "أنت عضو في هذه المجموعة بالفعل.")]
    [InlineData("ja-JP", "You're already a member of this group.")]
    public async Task Problem_titles_follow_the_requests_language(string? language, string expected)
    {
        var owner = await _db.CreateUserAsync(Unique("lo_"));
        var created = await factory.ClientFor(owner).PostAsJsonAsync(
            Path("/groups"), new CreateGroupRequest(Unique("g_"), "Dil Grubu", "running", "open", null), Ct);
        var group = (await created.Content.ReadFromJsonAsync<CreatedGroup>(Ct))!;
        var client = factory.ClientFor(owner);
        if (language is not null) client.DefaultRequestHeaders.AcceptLanguage.ParseAdd(language);

        var again = await client.PostAsync(Path($"/groups/{group.Id}/join"), null, Ct);

        Assert.Equal(HttpStatusCode.Conflict, again.StatusCode);
        var problem = await again.Content.ReadFromJsonAsync<ProblemDetails>(Ct);
        Assert.Equal(expected, problem!.Title);
        Assert.Equal("group.already_member", problem.Extensions["code"]?.ToString());
    }

    [Fact]
    public void Sentences_with_values_are_matched_as_patterns_the_most_specific_first()
    {
        Assert.Equal("A group can have at most 5 goals at a time.", ServerText.Translate("Bir grupta aynı anda en fazla 5 hedef olabilir.", "en"));
        Assert.Equal("12 members · Join on GWAY.", ServerText.Translate("12 üye · GWAY'de katıl.", "en"));
        Assert.Equal("12 members · Running", ServerText.Translate("12 üye · Running", "en"));
        Assert.Equal("Bilinmeyen bir cümle.", ServerText.Translate("Bilinmeyen bir cümle.", "en"));
    }
}
