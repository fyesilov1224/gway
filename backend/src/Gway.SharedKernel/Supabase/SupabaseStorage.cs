using System.Net.Http.Json;
using Microsoft.Extensions.Options;

namespace Gway.SharedKernel.Supabase;

public interface ISupabaseStorage
{
    /// <summary>Deletes every object directly inside <paramref name="folder"/> of <paramref name="bucket"/>. Idempotent.</summary>
    Task DeleteFolderAsync(string bucket, string folder, CancellationToken ct);

    /// <summary>Deletes the given objects of <paramref name="bucket"/>. Missing objects are ignored.</summary>
    Task DeleteObjectsAsync(string bucket, IReadOnlyList<string> paths, CancellationToken ct);

    /// <summary>Signed download URLs for the given objects, by path; missing objects are left out.</summary>
    Task<IReadOnlyDictionary<string, string>> CreateSignedUrlsAsync(string bucket, IReadOnlyList<string> paths, TimeSpan lifetime, CancellationToken ct);
}

/// <summary>Supabase Storage admin calls using the service role key.</summary>
public sealed class SupabaseStorage(HttpClient http, IOptions<SupabaseOptions> options) : ISupabaseStorage
{
    private sealed record ListRequest(string Prefix, int Limit);

    private sealed record StorageObject(string Name);

    private sealed record DeleteRequest(IReadOnlyList<string> Prefixes);

    private sealed record SignRequest(int ExpiresIn, IReadOnlyList<string> Paths);

    private sealed record SignedObject(string? Path, string? SignedURL, string? Error);

    public async Task DeleteFolderAsync(string bucket, string folder, CancellationToken ct)
    {
        while (true)
        {
            var list = await Send<IReadOnlyList<StorageObject>>(
                HttpMethod.Post, $"storage/v1/object/list/{bucket}", new ListRequest(folder, 1000), ct);
            if (list is null || list.Count == 0) return;

            var paths = list.Select(o => $"{folder}/{o.Name}").ToList();
            await Send<object>(HttpMethod.Delete, $"storage/v1/object/{bucket}", new DeleteRequest(paths), ct);
        }
    }

    public async Task DeleteObjectsAsync(string bucket, IReadOnlyList<string> paths, CancellationToken ct)
    {
        ArgumentNullException.ThrowIfNull(paths);
        if (paths.Count > 0) await Send<object>(HttpMethod.Delete, $"storage/v1/object/{bucket}", new DeleteRequest(paths), ct);
    }

    public async Task<IReadOnlyDictionary<string, string>> CreateSignedUrlsAsync(
        string bucket, IReadOnlyList<string> paths, TimeSpan lifetime, CancellationToken ct)
    {
        ArgumentNullException.ThrowIfNull(paths);
        if (paths.Count == 0) return new Dictionary<string, string>();
        var signed = await Send<IReadOnlyList<SignedObject>>(
            HttpMethod.Post, $"storage/v1/object/sign/{bucket}", new SignRequest((int)lifetime.TotalSeconds, paths), ct);
        // signedURL is relative to /storage/v1.
        var root = options.Value.Url.TrimEnd('/') + "/storage/v1";
        return (signed ?? [])
            .Where(o => o.Path is not null && o.SignedURL is not null && o.Error is null)
            .ToDictionary(o => o.Path!, o => root + o.SignedURL);
    }

    private async Task<T?> Send<T>(HttpMethod method, string path, object body, CancellationToken ct)
    {
        var key = options.Value.ServiceRoleKey;
        using var request = new HttpRequestMessage(method, new Uri(new Uri(options.Value.Url.TrimEnd('/') + "/"), path))
        {
            Content = JsonContent.Create(body),
        };
        request.Headers.Add("apikey", key);
        request.Headers.Authorization = new("Bearer", key);

        using var response = await http.SendAsync(request, ct);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<T>(ct);
    }
}
