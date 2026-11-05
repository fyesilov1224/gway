using System.Text.Encodings.Web;
using System.Text.Unicode;
using Gway.SharedKernel.Localization;
using Microsoft.AspNetCore.Http;

namespace Gway.SharedKernel.Http;

/// <summary>
/// The small page behind a share link (docs/ARCHITECTURE.md §3b, Paylaşım sayfaları): Open Graph tags for link previews,
/// then a redirect to the page in the web app. Only public information goes in. The texts follow the visitor's
/// language (<c>Accept-Language</c>; docs/ARCHITECTURE.md §11).
/// </summary>
public static class SharePage
{
    private static readonly HtmlEncoder Html = HtmlEncoder.Create(UnicodeRanges.All);

    public const string FallbackTitle = "GWAY";
    public const string FallbackDescription = "Gruplar, organizasyonlar ve yeni insanlar. GWAY'de topluluğunu bul.";

    /// <summary>The page for a link whose group or event is gone: GWAY itself.</summary>
    public static IResult Fallback(string? appUrl) =>
        Render(appUrl, "/groups", _ => FallbackTitle, language => ServerText.Translate(FallbackDescription, language), null);

    /// <param name="appUrl">The web app (<c>Share:AppUrl</c>); without it the page only shows the preview.</param>
    /// <param name="appPath">The app's route, e.g. <c>/g/doga.yuruyus</c>.</param>
    /// <param name="title">The title in a language.</param>
    /// <param name="description">The description in a language.</param>
    public static IResult Render(string? appUrl, string appPath, Func<string, string> title, Func<string, string> description, string? imageUrl) =>
        new Page(appUrl, appPath, title, description, imageUrl);

    private sealed record Page(string? AppUrl, string AppPath, Func<string, string> Title, Func<string, string> Description, string? ImageUrl) : IResult
    {
        public Task ExecuteAsync(HttpContext httpContext)
        {
            var language = ServerText.Of(httpContext);
            return Results.Content(Document(AppUrl, AppPath, Title(language), Description(language), ImageUrl, language), "text/html; charset=utf-8")
                .ExecuteAsync(httpContext);
        }
    }

    private static string Document(string? appUrl, string appPath, string title, string description, string? imageUrl, string language)
    {
        var target = string.IsNullOrWhiteSpace(appUrl) ? null : $"{appUrl.TrimEnd('/')}/#{appPath}";
        var t = Html.Encode(title);
        var d = Html.Encode(description.Length > 200 ? description[..197] + "..." : description);
        var image = imageUrl is null ? "" : $"""<meta property="og:image" content="{Html.Encode(imageUrl)}">""";
        var redirect = target is null
            ? ""
            : $"""
               <meta http-equiv="refresh" content="0; url={Html.Encode(target)}">
               <script>location.replace({System.Text.Json.JsonSerializer.Serialize(target)});</script>
               """;
        var link = target is null ? "" : $"""<p><a href="{Html.Encode(target)}">{Html.Encode(ServerText.Translate("GWAY'de aç", language))}</a></p>""";
        var html = $"""
            <!doctype html>
            <html lang="{language}" dir="{(language == "ar" ? "rtl" : "ltr")}">
            <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <title>{t}</title>
            <meta name="description" content="{d}">
            <meta property="og:type" content="website">
            <meta property="og:site_name" content="GWAY">
            <meta property="og:title" content="{t}">
            <meta property="og:description" content="{d}">
            {image}
            <meta name="twitter:card" content="{(imageUrl is null ? "summary" : "summary_large_image")}">
            {redirect}
            </head>
            <body style="font-family:sans-serif;color:#1F2033;background:#FFFFFF;padding:24px">
            <h1 style="font-size:20px">{t}</h1>
            <p style="color:#5C5F77">{d}</p>
            {link}
            </body>
            </html>
            """;
        return html;
    }

    /// <summary>A file in a public Supabase Storage bucket.</summary>
    public static string? PublicImage(string supabaseUrl, string bucket, string? path) =>
        path is null ? null : $"{supabaseUrl.TrimEnd('/')}/storage/v1/object/public/{bucket}/{Uri.EscapeDataString(path).Replace("%2F", "/", StringComparison.Ordinal)}";
}
