using System.Globalization;
using Gway.SharedKernel.Localization;

namespace Gway.Modules.Notifications;

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
    string? GoalTitle,
    Guid? ConversationId = null,
    string? MessageText = null,
    bool MessagePhoto = false,
    string? ChatGroupName = null,
    Guid? CallId = null,
    string Locale = ServerText.Turkish);

/// <summary>
/// The app's notification sentences (<c>AppNotification.action</c> in Flutter), in the recipient's language
/// (<c>profiles.locale</c>; docs/ARCHITECTURE.md §11, Sunucu). Each sentence is written in Turkish with {0} for its
/// value; <see cref="ServerText"/> holds the other languages.
/// </summary>
internal static class PushTexts
{
    /// <summary>How long a call rings before it is missed (the live module's <c>CallService.RingFor</c>).</summary>
    private static readonly TimeSpan RingFor = TimeSpan.FromSeconds(30);

    /// <summary>The name the database gives a small table's chat (PushService).</summary>
    internal const string TableChatName = "Bu akşamın masası";

    /// <summary>The push for a notification; null for a chat message deleted before it went out.</summary>
    public static PushMessage? For(PendingPush n)
    {
        var data = new Dictionary<string, string>
        {
            ["type"] = n.Type,
            ["notification_id"] = n.Id.ToString(CultureInfo.InvariantCulture),
        };
        if (n.LiveId is { } live) data["live_id"] = live.ToString();
        if (n.ConversationId is { } chat) data["conversation_id"] = chat.ToString();
        if (n.CallId is { } call) data["call_id"] = call.ToString();
        var t = new Sentences(n.Locale);
        return n.Type switch
        {
            "message" => ForMessage(n, t, data),
            // Android: the app opens the phone's incoming call screen for 30 seconds; call_ended closes it early.
            "call_incoming" => new PushMessage(n.ActorUsername, t["seni sesli arıyor…"], data, FcmClient.CallsChannel, $"call-{n.CallId}",
                AppHandlesFor: RingFor),
            "call_ended" => new PushMessage(n.ActorUsername, t["aramayı bitirdi."], data, AppHandlesFor: RingFor, Silent: true),
            "call_missed" => new PushMessage(n.ActorUsername, t["seni aradı, açamadın."], data, FcmClient.MessagesChannel, $"call-{n.CallId}"),
            _ => new PushMessage(Lead(n, t), Action(n, t), data),
        };
    }

    /// <summary>Direct: the sender and the text. Group: the group, then "sender: text" (docs/ARCHITECTURE.md §3c, Mesaj bildirimi).</summary>
    private static PushMessage? ForMessage(PendingPush n, Sentences t, Dictionary<string, string> data)
    {
        var text = !string.IsNullOrWhiteSpace(n.MessageText) ? n.MessageText : n.MessagePhoto ? t["📷 Fotoğraf"] : null;
        if (text is null || n.ConversationId is not { } conversation) return null;
        // A chat keeps one notification on the phone: the newest message replaces the previous one.
        var tag = conversation.ToString();
        return n.ChatGroupName is { } group
            ? new PushMessage(group == TableChatName ? t[TableChatName] : group, $"{n.ActorUsername}: {text}", data, FcmClient.MessagesChannel, tag)
            : new PushMessage(n.ActorUsername, text, data, FcmClient.MessagesChannel, tag);
    }

    /// <summary>The group for group notices, nobody for a match (who it is needs a package), otherwise the person.</summary>
    private static string Lead(PendingPush n, Sentences t) => n.Type switch
    {
        "sanction_applied" or "appeal_decided" or "league_result" => n.GroupName ?? "",
        "match_created" => t["Yeni bir eşleşmen var!"],
        "event_series_limit" => t["Tekrarlayan organizasyon"],
        "call_permission_granted" or "call_permission_declined" or "call_permission_revoked" => t["Sesli görüşme"],
        "event_venue_revealed" => t["Sürpriz mekan açıklandı"],
        _ => n.ActorUsername,
    };

