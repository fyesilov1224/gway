using System.Collections.Concurrent;
using Gway.Modules.Live;

namespace Gway.Api.Tests;

/// <summary>Stands in for the LiveKit server: rooms, participants with their attributes and microphone permission.</summary>
internal sealed class FakeLiveKit : ILiveKit
{
    private readonly ConcurrentDictionary<string, ConcurrentDictionary<string, Person>> _rooms = new();

    internal sealed class Person
    {
        public Dictionary<string, string> Attributes { get; } = [];

        public bool CanPublish { get; set; }
    }

    public ConcurrentBag<(string Room, string Identity)> Removed { get; } = [];

    public bool Fail { get; set; }

    /// <summary>Puts the user in the room as the join token would.</summary>
    public void Join(Guid room, Guid user, string role = "listener") =>
        _rooms[room.ToString()][user.ToString()] = new Person { CanPublish = role == "host", Attributes = { ["role"] = role } };

    public bool HasRoom(Guid room) => _rooms.ContainsKey(room.ToString());

    public bool HasRoom(string room) => _rooms.ContainsKey(room);

    public void CloseRoom(Guid room) => _rooms.TryRemove(room.ToString(), out _);

    public Person? Find(Guid room, Guid user) =>
        _rooms.TryGetValue(room.ToString(), out var people) && people.TryGetValue(user.ToString(), out var p) ? p : null;

    public string CreateJoinToken(
        string room, Guid userId, string name, bool canPublish, IReadOnlyDictionary<string, string> attributes,
        bool canUpdateOwnAttributes = false) =>
        $"token:{room}:{userId}:{canPublish}:{attributes.GetValueOrDefault("role")}" + (canUpdateOwnAttributes ? ":attrs" : "");

    public Task CreateRoomAsync(string room, CancellationToken ct)
    {
        ThrowIfFailing();
        _rooms.TryAdd(room, new());
        return Task.CompletedTask;
    }

    public Task DeleteRoomAsync(string room, CancellationToken ct)
    {
        _rooms.TryRemove(room, out _);
        return Task.CompletedTask;
    }

    public Task<IReadOnlyDictionary<string, int>> ListRoomsAsync(IReadOnlyCollection<string> rooms, CancellationToken ct) =>
        Task.FromResult<IReadOnlyDictionary<string, int>>(
            rooms.Where(_rooms.ContainsKey).ToDictionary(r => r, r => _rooms[r].Count));

    public Task<IReadOnlyList<LiveParticipant>> ListParticipantsAsync(string room, CancellationToken ct) =>
        Task.FromResult<IReadOnlyList<LiveParticipant>>(_rooms.TryGetValue(room, out var people)
            ? [.. people.Select(p => new LiveParticipant(p.Key, new Dictionary<string, string>(p.Value.Attributes)))]
            : []);

    public Task<bool> UpdateParticipantAsync(
        string room, Guid userId, bool? canPublish, IReadOnlyDictionary<string, string> attributes, CancellationToken ct)
    {
        ThrowIfFailing();
        if (!_rooms.TryGetValue(room, out var people) || !people.TryGetValue(userId.ToString(), out var person)) return Task.FromResult(false);
        if (canPublish is { } publish) person.CanPublish = publish;
        foreach (var (key, value) in attributes)
        {
            if (value.Length == 0) person.Attributes.Remove(key);
            else person.Attributes[key] = value;
        }
        return Task.FromResult(true);
    }

    public Task RemoveParticipantAsync(string room, Guid userId, CancellationToken ct)
    {
        if (_rooms.TryGetValue(room, out var people)) people.TryRemove(userId.ToString(), out _);
        Removed.Add((room, userId.ToString()));
        return Task.CompletedTask;
    }

    private void ThrowIfFailing()
    {
        if (Fail) throw new HttpRequestException("LiveKit is down");
    }
}
