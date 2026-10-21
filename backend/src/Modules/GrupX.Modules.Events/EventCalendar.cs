using System.Globalization;
using System.Text;

namespace GrupX.Modules.Events;

/// <summary>One event as an iCalendar (RFC 5545) file for "Takvime ekle".</summary>
internal static class EventCalendar
{
    /// <summary>An event without an end is shown as two hours long.</summary>
    public static readonly TimeSpan DefaultLength = TimeSpan.FromHours(2);

    public static string Build(
        Guid id, string title, string description, string location, DateTimeOffset startsAt, DateTimeOffset? endsAt, bool canceled,
        string? url, DateTimeOffset now)
    {
        var details = url is null ? description : description.Length == 0 ? url : $"{description}\n\n{url}";
        var lines = new List<string>
        {
            "BEGIN:VCALENDAR",
            "VERSION:2.0",
            "PRODID:-//GrupX//Organizasyon//TR",
            "CALSCALE:GREGORIAN",
            "METHOD:PUBLISH",
            "BEGIN:VEVENT",
            $"UID:{id}@grupx.app",
            $"DTSTAMP:{Utc(now)}",
            $"DTSTART:{Utc(startsAt)}",
            $"DTEND:{Utc(endsAt ?? startsAt + DefaultLength)}",
            $"SUMMARY:{Escape(title)}",
            $"LOCATION:{Escape(location)}",
        };
        if (details.Length > 0) lines.Add($"DESCRIPTION:{Escape(details)}");
        if (url is not null) lines.Add($"URL:{url}");
        lines.Add(canceled ? "STATUS:CANCELLED" : "STATUS:CONFIRMED");
        lines.Add("END:VEVENT");
        lines.Add("END:VCALENDAR");

        var ics = new StringBuilder();
        foreach (var line in lines) Fold(ics, line);
        return ics.ToString();
    }

    private static string Utc(DateTimeOffset time) => time.UtcDateTime.ToString("yyyyMMdd'T'HHmmss'Z'", CultureInfo.InvariantCulture);

    private static string Escape(string text) => text
        .Replace("\\", "\\\\", StringComparison.Ordinal)
        .Replace(";", "\\;", StringComparison.Ordinal)
        .Replace(",", "\\,", StringComparison.Ordinal)
        .Replace("\r\n", "\\n", StringComparison.Ordinal)
        .Replace("\n", "\\n", StringComparison.Ordinal);

    /// <summary>Lines are at most 75 octets; continuation lines start with a space. Characters are never split.</summary>
    private static void Fold(StringBuilder ics, string line)
    {
        var octets = 0;
        foreach (var rune in line.EnumerateRunes())
        {
            var size = rune.Utf8SequenceLength;
            if (octets + size > 75)
            {
                ics.Append("\r\n ");
                octets = 1;
            }
            ics.Append(rune.ToString());
            octets += size;
        }
        ics.Append("\r\n");
    }
}
