using Gway.SharedKernel;
using Gway.SharedKernel.Auditing;
using Gway.SharedKernel.Database;
using Npgsql;

namespace Gway.Modules.Admin;

/// <summary>One version of a legal text in the list (docs/ARCHITECTURE.md §8b, Hukuki metin yönetimi).</summary>
public sealed record AdminLegalVersion(
    int Version,
    string Title,
    DateTimeOffset PublishedAt,
    bool IsCurrent,
    bool IsDraft,
    int ConsentCount);

/// <summary>A legal text kind with its versions, newest first.</summary>
public sealed record AdminLegalKind(string Kind, string Audience, IReadOnlyList<AdminLegalVersion> Versions);

/// <summary>A version's full body, for editing.</summary>
public sealed record AdminLegalDocument(string Kind, int Version, string Title, string Body, DateTimeOffset PublishedAt, int ConsentCount);

public sealed record LegalVersionRequest(string Title, string Body, DateTimeOffset? PublishedAt);

/// <summary>An informational translation of a version (docs/ARCHITECTURE.md §11, Hukuki metin çevirileri).</summary>
public sealed record AdminLegalTranslation(string Language, string Title, string Body, DateTimeOffset UpdatedAt);

public sealed record LegalTranslationRequest(string Title, string Body);

/// <summary>
/// Manages <c>public.legal_documents</c> for the admin panel. A version anyone has consented to is frozen
/// (the DB guard enforces it too); text is changed by publishing a new version.
/// </summary>
internal sealed class AdminLegal(NpgsqlDataSource db, TimeProvider time)
{
    // The kinds and their fixed audience (mirrors the table's check constraints).
    public static readonly IReadOnlyDictionary<string, string> Audiences = new Dictionary<string, string>
    {
        ["privacy_notice"] = "signup",
        ["explicit_consent"] = "signup",
        ["terms"] = "signup",
        ["community_rules"] = "signup",
        ["distance_sales"] = "purchase",
    };

    private static readonly Error NotFound = Error.NotFound("admin.legal_not_found", "Bu hukuki metin sürümü bulunamadı.");

    private static readonly Error Frozen = Error.Conflict(
        "admin.legal_consented", "Bu sürüm en az bir kullanıcı tarafından onaylandığı için değiştirilemez. Yeni bir sürüm yayınla.");

    private static Error RuleError(string code) => code switch
    {
        "legal_consented_immutable" => Frozen,
        _ => Error.RuleViolation($"legal.{code}", "Bu işlem şu anda yapılamıyor. Sayfayı yenileyip tekrar dene."),
    };

    public static bool IsKind(string kind) => Audiences.ContainsKey(kind);

    public async Task<IReadOnlyList<AdminLegalKind>> ListAsync(CancellationToken ct)
    {
        var byKind = new Dictionary<string, List<AdminLegalVersion>>();
        await using (var cmd = db.CreateCommand(
            """
            select d.kind, d.version, d.title, d.published_at,
                   d.version = (select max(x.version) from public.legal_documents x
                                where x.kind = d.kind and x.published_at <= now()) as is_current,
                   d.published_at > now() as is_draft,
                   (select count(*)::int from public.consents c where c.kind = d.kind and c.version = d.version) as consents
            from public.legal_documents d
            order by d.kind, d.version desc
            """))
        {
            await using var r = await cmd.ExecuteReaderAsync(ct);
            while (await r.ReadAsync(ct))
            {
                var kind = r.GetString(0);
                if (!byKind.TryGetValue(kind, out var list)) byKind[kind] = list = [];
                list.Add(new AdminLegalVersion(
                    r.GetInt32(1), r.GetString(2), r.GetFieldValue<DateTimeOffset>(3),
                    !r.IsDBNull(4) && r.GetBoolean(4), r.GetBoolean(5), r.GetInt32(6)));
            }
        }

        // Every known kind appears, even with no versions yet, so the admin can start one.
        return Audiences.Keys
            .Select(kind => new AdminLegalKind(kind, Audiences[kind],
                byKind.TryGetValue(kind, out var v) ? v : []))
            .ToList();
    }

    public async Task<Result<AdminLegalDocument>> GetAsync(string kind, int version, CancellationToken ct)
    {
        if (!IsKind(kind)) return NotFound;
        await using var cmd = db.CreateCommand(
            """
            select d.title, d.body, d.published_at,
                   (select count(*)::int from public.consents c where c.kind = d.kind and c.version = d.version)
            from public.legal_documents d where d.kind = @kind and d.version = @version
            """);
        cmd.Parameters.AddWithValue("kind", kind);
        cmd.Parameters.AddWithValue("version", version);
        await using var r = await cmd.ExecuteReaderAsync(ct);
        if (!await r.ReadAsync(ct)) return NotFound;
        return new AdminLegalDocument(kind, version, r.GetString(0), r.GetString(1), r.GetFieldValue<DateTimeOffset>(2), r.GetInt32(3));
    }

