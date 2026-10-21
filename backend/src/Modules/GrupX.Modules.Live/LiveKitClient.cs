using System.Buffers.Text;
using System.Net;
using System.Net.Http.Json;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Options;

namespace GrupX.Modules.Live;

/// <summary><c>LiveKit</c> configuration (docs/ARCHITECTURE.md §8, Yapılandırma). Keys come from the environment.</summary>
public sealed class LiveKitOptions
{
    public const string Section = "LiveKit";

    /// <summary>Address clients connect to, e.g. <c>wss://live.grupx.app</c>.</summary>
    public string Url { get; set; } = "";

    /// <summary>Server API address; defaults to <see cref="Url"/> over http(s).</summary>
    public string ApiUrl { get; set; } = "";

    public string ApiKey { get; set; } = "";

    public string ApiSecret { get; set; } = "";

    public bool IsConfigured => Url.Length > 0 && ApiKey.Length > 0 && ApiSecret.Length > 0;

    public Uri ServerUri => new((ApiUrl.Length > 0 ? ApiUrl : Url.Replace("wss://", "https://", StringComparison.Ordinal)
        .Replace("ws://", "http://", StringComparison.Ordinal)).TrimEnd('/') + "/");
}

/// <summary>A participant in a room; the server keeps <c>role</c>, <c>hand</c> and <c>muted</c> in its attributes.</summary>
internal sealed record LiveParticipant(string Identity, IReadOnlyDictionary<string, string> Attributes)
{
    public string Role => Attributes.GetValueOrDefault(LiveRoles.Attribute) ?? LiveRoles.Listener;

    public bool OnStage => Role is LiveRoles.Host or LiveRoles.Speaker;
}

internal static class LiveRoles
{
    public const string Attribute = "role";
    public const string Host = "host";
    public const string Speaker = "speaker";
    public const string Listener = "listener";
}

/// <summary>LiveKit access tokens and the room service API. Tests replace it with a fake.</summary>
internal interface ILiveKit
{
    /// <summary>A 10-minute join token. Only the server changes permissions and attributes afterwards.</summary>
    string CreateJoinToken(string room, Guid userId, string name, bool canPublish, IReadOnlyDictionary<string, string> attributes);

    Task CreateRoomAsync(string room, CancellationToken ct);

    /// <summary>Closes the room and disconnects everyone; a missing room is fine.</summary>
    Task DeleteRoomAsync(string room, CancellationToken ct);

    /// <summary>Participant counts of the rooms that exist.</summary>
    Task<IReadOnlyDictionary<string, int>> ListRoomsAsync(IReadOnlyCollection<string> rooms, CancellationToken ct);

    Task<IReadOnlyList<LiveParticipant>> ListParticipantsAsync(string room, CancellationToken ct);

    /// <summary>Sets the microphone permission (when given) and attributes ("" removes one). False when the user is not in the room.</summary>
    Task<bool> UpdateParticipantAsync(
        string room, Guid userId, bool? canPublish, IReadOnlyDictionary<string, string> attributes, CancellationToken ct);

    /// <summary>Disconnects the user; not being in the room is fine.</summary>
    Task RemoveParticipantAsync(string room, Guid userId, CancellationToken ct);
}

/// <summary>LiveKit over its Twirp JSON API, signed with HS256 tokens (no SDK needed).</summary>
internal sealed class LiveKitClient(HttpClient http, IOptions<LiveKitOptions> options, TimeProvider time) : ILiveKit
{
    private static readonly TimeSpan JoinTokenLifetime = TimeSpan.FromMinutes(10);
    private static readonly string[] MicrophoneOnly = ["microphone"];

    private LiveKitOptions Options => options.Value;

    public string CreateJoinToken(string room, Guid userId, string name, bool canPublish, IReadOnlyDictionary<string, string> attributes) =>
        Sign(JoinTokenLifetime, new Dictionary<string, object>
        {
            ["sub"] = userId.ToString(),
            ["name"] = name,
            ["attributes"] = attributes,
            ["video"] = new Dictionary<string, object>
            {
                ["room"] = room,
                ["roomJoin"] = true,
                ["canSubscribe"] = true,
                ["canPublish"] = canPublish,
                ["canPublishData"] = true,
                ["canPublishSources"] = MicrophoneOnly,
                ["canUpdateOwnMetadata"] = false,
            },
        });

