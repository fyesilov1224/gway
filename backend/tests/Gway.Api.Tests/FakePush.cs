using System.Collections.Concurrent;
using Gway.Modules.Notifications;

namespace Gway.Api.Tests;

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

    public ConcurrentQueue<string> Probed { get; } = new();

    public Task<PushResult> ProbeAsync(string token, CancellationToken ct)
    {
        Probed.Enqueue(token);
        return Task.FromResult(token.StartsWith(DeadPrefix, StringComparison.Ordinal) ? PushResult.Unregistered : PushResult.Sent);
    }
}
