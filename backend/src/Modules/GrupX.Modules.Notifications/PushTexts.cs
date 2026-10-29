using System.Globalization;

namespace GrupX.Modules.Notifications;

/// <summary>A claimed notification with what its sentence needs (the columns of <c>my_notifications</c>).</summary>
internal sealed record PendingPush(
    long Id,
    Guid RecipientId,
    string Type,
    DateTimeOffset CreatedAt,
    string ActorUsername,
    string? Comment,
    Guid? LiveId,
    string? LiveTitle,
    DateTimeOffset? LiveScheduledAt,
    string? EventTitle,
    DateTimeOffset? EventStartsAt,
    string? GroupName,
    string? SanctionType,
    string? GoalTitle);

/// <summary>The same Turkish sentences as the app's notification list (<c>AppNotification.action</c> in Flutter).</summary>
internal static class PushTexts
{
    private static readonly string[] Months =
        ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"];

    private static readonly TimeZoneInfo Turkey = TimeZoneInfo.FindSystemTimeZoneById("Europe/Istanbul");

    public static PushMessage For(PendingPush n)
    {
        var data = new Dictionary<string, string>
        {
            ["type"] = n.Type,
            ["notification_id"] = n.Id.ToString(CultureInfo.InvariantCulture),
        };
        if (n.LiveId is { } live) data["live_id"] = live.ToString();
        return new PushMessage(Lead(n), Action(n), data);
    }

    /// <summary>The group for group notices, nobody for a match (who it is needs a package), otherwise the person.</summary>
    private static string Lead(PendingPush n) => n.Type switch
    {
        "sanction_applied" or "appeal_decided" or "league_result" => n.GroupName ?? "",
        "match_created" => "Yeni bir eşleşmen var!",
        "event_series_limit" => "Tekrarlayan organizasyon",
        _ => n.ActorUsername,
    };

    private static string Action(PendingPush n) => n.Type switch
    {
        "like" => "gönderini beğendi.",
        "comment" => $"yorum yaptı: {n.Comment}",
        "reply" => $"yorumuna yanıt verdi: {n.Comment}",
        "comment_like" => $"yorumunu beğendi: {n.Comment}",
        "mention" => n.Comment is null ? "bir gönderide senden bahsetti." : $"bir yorumda senden bahsetti: {n.Comment}",
        "follow" => "seni takip etmeye başladı.",
        "follow_request" => "seni takip etmek istiyor.",
        "follow_accepted" => "takip isteğini kabul etti.",
        "live_scheduled" => n.LiveScheduledAt is { } at
            ? $"{DateTimeTr(at)} için canlı yayın planladı: {n.LiveTitle}"
            : $"canlı yayın planladı: {n.LiveTitle}",
        "live_started" => $"canlı yayına başladı: {n.LiveTitle}",
        "event_promoted" => $"\"{n.EventTitle}\" için yer açıldı, artık katılıyorsun.",
        "event_updated" => $"\"{n.EventTitle}\" organizasyonunun zamanını ya da yerini değiştirdi.",
        "event_canceled" => $"\"{n.EventTitle}\" organizasyonunu iptal etti.",
        "event_reminder" => n.EventStartsAt is { } starts && starts - n.CreatedAt > TimeSpan.FromHours(1)
            ? $"\"{n.EventTitle}\" yarın başlıyor. Geliyor musun? Teyit et."
            : $"\"{n.EventTitle}\" 1 saat içinde başlıyor.",
        "case_vote" => $"{n.GroupName} grubunda bir disiplin dosyası açtı; oyunu bekliyor.",
        "sanction_applied" => n.SanctionType switch
        {
            "mute" => "grubunda susturuldun. Ayrıntılar ve itiraz için dokun.",
            "kick" => "grubundan çıkarıldın. Ayrıntılar ve itiraz için dokun.",
            "ban" => "grubundan uzaklaştırıldın. Ayrıntılar ve itiraz için dokun.",
            _ => "grubu sana uyarı verdi. Ayrıntılar ve itiraz için dokun.",
        },
        "appeal_submitted" => $"{n.GroupName} grubundaki yaptırıma itiraz etti.",
        "appeal_decided" => "grubu itirazını karara bağladı.",
        "event_approved" => $"\"{n.EventTitle}\" için katılım isteğini onayladı.",
        "event_declined" => $"\"{n.EventTitle}\" için katılım isteğini kabul edemedi.",
        "event_review" => $"\"{n.EventTitle}\" nasıldı? Değerlendir, anılarını paylaş.",
        "goal_completed" => $"\"{n.GoalTitle}\" hedefini tamamladın! Rozetin profilinde.",
        "teammate_request" => "seninle ekip arkadaşı olmak istiyor.",
        "teammate_accepted" => "ekip arkadaşlığı isteğini kabul etti.",
        "match_created" => "Kim olduğunu Eşleşmelerim'de gör.",
        "match_super_liked" => "seni süper beğendi! Destende ilk o görünüyor.",
        "welcome_requested" => $"\"{n.EventTitle}\" organizasyonuna ilk kez geliyor ve karşılanmak istiyor.",
        "welcome_matched" => $"\"{n.EventTitle}\" organizasyonunda seni karşılayacak. Buluşma notunu gör.",
        "welcome_released" => $"\"{n.EventTitle}\" için karşılamayı bıraktı; yeni bir karşılayıcı aranıyor.",
        "welcome_withdrawn" => $"\"{n.EventTitle}\" için karşılama isteğini geri çekti.",
        "league_result" => "geçen ayın liginde ilk üçe girdi! Sıralamayı ve derecesini grup sayfasında gör.",
        "welcome_thanked" => $"\"{n.EventTitle}\" organizasyonunda onu karşıladığın için teşekkür etti.",
        "event_series_limit" => $"\"{n.EventTitle}\" için sonraki tarih açılamadı: grubun bu ayki organizasyon hakkı doldu. Yeni ay başlayınca ya da paket yükselince açılır.",
        _ => "yeni bir bildirim gönderdi.",
    };

    /// <summary><c>27 Ekim 2026, 20:00</c> in Turkey time.</summary>
    internal static string DateTimeTr(DateTimeOffset at)
    {
        var t = TimeZoneInfo.ConvertTime(at, Turkey);
        return $"{t.Day} {Months[t.Month - 1]} {t.Year}, {t.Hour:00}:{t.Minute:00}";
    }
}
