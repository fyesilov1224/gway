using System.Collections.Concurrent;
using GrupX.Modules.Notifications;

namespace GrupX.Api.Tests;

/// <summary>Records pushes; tokens starting with <see cref="DeadPrefix"/> belong to removed apps.</summary>
internal sealed class FakePush : IPushSender
{
    public const string DeadPrefix = "dead-";

    public ConcurrentQueue<(string Token, PushMessage Message)> Sent { get; } = new();

    public bool IsConfigured => true;

    public Task<PushResult> SendAsync(string token, PushMessage message, CancellationToken ct)
    {
        if (token.StartsWith(DeadPrefix, StringComparison.Ordinal)) return Task.FromResult(PushResult.Unregistered);
        Sent.Enqueue((token, message));
        return Task.FromResult(PushResult.Sent);
    }
}
