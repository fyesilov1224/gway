using System.Globalization;
using System.Text.Json;
using System.Text.RegularExpressions;
using Microsoft.AspNetCore.Http;

namespace Gway.SharedKernel.Localization;

/// <summary>
/// Server sentences in the person's language (docs/ARCHITECTURE.md §11, Sunucu). The source is the Turkish sentence
/// itself; <c>server_texts.json</c> (written by <c>app/tool/l10n/server_write.py</c>) holds the other 11 languages.
/// A sentence built with values (<c>$"... {max} ..."</c>) is matched as a pattern, so callers keep writing Turkish.
/// An unknown sentence or language stays Turkish.
/// </summary>
public static partial class ServerText
{
    public const string Turkish = "tr";

    /// <summary>The 12 app languages; the first is the source.</summary>
    public static readonly IReadOnlyList<string> Languages;

    private static readonly Dictionary<string, int> Index;
    private static readonly Dictionary<string, string[]> Exact;
    private static readonly List<(Regex Pattern, string[] Translations)> Patterns;

    static ServerText()
    {
        using var stream = typeof(ServerText).Assembly.GetManifestResourceStream("Gway.SharedKernel.Localization.server_texts.json")
            ?? throw new InvalidOperationException("server_texts.json is not embedded.");
        using var json = JsonDocument.Parse(stream);
        var others = json.RootElement.GetProperty("languages").EnumerateArray().Select(l => l.GetString()!).ToArray();
        Languages = [Turkish, .. others];
        Index = others.Select((code, i) => (code, i)).ToDictionary(x => x.code, x => x.i);
        Exact = json.RootElement.GetProperty("texts").EnumerateObject()
            .ToDictionary(e => e.Name, e => e.Value.EnumerateArray().Select(v => v.GetString()!).ToArray(), StringComparer.Ordinal);
        // The most specific pattern first: "{0} üye · GWAY'de katıl." before "{0} üye · {1}".
        Patterns = Exact.Where(e => Placeholder().IsMatch(e.Key))
            .OrderByDescending(e => Placeholder().Replace(e.Key, "").Length)
            .Select(e => (new Regex("^" + Placeholder().Replace(Regex.Escape(e.Key).Replace(@"\{", "{"), m => $"(?<p{m.Groups[1].Value}>.+?)") + "$",
                RegexOptions.Singleline | RegexOptions.CultureInvariant), e.Value))
            .ToList();
    }

    /// <summary>The Turkish sentence (with its values already filled in) in <paramref name="language"/>.</summary>
    public static string Translate(string turkish, string language)
    {
        var index = IndexOf(language);
        if (index < 0) return turkish;
        if (Exact.TryGetValue(turkish, out var exact)) return exact[index];
        foreach (var (pattern, translations) in Patterns)
        {
            var match = pattern.Match(turkish);
            if (!match.Success) continue;
            return Placeholder().Replace(translations[index], m => match.Groups[$"p{m.Groups[1].Value}"].Value);
        }
        return turkish;
    }

    /// <summary>A sentence written with <c>{0}</c>, <c>{1}</c>: translated, then filled with <paramref name="values"/>.</summary>
    public static string Format(string language, string turkishTemplate, params object?[] values)
    {
        var index = IndexOf(language);
        var template = index >= 0 && Exact.TryGetValue(turkishTemplate, out var t) ? t[index] : turkishTemplate;
        return Placeholder().Replace(template, m => Convert.ToString(values[int.Parse(m.Groups[1].Value, CultureInfo.InvariantCulture)],
            CultureInfo.InvariantCulture) ?? "");
    }

    /// <summary>One of the 12 codes; anything else (or nothing) is Turkish.</summary>
    public static string Normalize(string? code) =>
        code is { Length: >= 2 } && Languages.Contains(code[..2].ToLowerInvariant()) ? code[..2].ToLowerInvariant() : Turkish;

    /// <summary>
    /// The request's language: the app sends its own in <c>Accept-Language</c>; a browser's list is read in order.
    /// No header means Turkish; a header with none of the 12 means English.
    /// </summary>
    public static string Of(HttpContext? http)
    {
        var header = http?.Request.Headers.AcceptLanguage.ToString();
        if (string.IsNullOrWhiteSpace(header)) return Turkish;
        foreach (var part in header.Split(','))
        {
            var tag = part.Split(';')[0].Trim();
            if (tag.Length >= 2 && Languages.Contains(tag[..2].ToLowerInvariant())) return tag[..2].ToLowerInvariant();
        }
        return "en";
    }

    /// <summary>Puts a problem's title (a Turkish <see cref="Error.Message"/>) into the request's language.</summary>
    public static void LocalizeProblem(ProblemDetailsContext context)
    {
        if (context.ProblemDetails.Title is { } title)
            context.ProblemDetails.Title = Translate(title, Of(context.HttpContext));
    }

    /// <summary><c>27 Ekim 2026, 20:00</c> in Turkey time, in the language's own order and month names.</summary>
    public static string FormatDateTime(DateTimeOffset at, string language)
    {
        var t = TimeZoneInfo.ConvertTime(at, Turkey);
        var code = Normalize(language);
        // Arabic with the Gregorian calendar, as in the app.
        var culture = CultureInfo.GetCultureInfo(code == "ar" ? "ar-AE" : code);
        var pattern = code switch
        {
            "en" => "MMMM d, yyyy, h:mm tt",
            "de" => "d. MMMM yyyy, HH:mm",
            _ => "d MMMM yyyy, HH:mm",
        };
        return t.ToString(pattern, culture);
    }

    private static readonly TimeZoneInfo Turkey = TimeZoneInfo.FindSystemTimeZoneById("Europe/Istanbul");

    private static int IndexOf(string language) => Index.TryGetValue(language, out var i) ? i : -1;

    [GeneratedRegex(@"\{(\d)\}")]
    private static partial Regex Placeholder();
}