    private static string Action(PendingPush n, Sentences t) => n.Type switch
    {
        "like" => t["gönderini beğendi."],
        "comment" => t.Format("yorum yaptı: {0}", n.Comment),
        "reply" => t.Format("yorumuna yanıt verdi: {0}", n.Comment),
        "comment_like" => t.Format("yorumunu beğendi: {0}", n.Comment),
        "mention" => n.Comment is null ? t["bir gönderide senden bahsetti."] : t.Format("bir yorumda senden bahsetti: {0}", n.Comment),
        "follow" => t["seni takip etmeye başladı."],
        "follow_request" => t["seni takip etmek istiyor."],
        "follow_accepted" => t["takip isteğini kabul etti."],
        "live_scheduled" => n.LiveScheduledAt is { } at
            ? t.Format("{0} için canlı yayın planladı: {1}", ServerText.FormatDateTime(at, n.Locale), n.LiveTitle)
            : t.Format("canlı yayın planladı: {0}", n.LiveTitle),
        "live_started" => t.Format("canlı yayına başladı: {0}", n.LiveTitle),
        "event_promoted" => t.Format("\"{0}\" için yer açıldı, artık katılıyorsun.", n.EventTitle),
        "event_updated" => t.Format("\"{0}\" organizasyonunun zamanını ya da yerini değiştirdi.", n.EventTitle),
        "event_canceled" => t.Format("\"{0}\" organizasyonunu iptal etti.", n.EventTitle),
        "event_venue_revealed" => t.Format("\"{0}\": nereye gideceğini görmek için dokun.", n.EventTitle),
        "handshake" => t.Format("\"{0}\" organizasyonunda seninle el sıkıştı.", n.EventTitle),
        "event_reminder" => n.EventStartsAt is { } starts && starts - n.CreatedAt > TimeSpan.FromHours(1)
            ? t.Format("\"{0}\" yarın başlıyor. Geliyor musun? Teyit et.", n.EventTitle)
            : t.Format("\"{0}\" 1 saat içinde başlıyor.", n.EventTitle),
        "case_vote" => t.Format("{0} grubunda bir disiplin dosyası açtı; oyunu bekliyor.", n.GroupName),
        "sanction_applied" => n.SanctionType switch
        {
            "mute" => t["grubunda susturuldun. Ayrıntılar ve itiraz için dokun."],
            "kick" => t["grubundan çıkarıldın. Ayrıntılar ve itiraz için dokun."],
            "ban" => t["grubundan uzaklaştırıldın. Ayrıntılar ve itiraz için dokun."],
            _ => t["grubu sana uyarı verdi. Ayrıntılar ve itiraz için dokun."],
        },
        "appeal_submitted" => t.Format("{0} grubundaki yaptırıma itiraz etti.", n.GroupName),
        "appeal_decided" => t["grubu itirazını karara bağladı."],
        "event_approved" => t.Format("\"{0}\" için katılım isteğini onayladı.", n.EventTitle),
        "event_declined" => t.Format("\"{0}\" için katılım isteğini kabul edemedi.", n.EventTitle),
        "event_review" => t.Format("\"{0}\" nasıldı? Değerlendir, anılarını paylaş.", n.EventTitle),
        "goal_completed" => t.Format("\"{0}\" hedefini tamamladın! Rozetin profilinde.", n.GoalTitle),
        "teammate_request" => t["seninle ekip arkadaşı olmak istiyor."],
        "teammate_accepted" => t["ekip arkadaşlığı isteğini kabul etti."],
        "match_created" => t["Kim olduğunu Eşleşmelerim'de gör."],
        "match_super_liked" => t["seni süper beğendi! Destende ilk o görünüyor."],
        "chess_challenge" => t["seni satranç oynamaya davet etti."],
        "welcome_requested" => t.Format("\"{0}\" organizasyonuna ilk kez geliyor ve karşılanmak istiyor.", n.EventTitle),
        "welcome_matched" => t.Format("\"{0}\" organizasyonunda seni karşılayacak. Buluşma notunu gör.", n.EventTitle),
        "welcome_released" => t.Format("\"{0}\" için karşılamayı bıraktı; yeni bir karşılayıcı aranıyor.", n.EventTitle),
        "welcome_withdrawn" => t.Format("\"{0}\" için karşılama isteğini geri çekti.", n.EventTitle),
        "league_result" => t["geçen ayın liginde ilk üçe girdi! Sıralamayı ve derecesini grup sayfasında gör."],
        "welcome_thanked" => t.Format("\"{0}\" organizasyonunda onu karşıladığın için teşekkür etti.", n.EventTitle),
        "event_series_limit" => t.Format(
            "\"{0}\" için sonraki tarih açılamadı: grubun bu ayki organizasyon hakkı doldu. Yeni ay başlayınca ya da paket yükselince açılır.",
            n.EventTitle),
        "tonight_table_invite" => t["bu akşam küçük bir masa kurdu ve seni de çağırıyor."],
        "tonight_table_ready" => t["masaya katıldı; masa kuruldu. Yeri ve saati sohbette konuşun."],
        "call_permission_granted" => t["Sesli görüşme yetkin açıldı. Eşleştiğin kişileri sohbetten arayabilirsin."],
        "call_permission_declined" => t["Sesli görüşme talebin şimdilik onaylanmadı. Ayrıntı için dokun."],
        "call_permission_revoked" => t["Sesli görüşme yetkin kapatıldı. Ayrıntı için dokun."],
        _ => t["yeni bir bildirim gönderdi."],
    };

    /// <summary>The recipient's sentences: <c>t["..."]</c> for a fixed one, <c>t.Format("... {0}", value)</c> with a value.</summary>
    private readonly record struct Sentences(string Language)
    {
        public string this[string turkish] => ServerText.Translate(turkish, Language);

        public string Format(string turkishTemplate, params object?[] values) => ServerText.Format(Language, turkishTemplate, values);
    }
}
