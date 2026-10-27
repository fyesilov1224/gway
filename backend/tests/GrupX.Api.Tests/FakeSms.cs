using System.Collections.Concurrent;
using GrupX.Modules.Identity;
using GrupX.SharedKernel;

namespace GrupX.Api.Tests;

/// <summary>Records SMS sends; <see cref="Code"/> is the only correct code. Numbers in <see cref="VoipNumbers"/> look up as VoIP.</summary>
internal sealed class FakeSms : ISmsVerifier
{
    public const string Code = "246810";

    public ConcurrentQueue<string> Sent { get; } = new();

    public ConcurrentDictionary<string, bool> VoipNumbers { get; } = new();

    public bool IsConfigured => true;

    public Task<Result> SendAsync(string phone, string locale, CancellationToken ct)
    {
        Sent.Enqueue(phone);
        return Task.FromResult(Result.Success());
    }

    public Task<Result<bool>> CheckAsync(string phone, string code, CancellationToken ct) =>
        Task.FromResult<Result<bool>>(code == Code);

    public Task<string?> LineTypeAsync(string phone, CancellationToken ct) =>
        Task.FromResult<string?>(VoipNumbers.ContainsKey(phone) ? "nonFixedVoip" : "mobile");
}
