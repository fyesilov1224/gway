using System.Text.Encodings.Web;
using System.Text.Unicode;
using Microsoft.AspNetCore.Http;

namespace Gway.SharedKernel.Http;

/// <summary>
/// The small page behind a share link (docs/ARCHITECTURE.md §3b, Paylaşım sayfaları): Open Graph tags for link previews,
/// then a redirect to the page in the web app. Only public information goes in.
/// </summary>
public static class SharePage
{
    private static readonly HtmlEncoder Html = HtmlEncoder.Create(UnicodeRanges.All);

    public const string FallbackTitle = "GWAY";
    public const string FallbackDescription = "Gruplar, organizasyonlar ve yeni insanlar. GWAY'de topluluğunu bul.";

    /// <param name="appUrl">The web app (<c>Share:AppUrl</c>); without it the page only shows the preview.</param>
    /// <param name="appPath">The app's route, e.g. <c>/g/doga.yuruyus</c>.</param>
    public static IResult Render(string? appUrl, string appPath, string title, string description, string? imageUrl)
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
        var link = target is null ? "" : $"""<p><a href="{Html.Encode(target)}">GWAY'de aç</a></p>""";
        var html = $"""
            <!doctype html>
            <html lang="tr">
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
        return Results.Content(html, "text/html; charset=utf-8");
    }

    /// <summary>A file in a public Supabase Storage bucket.</summary>
    public static string? PublicImage(string supabaseUrl, string bucket, string? path) =>
        path is null ? null : $"{supabaseUrl.TrimEnd('/')}/storage/v1/object/public/{bucket}/{Uri.EscapeDataString(path).Replace("%2F", "/", StringComparison.Ordinal)}";
}