    public Task CreateRoomAsync(string room, CancellationToken ct) =>
        CallAsync("CreateRoom", new { name = room, emptyTimeout = 300, departureTimeout = 30 }, room, ct);

    public Task DeleteRoomAsync(string room, CancellationToken ct) => CallAsync("DeleteRoom", new { room }, room, ct);

    public async Task<IReadOnlyDictionary<string, int>> ListRoomsAsync(IReadOnlyCollection<string> rooms, CancellationToken ct)
    {
        var result = new Dictionary<string, int>();
        if (rooms.Count == 0) return result;
        var json = await CallAsync("ListRooms", new { names = rooms }, null, ct);
        if (json is { } body && body.TryGetProperty("rooms", out var list))
        {
            foreach (var r in list.EnumerateArray())
            {
                result[r.GetProperty("name").GetString()!] = Field(r, "numParticipants", "num_participants") is { } n ? n.GetInt32() : 0;
            }
        }
        return result;
    }

    public async Task<IReadOnlyList<LiveParticipant>> ListParticipantsAsync(string room, CancellationToken ct)
    {
        var json = await CallAsync("ListParticipants", new { room }, room, ct);
        var result = new List<LiveParticipant>();
        if (json is { } body && body.TryGetProperty("participants", out var list))
        {
            foreach (var p in list.EnumerateArray()) result.Add(Read(p));
        }
        return result;
    }

    public async Task<bool> UpdateParticipantAsync(
        string room, Guid userId, bool? canPublish, IReadOnlyDictionary<string, string> attributes, CancellationToken ct)
    {
        object body = canPublish is { } publish
            ? new
            {
                room,
                identity = userId.ToString(),
                attributes,
                permission = new
                {
                    canSubscribe = true,
                    canPublish = publish,
                    canPublishData = true,
                    canPublishSources = new[] { "MICROPHONE" },
                },
            }
            : new { room, identity = userId.ToString(), attributes };
        return await CallAsync("UpdateParticipant", body, room, ct) is not null;
    }

    public Task RemoveParticipantAsync(string room, Guid userId, CancellationToken ct) =>
        CallAsync("RemoveParticipant", new { room, identity = userId.ToString() }, room, ct);

    private static LiveParticipant Read(JsonElement p)
    {
        var attributes = new Dictionary<string, string>();
        if (p.TryGetProperty("attributes", out var a) && a.ValueKind == JsonValueKind.Object)
        {
            foreach (var kv in a.EnumerateObject()) attributes[kv.Name] = kv.Value.GetString() ?? "";
        }
        return new LiveParticipant(p.GetProperty("identity").GetString()!, attributes);
    }

    private static JsonElement? Field(JsonElement element, string camel, string snake) =>
        element.TryGetProperty(camel, out var v) || element.TryGetProperty(snake, out v) ? v : null;

    /// <summary>Calls a room service method; null when LiveKit answers "not found" (room or participant).</summary>
    private async Task<JsonElement?> CallAsync(string method, object body, string? room, CancellationToken ct)
    {
        var grant = new Dictionary<string, object> { ["roomCreate"] = true, ["roomList"] = true, ["roomAdmin"] = true };
        if (room is not null) grant["room"] = room;

        using var request = new HttpRequestMessage(HttpMethod.Post, new Uri(Options.ServerUri, $"twirp/livekit.RoomService/{method}"))
        {
            Content = JsonContent.Create(body),
        };
        request.Headers.Authorization = new("Bearer", Sign(TimeSpan.FromMinutes(1), new Dictionary<string, object> { ["video"] = grant }));

        using var response = await http.SendAsync(request, ct);
        if (response.StatusCode == HttpStatusCode.NotFound) return null;
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<JsonElement>(ct);
    }

    private string Sign(TimeSpan lifetime, Dictionary<string, object> claims)
    {
        var now = time.GetUtcNow().ToUnixTimeSeconds();
        claims["iss"] = Options.ApiKey;
        claims["nbf"] = now - 10;
        claims["exp"] = now + (long)lifetime.TotalSeconds;

        var header = Base64Url.EncodeToString("""{"alg":"HS256","typ":"JWT"}"""u8);
        var payload = Base64Url.EncodeToString(JsonSerializer.SerializeToUtf8Bytes(claims));
        var signature = HMACSHA256.HashData(Encoding.UTF8.GetBytes(Options.ApiSecret), Encoding.ASCII.GetBytes($"{header}.{payload}"));
        return $"{header}.{payload}.{Base64Url.EncodeToString(signature)}";
    }
}