    private Result<(string Title, string Body, DateTimeOffset PublishedAt)> Validate(string kind, LegalVersionRequest body)
    {
        if (!IsKind(kind)) return NotFound;
        ArgumentNullException.ThrowIfNull(body);
        var title = body.Title?.Trim() ?? "";
        var text = body.Body?.Trim() ?? "";
        if (title.Length is < 3 or > 200) return Error.Validation("admin.legal_title", "Başlık 3–200 karakter olmalı.");
        if (text.Length is < 20 or > 100_000) return Error.Validation("admin.legal_body", "Metin 20–100.000 karakter olmalı.");
        // Default to now; a future time keeps the version hidden until then.
        var at = body.PublishedAt ?? time.GetUtcNow();
        if (at > time.GetUtcNow().AddYears(5)) return Error.Validation("admin.legal_published_at", "Yayın zamanı en fazla 5 yıl ileride olabilir.");
        return (title, text, at);
    }

    /// <summary>Publishes a new version of the kind (version = max+1).</summary>
    public async Task<Result<int>> PublishAsync(Guid actorId, string kind, LegalVersionRequest body, CancellationToken ct)
    {
        var valid = Validate(kind, body);
        if (!valid.IsSuccess) return valid.Error;
        var (title, text, at) = valid.Value;

        return await ActingTransaction.RunAsync<int>(db, actorId, async (conn, tx) =>
        {
            int version;
            await using (var cmd = new NpgsqlCommand(
                """
                insert into public.legal_documents (kind, version, title, body, audience, published_at)
                values (@kind, coalesce((select max(version) from public.legal_documents where kind = @kind), 0) + 1,
                        @title, @body, @audience, @at)
                returning version
                """, conn, tx))
            {
                cmd.Parameters.AddWithValue("kind", kind);
                cmd.Parameters.AddWithValue("title", title);
                cmd.Parameters.AddWithValue("body", text);
                cmd.Parameters.AddWithValue("audience", Audiences[kind]);
                cmd.Parameters.AddWithValue("at", at);
                version = (int)(await cmd.ExecuteScalarAsync(ct))!;
            }
            await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.Staff, "legal.published", "legal_document",
                $"{kind}/{version}", new { kind, version, title, publishedAt = at }), ct);
            return version;
        }, RuleError, ct);
    }

    /// <summary>Edits a version that no one has consented to yet.</summary>
    public async Task<Result> UpdateAsync(Guid actorId, string kind, int version, LegalVersionRequest body, CancellationToken ct)
    {
        var valid = Validate(kind, body);
        if (!valid.IsSuccess) return valid.Error;
        var (title, text, at) = valid.Value;

        var result = await ActingTransaction.RunAsync<bool>(db, actorId, async (conn, tx) =>
        {
            if (await ConsentCountAsync(conn, tx, kind, version, ct) is not { } consents) return NotFound;
            if (consents > 0) return Frozen;
            await using (var cmd = new NpgsqlCommand(
                "update public.legal_documents set title = @title, body = @body, published_at = @at where kind = @kind and version = @version",
                conn, tx))
            {
                cmd.Parameters.AddWithValue("kind", kind);
                cmd.Parameters.AddWithValue("version", version);
                cmd.Parameters.AddWithValue("title", title);
                cmd.Parameters.AddWithValue("body", text);
                cmd.Parameters.AddWithValue("at", at);
                await cmd.ExecuteNonQueryAsync(ct);
            }
            await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.Staff, "legal.updated", "legal_document",
                $"{kind}/{version}", new { kind, version, title, publishedAt = at }), ct);
            return true;
        }, RuleError, ct);
        return result.IsSuccess ? Result.Success() : result.Error;
    }

    /// <summary>Deletes a version that no one has consented to yet.</summary>
    public async Task<Result> DeleteAsync(Guid actorId, string kind, int version, CancellationToken ct)
    {
        if (!IsKind(kind)) return NotFound;
        var result = await ActingTransaction.RunAsync<bool>(db, actorId, async (conn, tx) =>
        {
            if (await ConsentCountAsync(conn, tx, kind, version, ct) is not { } consents) return NotFound;
            if (consents > 0) return Frozen;
            await using (var cmd = new NpgsqlCommand(
                "delete from public.legal_documents where kind = @kind and version = @version", conn, tx))
            {
                cmd.Parameters.AddWithValue("kind", kind);
                cmd.Parameters.AddWithValue("version", version);
                await cmd.ExecuteNonQueryAsync(ct);
            }
            await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.Staff, "legal.deleted", "legal_document",
                $"{kind}/{version}", new { kind, version }), ct);
            return true;
        }, RuleError, ct);
        return result.IsSuccess ? Result.Success() : result.Error;
    }

    /// <summary>The languages a translation can be in: every app language but Turkish, the binding original.</summary>
    public static readonly IReadOnlySet<string> TranslationLanguages =
        new HashSet<string>(["en", "de", "fr", "nl", "es", "pt", "it", "ru", "ar", "az", "uk"]);

    private static readonly Error UnknownLanguage = Error.Validation("admin.legal_language", "Bu dil için çeviri eklenemez.");

    public async Task<Result<IReadOnlyList<AdminLegalTranslation>>> TranslationsAsync(string kind, int version, CancellationToken ct)
    {
        if (!IsKind(kind)) return NotFound;
        await using var cmd = db.CreateCommand(
            """
            select t.language, t.title, t.body, t.updated_at from public.legal_document_translations t
            where t.kind = @kind and t.version = @version order by t.language
            """);
        cmd.Parameters.AddWithValue("kind", kind);
        cmd.Parameters.AddWithValue("version", version);
        var list = new List<AdminLegalTranslation>();
        await using var r = await cmd.ExecuteReaderAsync(ct);
        while (await r.ReadAsync(ct))
            list.Add(new AdminLegalTranslation(r.GetString(0), r.GetString(1), r.GetString(2), r.GetFieldValue<DateTimeOffset>(3)));
        return list;
    }

    /// <summary>Adds or corrects a translation; unlike the Turkish text it may change after consents.</summary>
    public async Task<Result> SaveTranslationAsync(
        Guid actorId, string kind, int version, string language, LegalTranslationRequest body, CancellationToken ct)
    {
        if (!IsKind(kind)) return NotFound;
        if (!TranslationLanguages.Contains(language)) return UnknownLanguage;
        ArgumentNullException.ThrowIfNull(body);
        var title = body.Title?.Trim() ?? "";
        var text = body.Body?.Trim() ?? "";
        if (title.Length is < 3 or > 200) return Error.Validation("admin.legal_title", "Başlık 3–200 karakter olmalı.");
        if (text.Length is < 20 or > 100_000) return Error.Validation("admin.legal_body", "Metin 20–100.000 karakter olmalı.");

        var result = await ActingTransaction.RunAsync<bool>(db, actorId, async (conn, tx) =>
        {
            if (await ConsentCountAsync(conn, tx, kind, version, ct) is null) return NotFound;
            await using (var cmd = new NpgsqlCommand(
                """
                insert into public.legal_document_translations (kind, version, language, title, body)
                values (@kind, @version, @language, @title, @body)
                on conflict (kind, version, language) do update set title = excluded.title, body = excluded.body, updated_at = now()
                """, conn, tx))
            {
                cmd.Parameters.AddWithValue("kind", kind);
                cmd.Parameters.AddWithValue("version", version);
                cmd.Parameters.AddWithValue("language", language);
                cmd.Parameters.AddWithValue("title", title);
                cmd.Parameters.AddWithValue("body", text);
                await cmd.ExecuteNonQueryAsync(ct);
            }
            await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.Staff, "legal.translation_saved", "legal_document",
                $"{kind}/{version}/{language}", new { kind, version, language, title }), ct);
            return true;
        }, RuleError, ct);
        return result.IsSuccess ? Result.Success() : result.Error;
    }

    public async Task<Result> DeleteTranslationAsync(Guid actorId, string kind, int version, string language, CancellationToken ct)
    {
        if (!IsKind(kind)) return NotFound;
        if (!TranslationLanguages.Contains(language)) return UnknownLanguage;
        var result = await ActingTransaction.RunAsync<bool>(db, actorId, async (conn, tx) =>
        {
            await using (var cmd = new NpgsqlCommand(
                "delete from public.legal_document_translations where kind = @kind and version = @version and language = @language", conn, tx))
            {
                cmd.Parameters.AddWithValue("kind", kind);
                cmd.Parameters.AddWithValue("version", version);
                cmd.Parameters.AddWithValue("language", language);
                if (await cmd.ExecuteNonQueryAsync(ct) == 0) return NotFound;
            }
            await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.Staff, "legal.translation_deleted", "legal_document",
                $"{kind}/{version}/{language}", new { kind, version, language }), ct);
            return true;
        }, RuleError, ct);
        return result.IsSuccess ? Result.Success() : result.Error;
    }

    /// <summary>Null when the version does not exist.</summary>
    private static async Task<int?> ConsentCountAsync(NpgsqlConnection conn, NpgsqlTransaction tx, string kind, int version, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand(
            """
            select (select count(*)::int from public.consents c where c.kind = d.kind and c.version = d.version)
            from public.legal_documents d where d.kind = @kind and d.version = @version
            """, conn, tx);
        cmd.Parameters.AddWithValue("kind", kind);
        cmd.Parameters.AddWithValue("version", version);
        return await cmd.ExecuteScalarAsync(ct) as int?;
    }
}
