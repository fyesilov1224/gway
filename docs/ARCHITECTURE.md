# GrupX — Mimari ve Kurallar

Bu doküman bağlayıcıdır. `CLAUDE.md` ile çelişirse bu dosya geçerlidir. Bir kural değişecekse önce bu dosya güncellenir, sonra kod yazılır.

---

## 1. Genel bakış

```
 Flutter (social_app, admin_panel)
   │  okuma + kullanıcının kendi verisine basit yazma
   ├──────────────────────────────► Supabase (Auth, Postgres+RLS, Storage, Realtime)
   │                                        ▲
   │  kural / para / yetki içeren yazma     │ service role
   └──────────────► C# API (GrupX.Api) ─────┘
                       │
                       ├──► LiveKit (yayın tokenı, sunucu tarafı moderasyon)
                       ├──► PayTR (yurt içi ödeme, hash doğrulamalı bildirim)
                       └──► iyzico (yurt dışı ödeme, imzalı webhook + sunucudan sorgu)
```

| Katman | Teknoloji |
|---|---|
| Mobil + Web | Flutter 3.41+, Dart pub workspace + Melos, Riverpod 3, go_router |
| Backend | C# .NET 10, ASP.NET Core Minimal API, modüler monolit |
| Veri | Supabase: Auth, Postgres + RLS, Storage, Realtime |
| Ses | LiveKit |
| Ödeme | PayTR (yurt içi, TRY), iyzico (yurt dışı, USD); ülke IP'den belirlenir |
| Push | FCM / APNs |

## 2. Veri akışı (altın kural)

1. **Okuma:** Flutter → Supabase. Erişimi RLS sınırlar.
2. **Kullanıcının yalnızca kendi verisine basit yazma:** Flutter → Supabase. Örnekler: kendi profili, beğeni, yorum. RLS `auth.uid()` ile sınırlar.
3. **Başkasını etkileyen ya da kural, para veya yetki içeren her yazma:** Flutter → C# API → Supabase. Örnekler: rol atama, ban, susturma, abonelik, yayın tokenı, limit kontrollü gruba katılma.
4. **Service role anahtarı yalnızca C# backend'dedir.** Flutter koduna, `--dart-define` değerlerine veya istemci yapılandırmasına asla girmez. Flutter yalnızca publishable (eski adıyla anon) anahtarı bilir.

İstemciden gelen hiçbir değer güvenilir değildir. C# her istekte JWT'yi doğrular, yetkiyi kontrol eder. Veritabanı aynı kuralı RLS, trigger ve `private.has_group_permission` ile ikinci kez uygular (§3b).

## 3. Modüller

`core, identity, profile, groups, billing, support, feed, notifications, events, moderation, live, messaging, matching, admin`

- Her modül Flutter'da `app/packages/features/<modül>` olarak, C#'ta `backend/src/Modules/GrupX.Modules.<Ad>` olarak **aynı isimle** yaşar.
- Her modül kendi tablolarının sahibidir. Bir tablonun sahibi migration'daki yorumla belirtilir (`-- owner: <modül>`).
- Modüller birbirinin tablosuna doğrudan yazmaz.
- Flutter'da feature paketleri birbirini import etmez. Ortak ihtiyaçlar `core` veya `design_system` paketindedir.
- C#'ta bir modül başka bir modülün yalnızca `GrupX.Modules.<Ad>.Contracts` projesine referans verebilir.
- Modül klasörü ancak o modülün ilk gerçek kodu yazıldığında oluşturulur. Boş modül iskeleti tutulmaz.

### Tablo sahipliği

| Tablo | Sahip modül | Faz |
|---|---|---|
| `public.audit_log` | core | 0 |
| `public.platform_staff` | admin | 0 |
| `public.categories` | core | 1 |
| `public.legal_documents` | identity | 1 |
| `public.consents` | identity | 1 |
| `public.account_status` | identity | 1 |
| `public.profiles` | profile | 1 |
| `public.profile_interests` | profile | 1 |
| Storage `avatars`, `covers` | profile | 1 |
| `public.group_roles` | groups | 2 |
| `public.group_permissions` | groups | 2 |
| `public.group_role_permissions` | groups | 2 |
| `public.groups` | groups | 2 |
| `public.group_members` | groups | 2 |
| `public.group_member_roles` | groups | 2 |
| `public.group_join_requests` | groups | 2 |
| `public.group_invitations` | groups | 2 |
| Storage `group-images` | groups | 2 |
| `public.plans` | billing | 3 |
| `public.plan_prices` | billing | 3 |
| `public.billing_orders` | billing | 3 |
| `public.group_subscriptions` | billing | 3 |
| `public.support_tickets` | support | 3.5 |
| `public.support_messages` | support | 3.5 |
| Storage `support-attachments` | support | 3.5 |
| `public.follows`, `public.follow_requests`, `public.blocks` | profile | 4 |
| `public.teammate_preferences`, `public.teammate_requests`, `public.teammates`, `public.teammate_request_log` | profile | 13 |
| `public.provinces` | core | 14 |
| `public.group_follows` | groups | 4 |
| `public.posts`, `public.post_media`, `public.post_hashtags` | feed | 4 |
| `public.post_likes`, `public.comments`, `public.comment_likes`, `public.saved_posts` | feed | 4 |
| `public.post_reactions` | feed | 15.6 |
| `public.stories`, `public.story_views`, `public.highlights`, `public.highlight_stories` | feed | 4 |
| Storage `media` | feed | 4 |
| `public.notifications` | notifications | 4 |
| `public.notification_preferences` | notifications | 9 |
| `public.push_devices` | notifications | 4 |
| `public.events`, `public.event_attendees`, `public.polls`, `public.poll_options`, `public.poll_votes` | events | 5 |
| `public.event_reviews` | events | 10 |
| `public.goals`, `public.goal_teams`, `public.goal_team_members`, `public.goal_claims`, `public.goal_completions` | events | 12 |
| Storage `event-images` | events | 5 |
| `public.live_broadcasts`, `public.live_kicks`, `public.live_comments`, `public.live_reminders` | live | 7 |
| `public.reports`, `public.moderation_cases`, `public.case_votes`, `public.sanctions`, `public.sanction_appeals` | moderation | 6 |
| `public.conversations`, `public.conversation_members`, `public.messages` | messaging | 15 |
| `public.match_profiles`, `public.match_photos`, `public.match_swipes`, `public.matches`, `public.matching_settings` | matching | 15.6 |
| Storage `match-photos` | matching | 15.6 |
| Storage `message-images` | messaging | 15 |
| `public.security_settings` | identity | 15.8 |
| `public.user_security` | identity | 15.8 |
| `public.phone_verifications` | identity | 15.8 |
| `public.phone_bans` | identity | 15.8 |
| `public.verified_sessions` | identity | 15.8 |
| `public.totp_factors` | identity | 15.8 |
| `public.sms_sends` | identity | 15.8 |
| `public.location_checks` | identity | 15.8 |
| `public.security_reviews` | identity | 15.8 |
| `public.passkeys` | identity | 15.8 |
| `public.webauthn_challenges` | identity | 15.8 |
| `public.birth_dates` | identity | 17a |

Her yeni tablo bu listeye eklenir. Okuma amaçlı SQL yardımcı fonksiyonları (`private.is_account_visible` gibi) başka modülün tablosunu okuyabilir; yazamaz.

## 3a. Kimlik ve Profil (Faz 1)

### Hesap yaşam döngüsü
- Kayıt: e-posta + şifre (**e-posta doğrulaması zorunlu**), Google, Apple. Şifre sıfırlama e-postayla yapılır.
- `auth.users` kaydı oluşunca trigger `account_status` satırını `active` olarak açar.
- Giriş sonrası zorunlu sıra: **güvenlik doğrulaması (konum, telefon, ikinci adım; §3h) → KVKK onayları → onboarding → uygulama.** Router bu sırayı zorlar; güvenlik adımını ayrıca sunucu zorlar.
- Durumlar (`account_status.status`):
  - `active`: normal.
  - `suspended`: platform ekibi askıya aldı. Supabase Auth'ta da ban uygulanır (giriş ve token yenileme kapanır). `suspended_until` geçince hesap kendiliğinden aktif sayılır. Profil başkalarına gizlenir, kullanıcı kendi verisine yazamaz.
  - `pending_deletion`: kullanıcı silme istedi. Profil başkalarına **hemen gizlenir**. Kullanıcı giriş yapabilir ve yalnızca "silmeyi geri al" ekranını görür. 30 gün sonra backend kalıcı olarak siler.
- Kalıcı silme (`AccountPurgeService`, saatlik): storage dosyaları (`avatars/<uid>/`, `covers/<uid>/`) ve `auth.users` kaydı silinir. Bağlı satırlar `on delete cascade` ile gider. `audit_log` kaydı (`account.purged`) kalır, yalnızca uuid içerir.

### KVKK
- Hukuki metinler `legal_documents` tablosunda sürümlüdür (`kind`, `version`). Zorunlu türler: `terms` (kullanım koşulları), `privacy_notice` (aydınlatma metni), `explicit_consent` (açık rıza: verilerin yurt dışındaki sunucularda işlenmesi), `community_rules` (Topluluk Kuralları, Yaptırımlar ve Yasal İşlemler Sözleşmesi; 2026-10-28, §3e Yasa dışı faaliyet).
- Kullanıcının her zorunlu türün **en güncel sürümünü** onaylamış olması gerekir. Yeni sürüm yayınlanınca onay ekranı yeniden gösterilir. Yeni bir zorunlu tür eklendiğinde mevcut kullanıcılar da bir sonraki açılışta onaylar.
- **Okumadan onay yok** (kullanıcı kararı, 2026-10-28): onay ekranında bir metnin onay kutusu, metin açılıp **sonuna kadar kaydırılmadan** işaretlenemez. Bu kural arayüzdedir; sunucu onayın sürümünü ve zamanını saklar.
- `consents` yalnızca ekleme yapılan bir kayıttır. Kullanıcı yalnızca kendi adına ekler (kendi verisine basit yazma), değiştiremez ve silemez.
- Metinler taslaktır; yayından önce hukuki incelemeden geçmelidir.
- **Yönetim (Faz 15.7'de admin paneline eklendi):** platform yöneticisi (`admin`) her türün metinlerini panelden yönetir (`/admin/legal`). Her tür için yeni **sürüm** yayınlar (başlık, gövde, yayın zamanı); yayın zamanı ileri tarihli olabilir (o zamana kadar taslak, kimseye görünmez). `audience` türden türetilir (`distance_sales → purchase`, diğerleri `signup`). Yazmalar C# API'den geçer; her işlem `audit_log`'a yazılır (`legal.published`, `legal.updated`, `legal.deleted`).
- **Değişmezlik:** bir sürüme **en az bir onay (`consents`) bağlandıysa** o sürümün başlığı ve gövdesi artık değiştirilemez, silinemez (hem FK hem `legal_documents_guard` trigger ile). Kullanıcıların onayladığı metin kayıt altında kalır; metni güncellemek için yeni sürüm açılır. Henüz kimsenin onaylamadığı bir sürüm (taslak ya da yeni yayın) serbestçe düzenlenip silinebilir.

### Yaş sınırı: 18+ (Faz 17a, kullanıcı kararı 2026-10-27)
- GrupX yalnızca 18 yaş ve üstüne açıktır (eşleşmede sevgili bulma var; Play hedef kitlesi 18+).
- Giriş sonrası sıra: güvenlik → KVKK → **doğum tarihi** → onboarding → uygulama. Doğum tarihi olmayan mevcut hesaplar da bu adımı görür.
- `birth_dates` (identity): kullanıcı başına bir satır.
  - Kullanıcı kendi tarihini bir kez ekler ve okur (kendi verisine basit yazma).
  - Değiştiremez, silemez; düzeltme destek ekibinden yapılır.
  - Trigger, 18 yaşından küçükse (Türkiye saatine göre bugün) ya da tarih 1900'den önceyse reddeder.
- Doğum tarihi başkalarına gösterilmez. Eşleşme profilindeki doğum tarihi ayrı tutulur (§3g).

### Profil
- `profiles` satırı onboarding sonunda kullanıcı tarafından oluşturulur (Flutter → Supabase, RLS `id = auth.uid()`).
- Kullanıcı adı: zorunlu, benzersiz, 3–30 karakter, `a-z 0-9 _ .`, nokta ile başlayıp bitemez, `..` içeremez, ayrılmış adlar (`admin`, `grupx`, `destek`...) kullanılamaz. İlk seçimden sonra **30 günde bir** değiştirilebilir. Kuralı trigger uygular, `username_changed_at` değerini trigger yazar.
- Uygunluk kontrolü: `public.is_username_available(text)` RPC'si. Gizli hesapların adları da dolu sayılır.
- İlgi alanları: `profile_interests` (en fazla 10), `categories` tablosundan seçilir. `categories` Faz 2'de gruplar için de kullanılır.
- Görseller: `avatars` ve `covers` bucket'ları herkese açık okunur. Kullanıcı yalnızca `<uid>/` klasörüne yazar. En fazla 5 MB; JPEG, PNG veya WebP.
- Görünürlük: Bir profil, hesap `active` (ya da süresi dolmuş `suspended`) ise herkese görünür. Sahibi kendi profilini her zaman görür, platform ekibi hepsini görür.

### C# uç noktaları (Faz 1)
| Uç nokta | Açıklama |
|---|---|
| `GET /account` | Kendi hesap durumu |
| `POST /account/deletion` | Silme isteği (30 gün), audit log |
| `DELETE /account/deletion` | Silme isteğini geri alma, audit log |
| `GET /admin/users?q=&status=&page=` | Kullanıcı arama (e-posta dahil), `status`: `active` / `suspended` / `pending_deletion`. Rol: `admin`, `moderator`, `support` |
| `GET /admin/users/stats` | Toplam, aktif, askıda ve silinecek kullanıcı sayıları. Süresi dolmuş askı aktif sayılır. |
| `GET /admin/users/{id}` | Kullanıcı detayı |
| `POST /admin/users/{id}/suspension` | Askıya alma (`reason`, isteğe bağlı `until`). Rol: `admin`, `moderator`. Platform ekibi üyesi askıya alınamaz. |
| `DELETE /admin/users/{id}/suspension` | Askıyı kaldırma. Rol: `admin`, `moderator` |

Admin kullanıcı listesi C#'tan gelir, çünkü e-posta `auth` şemasındadır ve istemciye açılmaz.

### Backend altyapısı
- Veritabanına `Npgsql` ile `ConnectionStrings:Database` üzerinden bağlanılır. Bu bağlantı RLS'i aşar; yetki kontrolü C#'ta yapılır. Bir değişiklik ve onun audit kaydı aynı transaction'da yazılır.
- Supabase Auth ve Storage yönetim çağrıları `Supabase:ServiceRoleKey` ile yapılır (`ISupabaseAdmin`).

## 3b. Gruplar, Roller ve Üyelik (Faz 2)

### Grup
- Her grubun **tek kategorisi** vardır (`categories`, profil ilgi alanlarıyla ortak).
- Grup adresi (`handle`): benzersiz, kullanıcı adıyla aynı biçim kuralları (3–30 karakter, `a-z 0-9 _ .`, nokta ile başlayıp bitemez, `..` içeremez, ayrılmış adlar kullanılamaz). Oluşturulduktan sonra değişmez. Sayfa adresi `/g/<handle>`.
- Profil alanları: ad (3–60), tanıtım (en fazla 1000), kurallar (en fazla 2000), bağlantılar (en fazla 5; etiket 1–40, `http(s)` adresi en fazla 300), logo, kapak.
- Görseller `group-images` bucket'ında `<group_id>/` klasöründedir: herkese açık okunur, yalnızca `group.edit` yetkisi olan yazar. En fazla 5 MB; JPEG, PNG veya WebP. İstemci görseli yükler, yolu C# API'ye bildirir; API yolun grubun klasöründe olduğunu doğrular.
- **Görünürlük:** Tüm aktif grupların sayfası, üye listesi ve yönetim ekibi herkese açıktır (gizli grup yok). Katılım tipi yalnızca katılma yolunu belirler.
- **Durum** (`groups.status`): `active` veya `suspended` (platform ekibi askıya aldı, süresiz). Askıdaki grup yalnızca üyelerine ve platform ekibine görünür; hiçbir yetki çalışmaz, katılım, istek ve davet kapanır, yalnızca gruptan ayrılmak mümkündür.
- **Silme:** Yalnızca sahibi siler. Kalıcıdır: üyelikler, roller, istekler ve davetler `on delete cascade` ile, görseller backend tarafından silinir. `audit_log` kaydı (`group.deleted`) kalır.
- Grup sahibi olan kullanıcı **hesap silme isteğinde bulunamaz**; önce sahipliği devretmeli ya da grubu silmelidir.

### Katılım tipleri (`join_policy`)
| Tip | Akış |
|---|---|
| `open` (serbest) | Kullanıcı doğrudan üye olur. |
| `request` (istekle) | Kullanıcı istek gönderir, geri alabilir. `members.approve` yetkisi olan onaylar ya da reddeder. |
| `invite` (davetle) | `members.invite` yetkisi olan, kullanıcıyı **kullanıcı adıyla uygulama içinde** davet eder. Davet edilen kabul eder ya da reddeder; davet eden geri alabilir. Davet bağlantısı yoktur. |

- Davet her katılım tipinde gönderilebilir; bekleyen davet her zaman doğrudan katılım hakkı verir.
- Üye olunca o gruba ait bekleyen istek ve davet silinir.
- Katılmak için hesabın aktif ve profilin (onboarding) tamamlanmış olması gerekir.
- Grup sahibi gruptan ayrılamaz. Diğer üyeler istediği zaman ayrılır; rolleri de silinir. Üyeyi gruptan çıkarma ve banlama bir yaptırımdır; yalnızca disiplin dosyasının kararıyla olur (§3e). Banlı kişi ban süresince katılamaz, istek gönderemez, davet alamaz.

### Roller ve rütbe
| Rol (`group_roles.slug`) | Ad | Rütbe | Nerede tutulur |
|---|---|---|---|
| `owner` | Grup Sahibi | 100 | `groups.owner_id`. Grubu oluşturan; sahiplik devriyle değişir. |
| `admin` | Yönetici | 80 | `group_member_roles` |
| `discipline` | Disiplin Kurulu | 60 | `group_member_roles` |
| `moderator` | Moderatör | 50 | `group_member_roles` |
| `member` | Üye | 10 | `group_members` satırı |

- Bir üyenin birden fazla rolü olabilir. Etkin rütbesi rollerinin en yükseğidir.
- **Rol atamayı ve almayı yalnızca grup sahibi yapar** (`roles.assign`). Atanabilen roller: `admin`, `discipline`, `moderator`. Rol yalnızca üyeye verilir.
- **Rütbe kuralı:** İşlemi yapanın rütbesi hem hedef üyenin mevcut rütbesinden hem de verilen ya da alınan rolün rütbesinden **kesinlikle büyük** olmalıdır. Bu yüzden kimse kendine rol veremez. Grup sahibi banlanamaz ve gruptan çıkarılamaz.
- **Kurul karar eşiği** (`case_threshold`: `majority` / `two_thirds` / `unanimous`): yalnızca sahip değiştirir (§3e).
- **Sahiplik devri** (`group.transfer`): Sahip, sahipliği aktif hesaplı bir üyeye devreder. Eski sahip normal üye olarak kalır; yeni sahip isterse ona rol verir.

### Yetki kataloğu
Yetkiler `group_permissions`, rol–yetki eşlemesi `group_role_permissions` tablosundadır. **Grup sahibi her yetkiye sahiptir** (eşleme gerekmez). Yeni yetkiler ait oldukları fazın migration'ında kataloğa eklenir.

| Yetki | Açıklama | Roller (sahip dışında) |
|---|---|---|
| `group.edit` | Grup profilini, görselleri, kategoriyi ve katılım tipini düzenleme | admin |
| `group.delete` | Grubu silme | — |
| `group.transfer` | Sahipliği devretme | — |
| `roles.assign` | Rol atama ve alma | — |
| `members.approve` | Katılım isteklerini onaylama ve reddetme | admin |
| `members.invite` | Davet gönderme ve geri alma | admin |
| `billing.manage` | Paket satın alma ve abonelik bilgilerini görme (Faz 3) | — |
| `posts.publish` | Grup adına gönderi paylaşma, düzenleme, silme ve grup gönderilerindeki yorumları silme (Faz 4) | admin |
| `events.manage` | Organizasyon ve anket yönetimi (Faz 5, §3d) | admin |
| `live.start` | Canlı yayın başlatma ve planlama (Faz 7) | admin |
| `live.moderate` | Canlı yayın moderasyonu (Faz 7, §8) | admin, discipline, moderator |
| `reports.review` | Şikayet ön incelemesi, disiplin dosyası açma (Faz 6, §3e) | admin, discipline, moderator |
| `members.mute` | Acil susturma (Faz 6, §3e) | admin, discipline, moderator |

Kurul oylaması bir yetki değil, Disiplin Kurulu rolüdür (§3e).

### İki katmanlı yetki kontrolü
- **C#:** Her grup işleminde işlemi yapanın rolleri, rütbesi ve yetkileri veritabanındaki katalogdan okunur ve kontrol edilir. Hata `Result` olarak döner.
- **SQL:** `private.has_group_permission(group_id, permission)`, `auth.uid()` için yetkiyi döner (hesap aktif, grup aktif, kullanıcı üye). RLS ve storage politikaları bunu kullanır.
- Backend, grup tablolarına yazdığı her transaction'da işlemi yapanı `request.jwt.claims` ayarıyla (`sub`) bildirir. Trigger'lar aynı kuralları `auth.uid()` üzerinden **ikinci kez** uygular: katılım yolu, rol atama yetkisi ve rütbe kuralı, sahiplik devri, sahibin ayrılamaması, istek ve davet yetkileri. İşlemi yapan bilinmiyorsa yazma reddedilir. Üst satır (grup ya da profil) silinirken oluşan cascade silmeler serbesttir.
- İstemci rollerinin (`anon`, `authenticated`) grup tablolarına yazma yetkisi yoktur; tüm yazmalar C# API'den geçer. İstemci okumaları RLS ile sınırlanır. `public.my_group_permissions(group_id)` RPC'si arayüzde hangi aksiyonların gösterileceğini belirler.

### Audit log
`group.created`, `group.updated`, `group.deleted`, `group.ownership_transferred`, `group.role_assigned`, `group.role_removed`, `group.join_approved`, `group.join_rejected`, `group.invitation_sent`, `group.invitation_revoked`, `group.suspended`, `group.unsuspended`. Kayıtların `group_id` alanı doludur. Serbest katılma, istek gönderme ve geri alma, daveti kabul ya da reddetme ve ayrılma kullanıcının kendi işlemidir; audit log'a yazılmaz.

### C# uç noktaları (Faz 2)
| Uç nokta | Açıklama |
|---|---|
| `POST /groups` | Grup oluşturma (`handle`, `name`, `categorySlug`, `joinPolicy`, `about`, `province?`). Oluşturan sahip ve üye olur. |
| `PATCH /groups/{id}` | Profil düzenleme (`group.edit`): ad, kategori, katılım tipi, tanıtım, kurallar, bağlantılar, logo ve kapak yolu, il (`province`; 0 kaldırır). Yalnızca gönderilen alanlar değişir. |
| `DELETE /groups/{id}` | Grubu silme (`group.delete`) |
| `POST /groups/{id}/ownership` | Sahiplik devri (`userId`) |
| `POST /groups/{id}/join` | Katılma: serbest gruba ya da bekleyen davetle üye olur, istekli grupta istek açar. Yanıt: `member` / `requested` |
| `DELETE /groups/{id}/join-request` | Kendi isteğini geri alma |
| `DELETE /groups/{id}/membership` | Gruptan ayrılma (sahip hariç) |
| `DELETE /groups/{id}/invitation` | Kendine gelen daveti reddetme |
| `POST /groups/{id}/join-requests/{userId}/approval` | İsteği onaylama (`members.approve`) |
| `DELETE /groups/{id}/join-requests/{userId}` | İsteği reddetme (`members.approve`) |
| `POST /groups/{id}/invitations` | Kullanıcı adıyla davet (`username`, `members.invite`) |
| `DELETE /groups/{id}/invitations/{userId}` | Daveti geri alma (`members.invite`) |
| `PUT /groups/{id}/members/{userId}/roles/{role}` | Rol atama (`roles.assign`, rütbe kuralı) |
| `DELETE /groups/{id}/members/{userId}/roles/{role}` | Rol alma (`roles.assign`, rütbe kuralı) |
| `PUT /groups/{id}/case-threshold` | Kurul karar eşiği (`threshold`: `majority` / `two_thirds` / `unanimous`; `roles.assign`, Faz 6 §3e) |
| `GET /admin/groups?q=&status=&page=` | Grup arama (ad, adres), `status`: `active` / `suspended`. Rol: `admin`, `moderator`, `support` |
| `GET /admin/groups/stats` | Toplam, aktif ve askıdaki grup sayıları |
| `GET /admin/groups/{id}` | Grup detayı: sahip, yönetim ekibi, sayılar, işlem geçmişi |
| `POST /admin/groups/{id}/suspension` | Grubu askıya alma (`reason`). Rol: `admin`, `moderator` |
| `DELETE /admin/groups/{id}/suspension` | Askıyı kaldırma. Rol: `admin`, `moderator` |

## 3c. Akış, Takip ve Bildirimler (Faz 4)

Ürün kararları (2026-10-19):
- **Takip:** Instagram modeli; açık/gizli hesap, istek, kabul/ret, engelleme, takipçi çıkarma. Karşılıklı takip "Arkadaş" olarak görünür.
- **Video:** Supabase Storage'da olduğu gibi saklanır; en fazla 60 sn, 50 MB, MP4/MOV. Kapak görseli cihazda üretilir.
- **Kapsam:**
  - Çoklu medya (10'a kadar), kaydetme, #etiket ve @bahsetme, yorum yanıtları ve yorum beğenisi
  - Hikayeler (24 saat), görenler listesi, arşiv ve öne çıkanlar
  - Keşfet
  - Uygulama içi bildirimler
- **Grup gönderileri:** Grup sayfasında yayınlanır, grup takip edilebilir.
- **Bu fazda yok:** Mesajlaşma (Faz 8), push bildirimi (Firebase hesabı gelince), canlı yayın (Faz 7), şikayet akışı (Faz 6), filtre ve düzenleme araçları, fotoğrafta kişi etiketleme, konum.

### Modüller ve tablolar
| Modül | Tablolar |
|---|---|
| profile | `profiles.is_private`, `follows`, `follow_requests`, `blocks` |
| groups | `group_follows` |
| feed | `posts`, `post_media`, `post_hashtags`, `post_likes`, `post_reactions`, `comments`, `comment_likes`, `saved_posts`, `stories`, `story_views`, `highlights`, `highlight_stories`, Storage `media` |
| notifications | `notifications` (kayıtları diğer modüllerin tablolarındaki trigger'lar oluşturur), `push_devices` |

C#'ta `GrupX.Modules.Profile` (takip ve engelleme) ve `GrupX.Modules.Feed` (gönderi oluşturma, düzenleme, silme; admin kaldırma) modülleri eklenir. `GrupX.Modules.Notifications` yalnızca push gönderimini yapar (§3c, Push).

### Görünürlük kuralı (tek yerde)
`private.can_view_user_content(author)` bir kullanıcının içeriğinin (gönderi, hikaye, takipçi listeleri) görülüp görülemeyeceğini söyler:
- Kişi kendi içeriğini her zaman görür.
- Diğer durumlarda içerik görünür, eğer:
  - yazarın profili görünürse (hesap aktif),
  - iki taraf arasında hiçbir yönde engel yoksa,
  - ve hesap herkese açıksa ya da izleyen yazarı takip ediyorsa.
- Platform ekibi her şeyi görür.
- **Grup gönderileri** grup görünürse herkese görünür.
- **Admin'in kaldırdığı içerik** (`removed_at`) yalnızca platform ekibine görünür.
- Engelleme profili de gizler: engellenen kişi, engelleyenin profilini, içeriğini ve yorumlarını göremez. Engelleyen de engellediğinin içeriğini akışında görmez.

### Takip (profile)
| İşlem | Kural |
|---|---|
| Takip et | Hesap açıksa anında `follows`. Gizliyse `follow_requests` oluşur. Engel varsa yapılamaz. |
| Takibi bırak / isteği geri al | Takip eden kişi yapar. |
| İsteği kabul et | İstenen kişi kabul eder; istek takibe dönüşür. |
| İsteği reddet | İstenen kişi reddeder; istek silinir, istekte bulunana bildirilmez. |
| Takipçiyi çıkar | Takip edilen kişi yapar. |
| Engelle | İki yöndeki takip ve istekler silinir; birbirlerinin içeriğini, yorumlarını ve beğenilerini görmezler; takip edemezler, bahsedemezler, yorum yapamazlar. |
| Engeli kaldır | Yalnızca engelleyen yapar; takip geri gelmez. |
| Gizli → açık | Bekleyen istekler kendiliğinden kabul edilir. |

- Takip yazmaları başkasını etkilediği için C# API'den geçer (`/users/{id}/follow`, `/users/{id}/block`, `/me/follow-requests/...`, `/me/followers/{id}`). Trigger'lar aynı kuralları `auth.uid()` ile ikinci kez uygular. Takip için kullanıcı başına günde en fazla 200 istek kabul edilir.
- `profiles.is_private` kullanıcının kendi profiline basit yazmadır (Flutter → Supabase).
- **Arkadaş** = karşılıklı takip; hesaplanır, saklanmaz.
- `public.profile_social(user_id)`: gönderi, takipçi ve takip sayıları ile ilişki bilgisi:
  - ben takip ediyor muyum, istek gönderdim mi, o beni takip ediyor mu,
  - ben engelledim mi, gizli mi, içeriği görebilir miyim.
- Takipçi ve takip listeleri `can_view_user_content` ile korunur. Kişi bekleyen isteklerini ve engellediklerini yalnızca kendisi görür.
- **Grup takibi** (`group_follows`): kullanıcının kendi basit yazmasıdır (Flutter → Supabase, RLS). Grup görünür olmalıdır. Üye olunan grupların gönderileri takip edilmese de akışa düşer.

### Ekip arkadaşı (profile, Faz 13)
Ürün kararları (2026-10-21): önerilerde yalnızca "Ekip arıyorum"u açanlar görünür. İsteyen ilini seçer; il yalnızca eşleştirmede kullanılır, profilde gösterilmez. Kabul edilen istek ayrı bir "Ekip arkadaşları" ilişkisi kurar; Faz 15'te mesajlaşma önce ekip arkadaşları arasında açılır.

- **Tercihler** (`teammate_preferences`, kişinin kendi basit yazması, RLS):
  - "Ekip arıyorum" (`looking`).
  - Aktiviteler: ekip arkadaşı aranan kategoriler (`activities`, en fazla 8, `categories`'ten; 2026-10-27).
  - Seviye: `beginner` / `intermediate` / `advanced`.
  - Hedefler (`goals`): `fun`, `fitness`, `competition`, `learning`, `mentoring`, `social`.
  - Sıklık (`frequency`): `monthly`, `weekly`, `few_weekly`, `daily`.
  - Uygun zamanlar: hafta içi ve hafta sonu × sabah, öğle, akşam (`weekday_morning`, `weekday_noon`, `weekday_evening`, `weekend_morning`, `weekend_afternoon`, `weekend_evening`).
  - Ekip büyüklüğü (`group_sizes`): `pair`, `small`, `large`.
  - Aracı var (`has_vehicle`), kendi ekipmanı var (`has_equipment`).
  - İsteğe bağlı il (plaka kodu 1–81).
  - Kısa hedef notu (en fazla 140 karakter).

  Ekran bölümlere ayrılmış kartlardan oluşur; üstte görünürlük kartı ve tamamlanma çubuğu (8 bölüm), altta sabit kaydet çubuğu bulunur.

  İlgi alanları profildeki `profile_interests`'tir. Tercihleri yalnızca kişinin kendisi okur. Profilde yalnızca "Ekip arıyor · seviye" görünür; il gösterilmez.
- **Öneriler** (`public.teammate_suggestions`): adaylar "Ekip arıyorum"u açık, hesabı aktif ve gizli olmayan kişilerdir. Engel, mevcut ekip arkadaşlığı ve bekleyen istek bulunanlar elenir. Puan basit ve açıklanabilirdir; her öneri nedenlerini döner:

  | Neden | Puan |
  |---|---|
  | Her ortak aktivite | 3 |
  | Her ortak ilgi alanı | 3 |
  | Aynı il (ikisi de seçtiyse) | 3 |
  | Her ortak grup | 2 |
  | Aynı seviye | 2 |
  | Her ortak uygun zaman | 1 |
  | Her ortak hedef | 1 |
  | Aynı sıklık | 1 |

  Öneri kartında ayrıca "Aracı var" ve "Kendi ekipmanı var" bilgisi gösterilir (puana katılmaz).

  En az 3 puanı olanlar, puan sırasıyla ve en fazla 30 kişi listelenir. Yapay zekâ ya da gizli sinyal kullanılmaz; konum, mesaj ve gezinme verisi okunmaz.
- **İstek** (`teammate_requests`, C# API): mesaj en fazla 200 karakterdir. Karşı taraf "Ekip arıyorum"u açmış olmalıdır. Engel varsa istek gönderilemez. Karşı taraf kabul eder ya da reddeder; gönderen geri çeker. Karşı taraf zaten istek göndermişse, ona istek atmak o isteği kabul eder. Kabul edilince `teammates` kaydı oluşur ve iki taraf da istediği zaman ekip arkadaşlığını bitirir.
- **Sınırlar** (`teammate_request_log`, yalnızca trigger yazar, kimse okuyamaz): gönderilen her istek 24 saat kayıtlı kalır. Bu sayede geri çekilen istekler de sayılır:
  - Bir kişi 24 saatte en fazla 20 istek gönderir.
  - Aynı kişiye 24 saatte en fazla bir istek gönderilir. Reddedilen ya da geri çekilen istek aynı gün yinelenemez.
- **Engelleme** iki yöndeki istekleri ve ekip arkadaşlığını siler. Kötüye kullanım için profildeki "Şikayet et" (Faz 6) kullanılır.
- **Bildirimler:** `teammate_request` (alana), `teammate_accepted` (gönderene). İstek geri çekilir ya da reddedilirse bildirimi de silinir. Bir çift için tek "kabul etti" bildirimi tutulur.

### Gönderi (feed)
- **Yazar:** kullanıcı (kendi profili) ya da grup (`group_id`). Grup adına yalnızca `posts.publish` yetkisi olan yayınlar; bu yetki sahip ve Yönetici'dedir. Grup gönderisinde yazan yönetici kayıtlıdır, gönderi grup adıyla gösterilir.
- **İçerik:**
  - Açıklama (en fazla 2.200 karakter, 30 etiket).
  - 1–10 medya: fotoğraf (JPEG, PNG, WebP; 10 MB) ya da video (MP4, MOV; 50 MB, en fazla 60 sn; kapak görseli zorunlu değil).
  - **Fotoğraflar cihazda hazırlanır:** kullanıcının seçtiği orana (Orijinal 4:5–1.91:1 aralığında, 1:1, 4:5, 1.91:1) ve kadraja göre kırpılır, en uzun kenarı 1440 px, JPEG %85 olarak yüklenir. Karuseldeki fotoğraflar aynı oranı kullanır. Orijinal dosya yüklenmez. EXIF yönü uygulanır, konum dahil diğer EXIF verisi atılır.
  - **Küçük kopya** (`post_media.thumb_path`): her fotoğraf için en uzun kenarı 480 px JPEG; ızgara, keşfet ve bildirim önizlemeleri bunu kullanır. Sunucu görsel dönüştürmez (Supabase görsel dönüştürme bulutta ücretli).
  - Medyanın (kırpılmış) genişlik ve yüksekliği saklanır; akış ilk medyanın oranını 4:5 ile 1.91:1 arasında sınırlayarak gösterir.
  - Video cihazda dönüştürülmez. Süresi cihazda kontrol edilir; sunucu boyut ve türü kontrol eder.
  - Ölçülerin hepsi `GxMedia` tokenlarındadır (`docs/DESIGN.md` §7).
- **Seçenekler:** yorumları kapat, beğeni sayısını gizle (sayıyı yalnızca yazar görür).
- **Oluşturma, düzenleme, silme C# API'den geçer** (`POST /posts`, `PATCH /posts/{id}`, `DELETE /posts/{id}`):
  - Medya (ve küçük kopyası) önce `media` bucket'ına `<uid>/<uuid>.<uzantı>` olarak yüklenir. API, her dosyanın yükleyene ait olduğunu, depoda bulunduğunu ve türünün doğru olduğunu doğrular (küçük kopya yalnızca fotoğrafta ve görsel olmalı).
  - Silmede medya da silinir. Düzenleme yalnızca açıklama ve seçenekler içindir.
  - Kullanıcı başına günde en fazla 25 gönderi.
- **Etiketler:** Açıklamadaki `#etiket`'ler trigger ile `post_hashtags`'e çıkarılır (küçük harf, harf/rakam/alt çizgi, 1–50 karakter).
- **Bahsetmeler:** Açıklamadaki ve yorumlardaki `@kullanıcıadı` görünür bir hesabı gösteriyorsa ve engel yoksa bildirim oluşturur.
- **Beğeni, yorum, yorum beğenisi ve kaydetme** kullanıcının kendi basit yazmasıdır (Flutter → Supabase, RLS):
  - Gönderiyi görebilmek gerekir. Yorum için yorumların açık olması ve engel olmaması gerekir.
  - **Kişisel fotoğraf ve videoya yorum (kullanıcı kararı, 2026-10-27):** yalnızca paylaşımın sahibi, sahibiyle eşleşenler (§3g) ve ekip arkadaşları yazar (`private.can_comment_as`, trigger `comment_not_allowed`). Diğerleri yalnızca emoji tepkisi bırakır. Grup paylaşımlarına görebilen herkes (üyeler, takipçiler) eskisi gibi yorum yazar. Mevcut yorumlar silinmez. Kart, `can_comment` ile yazma kutusunu gösterir ya da gizler.
  - **Emoji tepkisi** (`post_reactions`): gönderiyi gören herkes 😍 😂 😮 👏 🔥 🙏 emojilerinden birini bırakır; kişi başına bir tepki, değiştirilebilir ve geri alınabilir. Kart her emojinin sayısını (`reactions`) ve kişinin kendi tepkisini (`my_reaction`) taşır. Tepki bildirim üretmez.
  - Yorum en fazla 2.200 karakterdir. Yanıtlar tek seviyedir (yanıta yanıt, ana yoruma bağlanır).
  - Yorumu yazarı ya da gönderinin sahibi (grup gönderisinde `posts.publish` yetkilisi) siler.
  - Sınırlar: saatte 120 yorum ve 600 beğeni.
- **Sayaçlar** (`like_count`, `comment_count`, yorumlarda `like_count`) trigger ile tutulur.
- **Kaydedilenleri** yalnızca kişinin kendisi görür.

### Hikaye (feed)
- Fotoğraf ya da video (en fazla 60 sn), 24 saat görünür (`expires_at`). Yalnızca kullanıcılar paylaşır. Fotoğraf cihazda 9:16 kadraja kırpılır (en fazla 1080×1920, JPEG %85).
- Kullanıcının kendi basit yazmasıdır (RLS). Sınır: günde 50 hikaye.
- **Görünürlük:** `can_view_user_content` + süresi dolmamış olmak; ya da bir öne çıkanda bulunmak.
- **Görenler** (`story_views`): izleyen kendi kaydını ekler; listeyi yalnızca hikayenin sahibi görür.
- **Arşiv ve öne çıkanlar:**
  - Süresi dolan hikaye silinmez; sahibinin arşivinde kalır.
  - Öne çıkanlar (`highlights`, başlık 1–30, en fazla 100 hikaye) profilde görünür ve hikayelerin görünürlüğüne uyar.
  - Sahibi hikayeyi silerse medyası da silinir.
- **Hikaye çubuğu:** `public.story_tray()` takip edilenlerin ve kendinin aktif hikayelerini döner; her kişi için hepsinin görülüp görülmediği bilgisi de gelir.

### Akış ve keşfet
- **Ana akış** (`public.home_feed`): kendi gönderileri, takip edilen kullanıcılarınki ve takip edilen ya da üye olunan grupların gönderileri. En yeniden eskiye, `(created_at, id)` imleciyle sayfalanır.
- **Keşfet** (`public.explore_posts`):
  - Son 14 günün açık hesap ve grup gönderilerinden, takip edilmeyenler.
  - Etkileşim puanına göre sıralanır: beğeni + 2 × yorum, yaşa göre azalır.
- **Diğer RPC'ler:**
  - Etiket sayfası: `public.hashtag_posts`
  - Etiket arama: `public.search_hashtags`
  - Kullanıcı arama: `public.search_profiles` (kullanıcı adı ve görünen ad; engellenenler hariç)
  - Önerilen hesaplar: `public.suggested_profiles` (takip ettiklerinin takip ettikleri, yoksa popüler açık hesaplar)
- **Paylaşım:** Gönderi bağlantısı `/#/p/<id>`; bağlantıyı açan kişi gönderiyi görünürlük kuralına göre görür.

### Bildirimler (notifications)
- **Türler:** `like`, `comment`, `reply`, `comment_like`, `mention`, `follow`, `follow_request`, `follow_accepted`, `event_promoted`, `event_updated`, `event_canceled`, `event_reminder` (Faz 5, §3d), `live_scheduled`, `live_started` (Faz 7, §8), `case_vote`, `sanction_applied`, `appeal_submitted`, `appeal_decided` (Faz 6, §3e).
- **Oluşturma:** Bildirimleri ilgili tablolardaki trigger'lar oluşturur. Kişi kendi işlemi için bildirim almaz; engel varsa bildirim oluşmaz.
- **Silme:** Beğeni geri alınınca, yorum silinince ya da takip bırakılınca ilgili bildirim de silinir.
- **Erişim:** Alıcı okur, okundu işaretler ve siler; başka hiçbir rol yazamaz.
- **Arayüz:** Ekranda bildirimler Bugün / Bu hafta / Daha önce diye gruplanır. Bekleyen takip istekleri en üstte toplanır. Okunmamış sayısı gezinmede görünür.
- **Push** (FCM; Firebase projesi `grupx-08706`):
  - **Cihaz kaydı** (`push_devices`: FCM token, kişi, platform): uygulama girişte bildirim izni ister ve token'ı `public.register_push_device` ile kaydeder. Token yeni giriş yapan kişiye geçer (aynı telefonda hesap değişimi). Kişi başına en fazla 10 cihaz tutulur, en eskisi silinir. Kişi kendi kayıtlarını okur ve siler (RLS). Çıkışta uygulama token'ı FCM'den siler; geçersiz token'ı sunucu ilk gönderimde kaldırır.
  - **Gönderim:** C#'taki `PushDispatcher` birkaç saniyede bir (`Push:DispatchInterval`, varsayılan 5 sn, sıfır kapatır) gönderilmemiş bildirimleri (`notifications.pushed_at` boş, son 15 dakika) işaretler ve alıcının cihazlarına sesli bildirim olarak gönderir. Önce işaretlenir, sonra gönderilir; bir bildirim en fazla bir kez gider. Metin uygulamadaki cümleyle aynıdır.
  - **Kimlik bilgisi:** Firebase servis hesabı anahtarı (JSON) yalnızca sunucudadır, repoya girmez: `Push:CredentialsPath`. Tanımlı değilse push kapalıdır, bildirimler yalnızca uygulama içinde kalır.
  - **Platformlar:** Android. iOS için Apple APNs anahtarı, web için Web Push (VAPID) anahtarı bekleniyor.
  - Bildirime dokununca yayın bildirimi yayın odasını, diğerleri bildirimler ekranını açar.
- **Sesli uyarı:** Uygulama açıkken `live_scheduled` ya da `live_started` bildirimi gelince kısa bir uyarı sesi çalar ve ekranın altında yayını açan bir şerit görünür. Uygulama kapalı ya da arka plandayken aynı bildirim push ile sesli gelir.
- **Tercihler** (Faz 9, `notification_preferences`): kişi organizasyon hatırlatmalarını (1 gün önce, 1 saat önce), organizasyon değişikliği/iptali bildirimlerini, değerlendirme isteklerini (Faz 10) ve canlı yayın bildirimlerini (`live_scheduled`, `live_started`) kapatabilir. Kayıt yoksa hepsi açıktır. Kişinin kendi basit yazmasıdır (RLS). Bildirimi yazan fonksiyonlar tercihi okur (`private.wants_notification`); kapalı türde kayıt hiç oluşmaz. Diğer türler (katılım onayı, sıra yükselmesi, yaptırım vb.) kişiyi doğrudan ilgilendirdiği için kapatılamaz.

### Depolama (`media`)
- Herkese açık okunur. Yollar tahmin edilemez uuid'lerdir; hangi medyanın kime ait olduğu ancak RLS'in izin verdiği gönderi ve hikaye kayıtlarından öğrenilir. Bu, Instagram'ın CDN modeline benzer.
- Kullanıcı yalnızca `<uid>/` klasörüne yazar.
- Fotoğraf en fazla 10 MB, video 50 MB.
- Hesap silinince `media/<uid>/` temizlenir.

### Admin
- **İçerik sayfası:** gönderi arama (açıklama, yazar ya da grup), kaldırılanlar filtresi, gönderi detayı (medya, sayılar, yorumlar).
- **Gönderiyi kaldırma** (gerekçeli) ve **geri alma:** `post.removed`, `post.restored`.
- **Yorumu kaldırma:** `comment.removed`.
- Kaldırılan içerik kullanıcılara görünmez; sayaçlardan düşer, kanıt olarak saklanır.
- **Roller:** Görüntüleme `admin`, `moderator`, `support`. Kaldırma `admin`, `moderator`.
- **Bildirimler sayfası** (`GET /admin/notifications/stats`, rol: `admin`, `moderator`, `support`): push açık mı (sunucuda anahtar var mı), platforma göre kayıtlı cihazlar ve cihazı olan kişi sayısı, son 24 saatte oluşan bildirimler, telefona ulaşanlar (`notifications.push_deliveries` > 0) ve toplam teslim, gönderim kuyruğunda bekleyenler, son 24 saatin tür dağılımı. Yalnızca sayılardır; bildirim içerikleri ve token'lar gösterilmez.

### C# uç noktaları (Faz 4)
| Uç nokta | Açıklama |
|---|---|
| `POST /users/{id}/follow` | Takip et; yanıt `following` ya da `requested` |
| `DELETE /users/{id}/follow` | Takibi bırak ya da isteği geri al |
| `POST /me/follow-requests/{userId}/approval` | İsteği kabul et |
| `DELETE /me/follow-requests/{userId}` | İsteği reddet |
| `DELETE /me/followers/{userId}` | Takipçiyi çıkar |
| `POST /users/{id}/block` / `DELETE /users/{id}/block` | Engelle / engeli kaldır |
| `POST /users/{id}/teammate` | Ekip arkadaşlığı isteği (`message?`; Faz 13) |
| `DELETE /users/{id}/teammate` | İsteği geri çekme ya da ekip arkadaşlığını bitirme |
| `POST /me/teammate-requests/{userId}/approval`, `DELETE /me/teammate-requests/{userId}` | Gelen isteği kabul / reddetme |
| `POST /posts` | Gönderi (`caption`, `media[]`, `groupId?`, `eventId?` (Faz 10, anı), `commentsDisabled`, `hideLikeCount`) |
| `PATCH /posts/{id}` | Açıklama ve seçenekler |
| `DELETE /posts/{id}` | Gönderiyi ve medyasını sil (yazar ya da grup gönderisinde `posts.publish`) |
| `GET /admin/posts?q=&removed=&page=`, `GET /admin/posts/{id}` | İçerik listesi ve detayı |
| `POST /admin/posts/{id}/removal`, `DELETE /admin/posts/{id}/removal` | Kaldır (`reason`) / geri al |
| `POST /admin/comments/{id}/removal` | Yorumu kaldır (`reason`) |

## 3d. Organizasyonlar ve Anketler (Faz 5)

Ürün kararları (2026-10-20): organizasyonları herkes görür, yalnızca grup üyeleri katılır; kapasite dolunca bekleme listesi; katılım ücreti yalnızca bilgidir; anketlerde çoklu seçim, gizli oy, bitiş zamanı ve organizasyona bağlı anket vardır; hatırlatmalar 1 gün ve 1 saat önce gider. Veriler `events` modülünün tablolarındadır.

### Yetki
| Yetki | Açıklama | Roller (sahip dışında) |
|---|---|---|
| `events.manage` | Organizasyon oluşturma, düzenleme ve iptal; anket açma, kapatma ve silme | admin |

### Organizasyon
`events`: grup, oluşturan, başlık (3–100), açıklama (en fazla 2000), başlangıç ve isteğe bağlı bitiş, yer (en fazla 200) ve isteğe bağlı harita ya da çevrim içi bağlantısı (`http(s)`, en fazla 300), kapasite (boş = sınırsız, 1–10.000), katılım ücreti, kapak görseli, katılım koşulları (en fazla 500), gerekli ekipman (en fazla 10 madde, her biri 1–60), onaylı katılım (`approval_required`), katılan ve bekleyen sayıları, iptal bilgisi.

- **Zaman:** Başlangıç en az 15 dakika, en fazla 1 yıl ileride olur; bitiş başlangıçtan sonradır. Geçmiş organizasyon düzenlenemez ve katılıma kapanır (başlangıç anı geçince).
- **Katılım ücreti** (`fee_amount` küçük birim, `fee_currency` `TRY` / `USD` / `EUR`, `fee_note` en fazla 200; ör. "Yerinde nakit ödenir"): yalnızca gösterilir. Platform para toplamaz; ekranda bu açıkça yazar.
- **Kapak görseli:** `event-images` bucket'ında `<group_id>/<uuid>.<uzantı>`. Herkese açık okunur, yalnızca grupta `events.manage` yetkisi olan yazar. En fazla 5 MB; JPEG, PNG veya WebP. İstemci yükler, yolu API'ye bildirir; API yolun grubun klasöründe ve depoda olduğunu doğrular.
- **İptal:** Yetkili gerekçeyle iptal eder (`event.canceled`). İptal edilen organizasyon görünür kalır ama katılıma kapanır; katılanlara ve bekleyenlere `event_canceled` bildirimi gider.
- **Düzenleme:** Başlık, açıklama, zaman, yer, kapasite, ücret ve kapak değişebilir. Zaman ya da yer değişirse katılanlara `event_updated` bildirimi gider. Kapasite artarsa bekleyenler sırayla katılana geçer. Kapasite mevcut katılan sayısının altına inemez.
- **Kategori:** Organizasyonun kategorisi grubunun kategorisidir; ayrı seçilmez (Faz 8).
- **Takvime ekle:** `GET /events/{id}/calendar.ics` organizasyonu iCalendar dosyası olarak verir (başlık, zaman, yer, açıklama, sayfa bağlantısı). Oturum gerekmez; organizasyon kimin göreceğine açıksa dosyası da açıktır. Bitişi olmayan organizasyon 2 saat sürer sayılır. İptal edilen organizasyonun dosyası `STATUS:CANCELLED` taşır. Ek paket gerekmez: telefon dosyayı takvim uygulamasına verir.
- **Görünürlük:** Grup görünürse organizasyon sayfası herkese (oturum açmamış ziyaretçi dahil) açıktır. Katılanların listesini grubun üyeleri görür; diğerleri yalnızca sayıyı görür.

### Katılım ve bekleme listesi
`event_attendees`: organizasyon, kullanıcı, durum (`requested` / `going` / `waitlisted`), zaman.

- Katılmak ve vazgeçmek **C# API'den** geçer (kapasite ve sıra başkasını etkiler): `POST /events/{id}/attendance`, `DELETE /events/{id}/attendance`.
- Katılma: grup üyesi, hesabı aktif, organizasyon iptal edilmemiş ve başlamamış olmalı. Yer varsa `going`, yoksa `waitlisted`. Yanıt kişinin durumunu ve sıradaki yerini döner.
- **Onaylı katılım** (Faz 8): `approval_required` açıksa katılmak isteyen `requested` olur ve sayaçlara girmez. `events.manage` yetkilisi isteği onaylar; onaylanan, kapasiteye göre `going` ya da `waitlisted` olur ve `event_approved` bildirimi alır. Reddedilen istek silinir ve kişi `event_declined` bildirimi alır. Kişi isteğini kendisi geri alabilir. Yetkilinin kendi katılımı onay beklemez. Ayar sonradan kapatılırsa bekleyen istekler yine onaylanır ya da reddedilir.
- Bir `going` vazgeçince ya da kapasite artınca bekleyenlerin en eskisi `going` olur ve `event_promoted` bildirimi alır.
- Gruptan ayrılan kişinin gelecek organizasyonlardaki katılımı silinir (ve sıradaki yükselir).
- Trigger ikinci katmandır: kapasiteyi aşan `going` reddedilir, sayaçlar (`going_count`, `waitlist_count`) trigger ile tutulur, katılım yalnızca üyeler için ve yalnızca başlamamış, iptal edilmemiş organizasyona yapılır.

### Aylık organizasyon limiti
- Ay, Türkiye saatiyle takvim ayıdır. O ay **oluşturulan** organizasyonlar sayılır (iptal edilenler dahil; oluştur-iptal ile limit aşılmasın diye).
- Limit grubun paketindeki `monthly_events` değeridir (§7). Kontrol hem C#'ta (`IGroupPlanLimits`) hem `events` ekleme trigger'ında yapılır. Hata kodu `event.monthly_limit_reached`. Oluşturma ekranı kalan hakkı gösterir.

### Hatırlatmalar
- `EventReminderService` (5 dakikada bir) katılanlara (`going`) uygulama içi `event_reminder` bildirimi yazar: başlangıca 24 saatten az, 1 saatten fazla kala bir kez ("yarın"), 1 saatten az kala bir kez ("1 saat sonra"). Gönderildiği `events.reminded_day_at` ve `reminded_hour_at` ile işaretlenir. Push bildirimi Firebase bilgileri gelince bu kayıtlardan gider.

### Anketler
`polls` (grup, isteğe bağlı organizasyon, soru 3–200, `allows_multiple`, `is_anonymous`, isteğe bağlı `closes_at`, `closed_at`), `poll_options` (2–10 seçenek, 1–80 karakter), `poll_votes`.

- Anketi `events.manage` yetkilisi açar, erken kapatır ya da siler; bunlar C# API'den geçer. Bitiş zamanı en az 5 dakika, en fazla 90 gün ileridedir. Organizasyona bağlı anket o organizasyonun sayfasında görünür.
- **Oy vermek kullanıcının kendi basit yazmasıdır** (Flutter → Supabase, RLS): grup üyesi, hesabı aktif ve anket açık olmalı. Oy değiştirmek, oyu silip yeniden vermektir. Tek seçimli ankette kişi başına bir oy (trigger).
- **Görünürlük:** Anketleri ve sonuçlarını grubun üyeleri görür. Sonuçlar (`public.poll_results`) seçenek başına oy sayısını, oy veren kişi sayısını ve kişinin kendi oylarını döner. Gizli ankette kimin neye oy verdiği kimseye (anketi açana da) gösterilmez; açık ankette her seçeneğe oy verenler görülür.
- Anket kapanınca oy verilemez, sonuçlar kalır.

### Bildirimler
`event_promoted`, `event_updated`, `event_canceled`, `event_reminder`, `event_approved`, `event_declined`, `event_review` (bildirim kaydında `event_id`), `goal_completed` (Faz 12, bildirim kaydında `goal_id`), `teammate_request`, `teammate_accepted` (Faz 13). Organizasyon oluşturulduğunda toplu bildirim gönderilmez; organizasyon grup sayfasında ve grubu takip edenlerin ilgisine görünür.

### Arayüz
- **Grup sayfası:** "Organizasyonlar" bölümü (yaklaşanlar; kapak, tarih, yer, katılan sayısı) ve "Anketler" bölümü (açık anketler, oy verme ve sonuç çubukları). Yetkiliye "Organizasyon oluştur" ve "Anket aç".
- **Organizasyon sayfası** (`/e/<id>`): kapak, başlık, grup, tarih ve saat, yer ve harita bağlantısı, ücret bilgisi ("Ücret organizasyon sahibine ödenir, GrupX ödeme almaz"), kapasite çubuğu, katılanlar, bağlı anketler, Katıl / Bekleme listesine gir / Vazgeç. Yetkiliye Düzenle ve İptal et.
- **Organizasyon sayfası** (Faz 8): katılım koşulları ve ekipman listesi, "Takvime ekle", onaylı katılımda "Katılım isteği gönder" ve "Onay bekliyor"; yetkiliye bekleyen istekler (Onayla / Reddet).
- **Organizasyon formu:** kapak, başlık, açıklama, tarih ve saat, bitiş, yer, bağlantı, kapasite, ücret, katılım koşulları, ekipman, "Katılım onayla olsun"; bu ay kalan organizasyon hakkı.

### Takvim (Faz 9)
- Takvim organizasyon tablolarını okur; ayrı bir takvim verisi yoktur.
- **Takvimim** (`/calendar`): kişinin katıldığı, onay beklediği ve bekleme listesinde olduğu organizasyonlar; isteğe bağlı olarak üyesi olduğu grupların tüm organizasyonları ("Gruplarımın organizasyonları").
- **Grup takvimi** (`/calendar?group=<id>`): grubun organizasyonları (geçmiş dahil). Grup görünürse herkes okur.
- **Görünümler:** gün, hafta (pazartesi başlar) ve ay. Günler cihazın saat diliminde hesaplanır; zamanlar veritabanında UTC'dir.
- **Çakışma:** Kişinin iptal edilmemiş iki organizasyonunun (katılan, bekleyen ya da istek) zamanı kesişiyorsa çakışma sayılır. Bitişi olmayan organizasyon 2 saat sürer sayılır (`.ics` ile aynı). Takvim çakışanları işaretler. Organizasyon sayfası, kişinin o saatteki diğer organizasyonlarını gösterir (`event_detail.conflicts`).
- `public.calendar_events(range_start, range_end, target_group, include_groups)` en fazla 62 günlük aralık ve 500 organizasyon döner.

### Organizasyon sonrası (Faz 10)
- **Anılar:** Gönderi bir organizasyona bağlanabilir (`posts.event_id`; feed modülü). Bağlayan, organizasyonun bir yöneticisi (`events.manage`) ya da organizasyona **katılmış** (`going`) kişidir. Organizasyon başlamış ve iptal edilmemiş olmalıdır. Kuralı C# ve `posts` trigger'ı birlikte uygular. Bağlantı sonradan değişmez. Anı, sıradan bir gönderidir: görünürlüğü, şikayeti ve kaldırılması gönderi kurallarına uyar. Kimsenin fotoğrafı otomatik paylaşılmaz; herkes yalnızca kendi gönderisini bağlar. Organizasyon sayfası, görüntüleyenin görebildiği anıları gösterir (`public.event_posts`).
- **Değerlendirme** (`event_reviews`): organizasyona katılmış kişi, organizasyon bittikten sonra (bitişi yoksa başlangıçtan 2 saat sonra) 30 gün içinde 1–5 yıldız ve isteğe bağlı not (en fazla 500 karakter) verir. Kişi değerlendirmesini değiştirir ya da siler. Kendi basit yazmasıdır (RLS); uygunluğu trigger denetler. Herkes yalnızca ortalamayı ve sayıyı görür. Notları kişinin kendisi ve grubun `events.manage` yetkilileri görür (herkese açık yorum alanı yoktur).
- **Değerlendirme isteği:** Organizasyon bittikten sonra katılanlara bir kez `event_review` bildirimi gider (`EventReminderService`, `events.review_asked_at`). Bildirim tercihlerinden kapatılabilir (`event_review_requests`).
- **Özet ve geçmiş:** Biten organizasyonun sayfası katılan sayısını, puan ortalamasını ve anı sayısını gösterir. Grubun sıradaki organizasyonlarını da önerir. Grubun geçmişi (`public.group_event_history`) biten organizasyonları özetleriyle, yeniden eskiye ve sayfalı listeler.

### Katkı ve rozetler (Faz 11)
Ürün kararları (2026-10-21): organizasyon bitince "katılıyor" görünen herkes katılmış sayılır, düzenleyen gelmeyenleri işaretler. Rozetler görünür, sıralama yoktur.

- **Yoklama:** Organizasyon bittikten sonra 7 gün içinde `events.manage` yetkilisi bir katılanı "gelmedi" olarak işaretler ya da işareti kaldırır (`event_attendees.no_show_at`, C# API, audit log). "Gelmedi" işaretli kişi katılmış sayılmaz; değerlendirme yapamaz, anı ekleyemez.
- **Katkı ayrı bir puan tablosunda tutulmaz.** Her seferinde kaynak kayıtlardan hesaplanır. İstemci puan yazamaz, aynı işlem iki kez sayılamaz:
  - **Katılım:** iptal edilmemiş, bitmiş ve kişinin `going` olup "gelmedi" işaretlenmediği organizasyon.
  - **Düzenleme:** kişinin oluşturduğu, iptal edilmemiş, bitmiş ve düzenleyen dışında en az 2 kişinin katıldığı organizasyon (boş organizasyonla rozet kazanılamaz).
  - **Anı:** kaldırılmamış, organizasyona bağlı gönderi.
  - **Değerlendirme:** kişinin değerlendirmeleri.
- **Rozetler** (`public.badge_catalog()` tek kaynaktır; ekran koşulları buradan gösterir):

  | Rozet | Koşul |
  |---|---|
  | İlk adım | 1 katılım |
  | Müdavim | 10 katılım |
  | Yol arkadaşı | 25 katılım |
  | Kâşif | 3 farklı grubun organizasyonuna katılım |
  | Düzenleyici | 1 düzenleme |
  | Usta düzenleyici | 10 düzenleme |
  | Anı biriktiren | 5 anı |
  | Geri bildirimci | 5 değerlendirme |
  | `<Kategori>` tutkunu | Bir kategoride 5 katılım |

- Beğeni, takipçi ve gönderi sayısı katkıya girmez. Gönüllülük ve yeni üyelere yardım gibi doğrulanamayan katkılar Faz 12'deki görevlerle gelir.
- **Görünürlük:** Profilde (`public.user_contributions`) ve grubun üye listesinde (`public.group_contributions`, yalnızca o grubun katılım ve düzenleme sayıları) görünür. Gizli hesabın katkısını yalnızca içeriğini görebilenler görür. Sıralama ve "ayın en iyileri" listesi yoktur.

### Hedefler ve görevler (Faz 12)
Ürün kararları (2026-10-21): kişisel, grup, takım hedefleri ve onaylı görevler olur. Hedefleri `events.manage` yetkilileri açar. Ödül görev rozetidir; para ya da puan yoktur.

- **Hedef** (`goals`): grup, oluşturan, başlık (3–80), açıklama (en fazla 500), tür, ölçüt, hedef sayı (1–1000), dönem ve iptal bilgisi. Dönem en çok 92 gündür; bitiş başlangıçtan sonradır ve gelecektedir. Bir grupta aynı anda en fazla **5** aktif hedef (iptal edilmemiş ve dönemi bitmemiş) olur. Hedefi `events.manage` yetkilisi açar, iptal eder, takımlarını kurar ve görevleri onaylar (C# API + trigger, audit log).
- **Türler:**

  | Tür | İlerleme | Tamamlanınca rozeti alan |
  |---|---|---|
  | `personal` | Her üyenin kendi sayısı | Sayısı hedefe ulaşan üye |
  | `group` | Grubun toplam sayısı | Katkısı olan herkes |
  | `team` | Takımın toplam sayısı (`goal_teams`, `goal_team_members`; üye bir hedefte tek takımda) | Takımın katkısı olan üyeleri |
  | `task` | Üyenin "yaptım" bildirimi (`goal_claims`, not en fazla 300 karakter), yöneticinin onayı | Onaylanan üye |

- **Ölçütler** (`personal`, `group`, `team`): `attended` (katılım), `organized` (düzenleme), `memories` (anı). Sayım Faz 11'deki katkı kurallarıyla, yalnızca o grubun dönem içinde başlayan organizasyonlarından (anıda dönem içinde paylaşılan anılardan) yapılır. İstemci ilerleme yazamaz.
- **Tamamlanma** (`goal_completions`): `EventReminderService` dönemi süren hedefleri değerlendirir ve hedefe ulaşanları bir kez kaydeder (sistem işlemi). Onaylanan görev aynı transaction'da kaydedilir. Kayıt kalıcıdır; sonradan "gelmedi" işaretlense de rozet geri alınmaz. Kişiye `goal_completed` bildirimi gider.
- **Görev bildirimi:** Üyenin kendi basit yazmasıdır (RLS): grup üyesi, hedef `task` türünde ve dönemi sürüyor olmalıdır. Kişi bir göreve tek bildirim yapar; reddedilirse yeniden bildirebilir.
- **Rozet:** Profildeki rozetlere tamamlanan hedeflerin adları eklenir ("Hedef: Ekim yürüyüşleri"). Görünürlük Faz 11 kurallarıyla aynıdır.
- **Arayüz:** Grup sayfasında "Hedefler" bölümü (aktif hedefler, ilerleme çubukları, yetkiliye "Hedef oluştur"). Hedef sayfası (`/goals/<id>`) açıklamayı, dönemi ve ilerlemeyi gösterir; takım hedefinde takımları, görevde "Yaptım" düğmesini ve yöneticiye bekleyen bildirimleri gösterir; tamamlayanları listeler.

### Harita ile keşif (Faz 14)
Ürün kararları (2026-10-21): döşeme sağlayıcısı **Stadia Maps** (flutter_map ile). Grubun konumu 81 ilden biridir; organizasyonun buluşma noktası haritada iğneyle seçilir. Adres arama (geocoding) yoktur. Haritada yalnızca gelecekteki, iptal edilmemiş organizasyonlar ve aktif, görünür gruplar yer alır. Kişilerin konumu hiçbir zaman tutulmaz ve gösterilmez; uygulama cihaz konumu izni istemez.

- **İller** (`provinces`, core): plaka kodu (1–81), ad ve il merkezinin koordinatı. Herkes okur; yalnızca migration yazar.
- **Grubun ili** (`groups.province`, isteğe bağlı): grup oluşturulurken ya da düzenlenirken `group.edit` yetkilisi seçer (C# API + trigger, audit log'daki `group.updated` alan listesinde). Haritada grup ilin merkezinde gösterilir.
- **Buluşma noktası** (`events.meeting_lat`, `events.meeting_lng`, isteğe bağlı, ikisi birlikte): organizasyon formunda haritaya dokunularak seçilir. Kurallar diğer organizasyon alanlarıyla aynıdır (`events.manage`, başlamamış ve iptal edilmemiş organizasyon). Yer metni (`location`) zorunlu olarak kalır; iğne yalnızca onu tamamlar. Platform ekibi (admin, moderatör) uygunsuz bir noktayı (ör. birinin ev adresi) kaldırabilir; bu işlem audit log'a yazılır.
- **Harita verisi** (`public.map_items(south, west, north, east, category?)`): görünen alandaki gruplar (en fazla 200) ve organizasyonlar (en fazla 200). Grup görünürlük kuralı (`is_group_visible`) uygulanır. Oturum gerekir.
- **Döşemeler** C# API üzerinden gelir (`GET /map/tiles/{z}/{x}/{y}.png`). Bunun iki sebebi var: sağlayıcı anahtarı yalnızca sunucuda kalır ve kullanıcının IP adresi sağlayıcıya gitmez. Ayrıntılar:
  - Döşemeler bellekte önbelleklenir.
  - Kişi başına dakikada 600 istek sınırı vardır.
  - Kaynak `Map:TileUrl` ve `Map:ApiKey` ayarlarıdır. Adres tanımlı değilse harita 503 ile kapalıdır.
  - Yerel geliştirmede OpenStreetMap döşemeleri düşük hacimde kullanılır (`appsettings.Development.json`). Yayında Stadia'nın ücretli planı gerekir ve kullanıcı onayıyla açılır.
- **Arayüz:**
  - "Harita" ekranı (`/map`): gruplar ve organizasyonlar, kategori filtresi, harita ya da liste görünümü.
  - Organizasyon sayfasında küçük harita ve "Yol tarifi" bağlantısı (cihazın harita uygulaması açılır; ücret yoktur).
  - Organizasyon formunda iğne seçici; grup formunda il seçimi; grup sayfasında il.
  - Atıf her haritada görünür: © Stadia Maps, © OpenMapTiles, © OpenStreetMap katkıcıları.

### Veri ve erişim
| Tablo | Okuma | Yazma |
|---|---|---|
| `events` | Herkes (grup görünürse) | Backend |
| `event_attendees` | Grubun üyeleri ve kişinin kendisi | Backend |
| `polls`, `poll_options` | Grubun üyeleri | Backend |
| `poll_votes` | Kendi oyları; açık anketlerde grubun üyeleri | Kendi oyu (RLS) |
| `event_reviews` | Kişinin kendisi ve grubun `events.manage` yetkilileri; ortalama herkese | Kendi değerlendirmesi (RLS) |
| `goals`, `goal_teams`, `goal_team_members`, `goal_completions` | Grup görünürse herkes | Backend (tamamlanma: iş ve görev onayı) |
| `goal_claims` | Kişinin kendisi ve grubun `events.manage` yetkilileri | Kendi bildirimi (RLS); karar backend |
| Storage `event-images` | Herkes | `events.manage` (kendi grubunun klasörü) |

### Audit log
`event.created`, `event.updated`, `event.canceled` (gerekçe), `event.canceled_by_admin` (gerekçe), `event.meeting_point_removed_by_admin`, `event.attendee_approved`, `event.attendee_declined`, `event.no_show_marked`, `event.no_show_cleared`, `goal.created`, `goal.canceled`, `goal.team_created`, `goal.team_deleted`, `goal.claim_approved`, `goal.claim_rejected`, `poll.created`, `poll.closed`, `poll.deleted`. Kayıtların `group_id` alanı doludur. Katılım ve oy kişinin kendi işlemidir; yazılmaz.

### C# uç noktaları
| Uç nokta | Açıklama |
|---|---|
| `POST /groups/{id}/events` | Organizasyon oluşturma (`events.manage`, aylık limit) |
| `PUT /events/{id}` | Düzenleme (`events.manage`); formun tamamı gönderilir (buluşma noktası `meeting: {lat, lng}` ya da boş) |
| `POST /events/{id}/cancellation` | İptal (`reason`, `events.manage`) |
| `POST /events/{id}/attendance` | Katılma; yanıt `going`, `waitlisted` (ve sıra) ya da onaylı katılımda `requested` |
| `DELETE /events/{id}/attendance` | Vazgeçme ya da isteği geri alma; sıradaki yükselir |
| `POST /events/{id}/requests/{userId}/approval` | Katılım isteğini onaylama (`events.manage`) |
| `DELETE /events/{id}/requests/{userId}` | Katılım isteğini reddetme (`events.manage`) |
| `GET /events/{id}/calendar.ics` | Takvime ekle (oturum gerekmez) |
| `POST /groups/{id}/goals` | Hedef açma (`title`, `description`, `kind`, `metric?`, `target?`, `startsAt`, `endsAt`; `events.manage`, en fazla 5 aktif) |
| `POST /goals/{id}/cancellation` | Hedefi iptal etme (`events.manage`) |
| `POST /goals/{id}/teams` | Takım kurma (`name`, `memberIds[]`; `events.manage`) |
| `DELETE /goals/{id}/teams/{teamId}` | Takımı silme (`events.manage`) |
| `POST /goals/{id}/claims/{userId}/approval`, `DELETE /goals/{id}/claims/{userId}` | Görev bildirimini onaylama / reddetme (`events.manage`) |
| `PUT /events/{id}/no-shows/{userId}`, `DELETE /events/{id}/no-shows/{userId}` | Yoklama: "gelmedi" işareti ve kaldırılması (`events.manage`, bitişten sonra 7 gün) |
| `POST /groups/{id}/polls` | Anket açma (`question`, `options[]`, `allowsMultiple`, `isAnonymous`, `closesAt?`, `eventId?`) |
| `POST /polls/{id}/close`, `DELETE /polls/{id}` | Anketi kapatma / silme (`events.manage`) |
| `GET /admin/events?q=&status=&page=` | Organizasyonlar (`upcoming` / `past` / `canceled`). Rol: `admin`, `moderator`, `support` |
| `POST /admin/events/{id}/cancellation` | Platform ekibinin iptali (`reason`). Rol: `admin`, `moderator` |
| `DELETE /admin/events/{id}/meeting-point` | Buluşma noktasını kaldırma (Faz 14). Rol: `admin`, `moderator` |
| `GET /map/tiles/{z}/{x}/{y}.png` | Harita döşemesi (oturum gerekir; Faz 14) |

## 3e. Moderasyon ve Disiplin Kurulu (Faz 6)

Ürün kararları (2026-10-21):
- Grupla ilgili şikayet grubun moderasyonuna, grup dışındaki şikayet platform ekibine gider. Admin paneli hepsini görür.
- Kurul oylamasını Disiplin Kurulu üyeleri yapar ve oylama 72 saat sürer. Kurulu olmayan grupta sahip tek başına karar verir.
- İtirazı grup sahibi karara bağlar. Sahip dosyada tarafsa (dosyayı açtıysa ya da oy kullandıysa) itiraz platform ekibine gider.
- Oylamasız uygulanan tek yaptırım acil susturmadır: en çok 24 saat sürer ve otomatik olarak dosya açar.

Veriler `moderation` modülünün tablolarındadır.

### Yetkiler
| Yetki | Açıklama | Roller (sahip dışında) |
|---|---|---|
| `reports.review` | Grubun şikayetlerini görme ve ön inceleme (reddetme, şikayet edilen yorumu kaldırma), disiplin dosyası açma, dosyaları ve yaptırımları görme | admin, discipline, moderator |
| `members.mute` | Acil susturma (en çok 24 saat; dosya açılarak) | admin, discipline, moderator |

Oy kullanmak bir yetki değildir. Dosya açıldığı anda Disiplin Kurulu rolündeki üyeler o dosyanın oy verenleri olur.

**Rütbe kuralı:**
- Dosyayı açan, acil susturan ve içerik kaldıran kişinin rütbesi hedefinkinden kesinlikle büyük olmalıdır.
- Karar veren kurulun rütbesi de hedefinkinden büyük olmalıdır: kurul varsa 60, yoksa 100 (sahip).
- Bu yüzden kurulu olan grupta Yönetici ve Disiplin Kurulu üyesi hakkında dosya açılamaz; sahip önce rolü alır. Grup sahibi hakkında hiç dosya açılamaz.

### Şikayet
`reports` tablosunun alanları:
- Şikayet eden.
- Hedef türü ve kimliği:

  | Tür | Grup şikayeti olduğu durum |
  |---|---|
  | `post` | Grup gönderisi |
  | `comment` | Grup gönderisindeki yorum |
  | `event` | Her zaman (organizasyon) |
  | `live_comment` | Her zaman (canlı yayın yorumu) |
  | `user` | Bir grubun üyeler sayfasından şikayet edildiyse |

- Grup (`group_id`): boşsa şikayet platformundur.
- Hedef kişi (`subject_id`: içeriğin yazarı ya da şikayet edilen kullanıcı).
- Sebep: `spam`, `harassment`, `hate`, `violence`, `sexual`, `misinformation`, `other`.
- İsteğe bağlı açıklama (en fazla 500 karakter).
- İçeriğin şikayet anındaki kopyası (`excerpt`, en fazla 500 karakter). İçerik silinse de kanıt kalır.
- Durum.

**Şikayet etmek kullanıcının kendi basit yazmasıdır** (Flutter → Supabase, RLS). Kurallar:
- Hesap aktif olmalı ve kullanıcı içeriği görebilmeli.
- Kendini ya da kendi içeriğini şikayet edemez.
- Aynı hedefi, şikayeti açıkken bir kez şikayet edebilir.
- 24 saatte en fazla 20 şikayet gönderebilir.

Grup, hedef kişi ve kopya trigger ile hedeften doldurulur. `user` şikayetinde grup ancak iki kişi de o grubun üyesiyse kalır.

**Durumlar:**
- `open` (açık).
- `dismissed` (reddedildi).
- `actioned` (içerik kaldırıldı ya da dosya açıldı; `case_id` dolu olabilir).

Aynı hedefin açık şikayetleri ekranda tek satırda toplanır. Ön inceleme kararı hepsine birden uygulanır.

**Ön inceleme** (`reports.review`, C# API):
- **Reddet.**
- **İçeriği kaldır:**
  - Yorum Faz 4'teki gibi kaldırılır ve kanıt olarak saklanır.
  - Canlı yayın yorumu silinir.
  - Rütbe kuralı uygulanır. Grup gönderisi ve organizasyon grubun yöneticilerinindir; onları sahip ya da `posts.publish` / `events.manage` yetkilisi kendi ekranından kaldırır.
- **Disiplin dosyası aç.**

**Gizlilik:** Şikayet edilen kişi şikayeti ve şikayet edeni görmez. Grup moderasyonu da şikayet edeni görmez, yalnızca platform ekibi görür.

### Disiplin dosyası ve oylama
`moderation_cases` tablosunun alanları:
- Grup.
- Hedef kişi.
- Açan.
- Önerilen yaptırım ve süresi.
- Gerekçe (10–1000 karakter).
- Durum: `voting` → `approved` / `rejected`.
- Karar eşiği (açılış anındaki grup ayarı).
- Oylama bitişi.
- Karar zamanı.

`case_votes`: oy verenlerin dosya açıldığı andaki listesi ve oyları (`approve` / `reject`).

- Dosyayı `reports.review` yetkilisi açar: bir şikayetten (o hedefin açık şikayetleri `actioned` olur) ya da üyeler sayfasından.
- Bir kişi hakkında aynı grupta aynı anda tek açık dosya olur.
- **Oy verenler:** Hedef kişi dışındaki Disiplin Kurulu üyeleri. Kurul yoksa (ya da tek üyesi hedef kişiyse) oy veren yalnızca grup sahibidir.
- **Karar eşiği** (`groups.case_threshold`; yalnızca sahip değiştirir):
  - `majority`: salt çoğunluk, varsayılan, yarıdan fazla.
  - `two_thirds`: üçte iki.
  - `unanimous`: oybirliği.
- **Karar:**
  - Onay oyları, oy verenlerin **tamamına** göre eşiği geçince dosya hemen onaylanır.
  - Herkes oy verdiyse dosya hemen sonuçlanır.
  - 72 saat dolunca **verilen oylara** göre karar çıkar. Hiç oy yoksa dosya reddedilir.
  - Karar kuralı tek yerdedir: `private.case_outcome(case_id)`. C# ve trigger aynı fonksiyonu kullanır.
- Oy, karar çıkana kadar değiştirilebilir. Oylar ve oy verenler yalnızca sayı olarak gösterilir; kişi kendi oyunu görür.
- `ModerationMonitor` (dakikada bir, `Moderation:MonitorInterval`) süresi dolan dosyaları karara bağlar (sistem işlemi).

### Yaptırımlar
`sanctions` tablosunun alanları:
- Grup.
- Kişi.
- Dosya.
- Tür.
- Acil olup olmadığı (`interim`).
- Başlangıç ve bitiş.
- Kaldırılma bilgisi.

| Tür | Etki | Süre |
|---|---|---|
| `warning` (uyarı) | Kişiye bildirim gider, kayda geçer | — |
| `mute` (susturma) | Grup gönderilerine yorum yapamaz. Canlı yayında yalnızca dinler: yorum yazamaz, el kaldıramaz, sahneye alınamaz; yayındaysa sahneden iner | 1–90 gün |
| `kick` (çıkarma) | Gruptan çıkarılır, rolleri silinir, gelecek organizasyonlardaki katılımı düşer. Sonra yeniden katılabilir | — |
| `ban` | Çıkarılır. Süre bitene kadar katılamaz, istek gönderemez, davet alamaz | 1–365 gün ya da kalıcı |

- Onaylanan dosyanın yaptırımı aynı transaction'da uygulanır ve kişiye `sanction_applied` bildirimi gider.
- Çıkarma ve ban üyeliği groups modülünün sözleşmesiyle (`IGroupMembership`) siler. Kişi o an canlı yayındaysa canlı yayın modülü onu odadan çıkarır; susturulan kişiyi sahneden indirir (`ILiveAdministration.EnforceSanctionAsync`).
- **Acil susturma** (`members.mute`):
  - Dosya açılırken "hemen sustur" seçilirse dosya kararına kadar, en çok 24 saat süren bir `mute` (`interim`) uygulanır.
  - Dosya karara bağlanınca acil susturma kalkar. Onaylanırsa yerine kararın yaptırımı gelir.
  - Acil susturmaya itiraz edilmez.
- Kontrol fonksiyonları: `private.is_group_banned(group, user)` ve `private.is_group_muted(group, user)`. Groups, feed ve live trigger'ları ile C# servisleri bunları kullanır (okuma yardımcısı).
- Trigger'lar ikinci katmandır:
  - Yaptırım yalnızca onaylanmış dosyadan ya da `members.mute` yetkili ve rütbesi yüksek kişinin açtığı dosyanın acil susturması olarak eklenebilir.
  - Başka bir üyeyi gruptan silmek yalnızca aynı transaction'da eklenen bir `kick` ya da `ban` ile mümkündür.

### İtiraz
`sanction_appeals` tablosunun alanları:
- Yaptırım (yaptırım başına tek itiraz).
- İtiraz eden.
- Metin (10–1000 karakter).
- İtirazı karara bağlayan (`owner` ya da `platform`).
- Durum: `pending` → `upheld` (yaptırım sürer) / `overturned` (yaptırım kalkar).
- Karar notu.

- Kişi, acil olmayan ve kaldırılmamış bir yaptırıma 7 gün içinde itiraz eder. Kendi basit yazmasıdır (RLS); trigger, itirazı kimin karara bağlayacağını belirler.
- İtiraz kararı beklenirken yaptırım sürer. Kaldırılan ban ya da çıkarmada üyelik geri gelmez; kişi yeniden katılabilir.
- Sahibe `appeal_submitted` bildirimi gider. Kişiye karar `appeal_decided` bildirimiyle iletilir.

### Yasa dışı faaliyet ve platform bildirimi (kullanıcı kararı, 2026-10-28)
Şiddet, tehdit, hakaret, nefret söylemi, cinsel istismar, dolandırıcılık, uyuşturucu, terör ya da başka bir suç teşkil eden faaliyet, grup kurallarının ötesinde platformun da sorunudur.
- **Dosya:** Dosyayı açan (`reports.review`), önerilen yaptırım **ban** iken dosyayı "yasa dışı faaliyet" olarak işaretleyip bir kategori seçebilir (`moderation_cases.illegal_category`): `violence`, `threat`, `insult`, `hate`, `sexual`, `fraud`, `drugs`, `terror`, `other_crime`. İşaret ve kategori sonradan değişmez. Oylama ve eşik her dosyadakiyle aynıdır; kararı disiplin kurulu verir (kurul yoksa sahip).
- **Onay anında** (aynı transaction'da):
  1. Grup banı her zamanki gibi uygulanır.
  2. Kişinin **hesabı platform incelemesine kadar askıya alınır**. Supabase Auth banı uygulanır, oturumlar kapanır. Gerekçe "Yasa dışı faaliyet bildirimi platform ekibince inceleniyor."dur. Silinmek üzere olan hesap askıya alınmaz; bildirim yine açılır.
  3. Bir **platform bildirimi** (`platform_referrals`) açılır.
- **Bildirimin alanları:**
  - grup, grup adı, kişi ve kullanıcı adı (anlık kopya),
  - kategori ve kurulun gerekçesi,
  - kanıt: dosyaya bağlı şikayetlerin içerik kopyaları,
  - durum, karar ve kolluk bilgisi.

  Kişi ya da grup silinse de bildirim ve kanıtı kalır (yasal saklama; kişi kimliği yabancı anahtarsız tutulur).
- **Kanıt kapsamı:** Kurul yalnızca grubun içindekileri görür: gönderi, yorum, grup sohbeti, canlı yayın yorumu ve şikayet edilen içeriklerin kopyaları. Birebir (özel) mesajları göremez; özel mesaj şikayetleri yalnızca platform ekibine gider (haberleşmenin gizliliği).
- **Platform kararı** (admin paneli; `admin` ve `moderator` görür, kararı ve kolluk kaydını yalnızca `admin` verir, çünkü iadesiz paket iptali de yalnızca platform yöneticisine açıktır):
  - **Banla:** Süreli (1–3650 gün) ya da kalıcı. Hesap bu süreyle askıda kalır. Kişinin kişisel paketleri (eşleşme ve ekip arkadaşı) **iadesiz** iptal edilir. Sahibi olduğu gruplar askıya alınır ve paketleri iadesiz iptal edilir. İptal gerekçesi `cancel_note`'a yazılır.
  - **Temize çıkar:** Hesap askısı kalkar. Grup banı kurulun kararıdır, sürer; kişi itiraz hakkını kullanabilir.
  - Kararla birlikte **kolluk durumu** seçilir: `none` ya da `to_notify` (bildirilecek). Bildirim yapıldığında `notified` olarak işaretlenir ve tarih ile notu (ör. başvuru yeri, evrak no) kaydedilir.
  - Kolluğa ve adli makamlara veri aktarımını yalnızca GrupX (veri sorumlusu) yapar, grup kurulu yapmaz. Aktarım, kanunun öngördüğü durumlarda ya da yetkili makamların talebiyle olur (KVKK m.8/2, 5651).
- Bütün adımlar `audit_log`'a yazılır: `referral.opened`, `referral.decided`, `referral.authorities_notified`.
- **Tablo koruması:** `platform_referrals` RLS ile yalnızca platform ekibine (`admin`, `moderator`) görünür. İstemci yazamaz. Trigger kuralları:
  - bildirim yalnızca onaylanmış, işaretli bir dosyadan açılır,
  - kanıt alanları değişmez,
  - durum yalnızca `pending → banned | cleared` yönünde ilerler,
  - kolluk durumu `to_notify → notified` yönünde ilerler,
  - kararı yalnızca platform yöneticisi (`admin`) verir.
- **Uç noktalar:** `GET /admin/referrals?status=`, `POST /admin/referrals/{id}/decision` (`ban`, `banDays` ya da kalıcı, `lawEnforcement`, `note`), `POST /admin/referrals/{id}/authorities` (`note`).
- **Sözleşme:** Bu süreç, kayıtta ve mevcut kullanıcılara bir sonraki açılışta onaylatılan `community_rules` metninde ayrıntılı yazılıdır. Metin bir taslaktır ve hukuki incelemeden geçmelidir.

### Bildirimler
| Tür | Kime |
|---|---|
| `case_vote` | Oy verenlere |
| `sanction_applied` | Yaptırım alan kişiye |
| `appeal_submitted` | Sahibe |
| `appeal_decided` | İtiraz edene |

Bildirim kaydında `group_id` ve `sanction_id` bulunur. Yaptırım bildirimlerinde kişi değil grup gösterilir.

### Arayüz
- **Şikayet et:** gönderi, yorum, organizasyon, canlı yayın yorumu ve profil menülerinde; grup üyeler sayfasında üye menüsünde. Sebep ve isteğe bağlı açıklamadan oluşan bir alt sayfa açılır.
- **Grup moderasyonu** (`/g/<handle>/moderation`, `reports.review` ya da sahip). Üç sekmesi vardır:
  - Şikayetler: hedef, sebepler, sayı, kopya; Reddet, İçeriği kaldır, Dosya aç.
  - Dosyalar: oylamadakiler ve kararlar; oy ver, kalan süre, oy sayıları.
  - Yaptırımlar ve itirazlar: sahip itirazı karara bağlar.

  Grup sayfasında yetkiliye bekleyen işlerin sayısıyla bir giriş kartı gösterilir.
- **Üye menüsü** (yetkiliye): "Disiplin dosyası aç" (önerilen yaptırım, süre, gerekçe, "Hemen sustur (24 saat)").
- **Yaptırımlarım** (`/me/sanctions`, ayarlardan): grup, tür, süre, gerekçe, itiraz durumu, "İtiraz et".
- **Grup ayarı:** Sahip "Kurul karar eşiği"ni moderasyon ekranındaki ayar düğmesinden seçer (`PUT /groups/{id}/case-threshold`). Yeni dosyalarda geçerli olur.

### Admin
- **Şikayetler sayfası:**
  - Tüm şikayetler: kapsam (platform / grup), durum ve tür filtresi.
  - Şikayet eden ve hedef kişi.
  - Hedefe bağlantı (gönderi detayı, kullanıcı, grup).
  - Reddet ya da "İşlem yapıldı" (`report.resolved`). İçeriği kaldırma ve hesabı askıya alma mevcut sayfalardan yapılır.
- **İtirazlar sekmesi:** platform ekibine düşen itirazlar; Onayla (yaptırım sürer) ya da Kaldır.
- **Roller:** Görüntüleme `admin`, `moderator`, `support`. İşlem `admin`, `moderator`.

### Veri ve erişim
| Tablo | Okuma | Yazma |
|---|---|---|
| `reports` | Şikayet eden kendi kaydını | Kendi şikayeti (RLS); durum backend |
| `moderation_cases`, `case_votes` | — (grup moderasyonu RPC ile) | Backend |
| `sanctions` | Kişi kendi yaptırımlarını | Backend |
| `sanction_appeals` | İtiraz eden kendi itirazını | Kendi itirazı (RLS); karar backend |

- `public.group_moderation(group_id)`: grubun açık şikayetlerini (şikayet edenler olmadan), dosyalarını, etkin yaptırımlarını ve bekleyen itirazlarını döner. Kişinin hangi işlemleri yapabileceğini de bildirir. `reports.review` yetkilisi ya da sahip okur; diğerleri boş sonuç alır.
- `public.my_sanctions()`: kişinin yaptırımlarını ve itiraz durumunu döner.
- Grup moderasyonu RPC'leri `private` şemasındaki `SECURITY DEFINER` fonksiyonların `security invoker` sarmalayıcılarıdır.

### Audit log
`report.dismissed`, `report.content_removed`, `report.resolved` (platform), `case.opened`, `case.decided` (sonuç), `sanction.applied`, `sanction.lifted` (neden), `appeal.decided`, `group.case_threshold_changed`. Kayıtların `group_id` alanı doludur (platform şikayetleri hariç). Şikayet, oy ve itiraz metni kişinin kendi işlemidir; kendi tablolarında durur.

### C# uç noktaları
| Uç nokta | Açıklama |
|---|---|
| `POST /reports/{id}/dismissal` | Hedefin açık şikayetlerini reddetme (`reports.review`) |
| `POST /reports/{id}/removal` | Şikayet edilen yorumu ya da canlı yayın yorumunu kaldırma (`reason`, `reports.review` + rütbe) |
| `POST /groups/{id}/cases` | Dosya açma (`subjectId`, `sanction`, `durationDays?`, `reason`, `reportId?`, `muteNow`). `reports.review` + rütbe; `muteNow` için `members.mute` |
| `PUT /cases/{id}/vote` | Oy verme ya da değiştirme (`approve`) |
| `POST /appeals/{id}/decision` | Sahibin itiraz kararı (`overturn`, `note`) |
| `PUT /groups/{id}/case-threshold` | Kurul karar eşiği (`threshold`; groups modülü, `roles.assign` yani sahip) |
| `GET /admin/reports?scope=&status=&type=&page=` | Şikayetler. Rol: `admin`, `moderator`, `support` |
| `POST /admin/reports/{id}/dismissal`, `POST /admin/reports/{id}/resolution` | Reddetme / işlem yapıldı. Rol: `admin`, `moderator` |
| `GET /admin/appeals?status=&page=` | Platformun itirazları. Rol: `admin`, `moderator`, `support` |
| `POST /admin/appeals/{id}/decision` | Platformun itiraz kararı (`overturn`, `note`). Rol: `admin`, `moderator` |

## 3f. Mesajlaşma (Faz 15)

Ürün kararları (2026-10-22):
- **Birebir mesajlaşma yalnızca iki ilişkide açıktır (kullanıcı kararı, 2026-10-26):** eşleşenler (§3g; yazmak için Eşleşme Sohbeti paketi, `match_chat_locked`) ve ekip arkadaşları (yazmak için Ekip Arkadaşı paketi, `teammate_chat_locked`; okumak ücretsiz). Takip mesaj hakkı vermez; takip yalnızca gönderileri görmek içindir. Yabancıya mesaj isteği gönderilemez (`message_not_allowed`). Böylece eşleşmenin ücretli sohbeti sosyal taraftan aşılamaz.
- Biten bir eşleşme aralarındaki sohbeti kapatır (`match_ended`) ve iki tarafın birbirini takibini (ve bekleyen takip isteklerini) kaldırır; sonradan yeniden takip mümkündür ama mesaj hakkı vermez. Ekip arkadaşıysalar (ve paketleri varsa) yazışmaları sürer.
- **Eski sohbetler:** bu karardan önce karşılıklı takip ya da mesaj isteğiyle açılmış birebir sohbetler silinmez ve okunur; kurala uymayan taraf yeni mesaj yazamaz. Bekleyen eski istekler kabul edilebilir ya da reddedilebilir, ama yazma hakkı açmaz.
- Her grubun tek bir sohbeti vardır.
- Mesaj metin ve fotoğraftan oluşur.
- Şikayet edilen mesajda platform ekibi, mesajı ve sohbetteki önceki 5 mesajı görür.

### Konuşmalar
- **`conversations`:** `kind` ya `direct` ya da `group` olur.
  - Birebir konuşma bir kişi çiftine bir kezdir (`user_a < user_b`).
  - Grup konuşması gruba bir kezdir. Grup oluşturulunca trigger ile açılır; mevcut gruplar migration'da doldurulur.
  - Grup konuşmasında `admins_only` açıksa yalnızca `posts.publish` yetkilileri (sahip ve Yönetici) yazar. Bu ayarı `group.edit` yetkilisi değiştirir (C# API, audit log).
- **`conversation_members`:** kişinin konuşmadaki durumu (`active`, `request`, `declined`) ve son okuma zamanı (`last_read_at`).
  - Birebir konuşmada iki kişinin de satırı vardır.
  - Grup konuşmasında satır yalnızca okuma zamanı için tutulur. Kimin okuyup yazabileceğini grup üyeliği belirler.
- **Kim okur:**
  - Birebir konuşmayı iki taraf okur. Reddeden taraf da okuyabilir, ama konuşma listesinde görünmez.
  - Grup konuşmasını grubun üyeleri okur. Çıkarılan ya da banlanan kişi üye olmadığı için göremez.
  - Engellediğin kişilerin grup mesajları sana gösterilmez.

### Birebir mesaj ve istek
- Konuşmayı başlatan `POST /messages/direct/{userId}` çağrısıdır. Yeni konuşma yalnızca eşleşenler ve ekip arkadaşları arasında açılır (iki taraf da `active`); diğerlerine `message_not_allowed`. Daha önce açılmış bir konuşma her zaman (okumak için) açılır.
- Profildeki "Mesaj gönder" düğmesi yalnızca `public.can_message(other)` doğruysa (eşleşme, ekip arkadaşlığı ya da eski bir konuşma) görünür.
- Aşağıdaki **istek** kuralları yalnızca kararlardan önce açılmış eski isteklere uygulanır; yeni istek oluşmaz.
- **Engel:** iki yönde de yazılamaz ve yeni konuşma açılamaz.
- **İstek** kabul edilene kadar:
  - Alıcı yanıt veremez (önce kabul eder).
  - Gönderen alıcının okuma bilgisini görmez.
  - Gönderen yazmaya devam edebilir.
- **Ret:** istek reddedilirse gönderen o konuşmaya artık yazamaz (`message_declined`). Alıcı sonradan kendisi yazarsa konuşma yeniden açılır.
- **Sınır:** bir kişi dakikada en fazla 30 mesaj gönderir.

### Mesaj
- **`messages`:** konuşma, gönderen, metin (en fazla 2.000 karakter) ve isteğe bağlı tek fotoğraf. Metin ya da fotoğraftan en az biri zorunludur.
- **Gönderme** C# API üzerinden yapılır (`POST /conversations/{id}/messages`). Trigger kuralları tekrar kontrol eder:
  - Hesap aktif olmalı ve engel olmamalı.
  - Birebir konuşmada taraflar eşleşmiş (ve gönderen Eşleşme Sohbeti paketli) ya da ekip arkadaşı olmalı.
  - Eski isteklerin istek ve ret durumları uygulanır.
  - Grupta susturulan üye yazamaz (Faz 6); `admins_only` modu uygulanır.
  - Hız sınırı uygulanır.
- **Silme:** gönderen kendi mesajını herkesten siler. Kayıt kalır; metin ve fotoğraf temizlenir ve mesaj "Bu mesaj silindi" olarak görünür.
- **Fotoğraf:** özel `message-images` deposunda tutulur (yol `{konuşma}/{dosya}`; JPEG, PNG ya da WebP; en fazla 5 MB).
  - Yalnızca konuşmanın okurları okur; yükleme yalnızca o konuşmanın okurları içindir.
  - İstemci imzalı adresle gösterir.
- **Okundu:** kişi kendi okuma zamanını yazar (`public.mark_conversation_read`, kendi basit yazması). Birebir konuşmada karşı tarafın okuma zamanı "Görüldü" olarak gösterilir; grup sohbetinde gösterilmez.
- **Gönderenin fotoğrafı (kullanıcı isteği, 2026-10-27):** Instagram'daki gibi karşı tarafın mesajlarının solunda yuvarlak profil fotoğrafı durur; art arda gelen mesajlarda yalnızca son mesajın yanında görünür, diğerleri hizayı korur. Fotoğrafa dokununca kişinin profili açılır. Birebir ve grup sohbetinde aynıdır; kişinin kendi mesajlarında fotoğraf yoktur.
- **Anlık güncelleme:** Supabase Realtime ile gelir (`messages`, RLS korur).
- **Bildirim tablosuna yazılmaz.** Okunmamış mesaj sayısı mesaj ikonunda gösterilir; push bildirimi Firebase bilgileri gelince bağlanır.
- **Hesap silme:** kişinin mesajlarını da siler (KVKK).

### Şikayet ve moderasyon
- Mesaj şikayet edilebilir (`reports.target_type = 'message'`; kanıt olarak metin saklanır).
  - Grup sohbetindeki mesaj şikayeti grubun moderasyon masasına gider. `reports.review` yetkilisi mesajı kaldırabilir; rütbe kuralı uygulanır.
  - Birebir mesaj şikayeti platform ekibine gider.
- **Platform ekibinin gördükleri:** şikayet edilen mesaj ve sohbetteki önceki 5 mesaj (`GET /admin/reports/{id}/message-context`). Bunun dışında hiçbir özel mesaj okunamaz. Her görüntüleme audit log'a yazılır (`message.context_viewed`).
- Platform ekibi (admin, moderatör) mesajı kaldırabilir (`message.removed_by_admin`).

### Veri ve erişim
| Tablo | Okuma | Yazma |
|---|---|---|
| `conversations` | Konuşmanın okurları | Backend (grup konuşması: trigger) |
| `conversation_members` | Kişinin kendi satırları; birebirde karşı tarafın satırı | Backend; okuma zamanı kişinin kendisi (RPC) |
| `messages` | Konuşmanın okurları (engellenenlerin mesajları hariç) | Backend |
| Storage `message-images` | Konuşmanın okurları | Konuşmanın okurları (kendi klasörlerine değil, konuşmanın klasörüne; sahip kendisi) |

### Audit log
`group.chat_mode_changed`, `message.removed` (grup moderasyonu, rapor üzerinden `report.content_removed`), `message.removed_by_admin`, `message.context_viewed`. Kişinin kendi mesajı ve kendi silmesi yazılmaz.

### C# uç noktaları
| Uç nokta | Açıklama |
|---|---|
| `POST /messages/direct/{userId}` | Birebir konuşmayı bulma ya da açma; yanıt konuşma kimliği ve alıcının durumu (`active` / `request`) |
| `POST /conversations/{id}/messages` | Mesaj gönderme (`body`, `imagePath?`) |
| `POST /conversations/{id}/acceptance`, `DELETE /conversations/{id}/acceptance` | Mesaj isteğini kabul etme / reddetme |
| `DELETE /messages/{id}` | Kendi mesajını herkesten silme |
| `PUT /groups/{id}/chat` | Grup sohbeti modu (`adminsOnly`; `group.edit`) |
| `GET /admin/reports/{id}/message-context` | Şikayet edilen mesaj ve önceki 5 mesaj (admin, moderatör; audit log) |
| `POST /admin/messages/{id}/removal` | Mesajı kaldırma (`reason`; admin, moderatör) |

## 3g. Eşleşme (Faz 15.6)

Ürün kararları (2026-10-26, kullanıcı onayladı): ortak gruplardan oluşan havuz, kart kaydırma, Arkadaş ve Sevgili modları, freemium, ödeme mevcut web akışıyla (PayTR / iyzico). Uygulama içi satın almaya geçiş Faz 17'de mağaza kurallarına göre ayrıca değerlendirilir.

### İlkeler
- **İsteğe bağlı ve ayrı:** Eşleşme, sosyal profilden ayrı bir **eşleşme profili**dir. Kişi açmadıkça hiçbir yerde görünmez; açmayan kişi kimseyi de göremez.
- **18 yaş sınırı:** Modül yalnızca 18 yaşını doldurmuş kişilere açıktır (doğum tarihi, sunucuda ve SQL'de kontrol). Doğum tarihi ve yaş sınırı yalnızca bu modülde tutulur; sosyal profilde yaş görünmez.
- **KVKK:** Cinsiyet, aradığı kişi ve Sevgili modu özel nitelikli veriye yakın kabul edilir. Eşleşme profili açılırken ayrı **açık rıza** alınır (`consented_at`, `consent_version`). Kişi eşleşme verisinin tamamını tek dokunuşla siler: profil, fotoğraflar, kaydırmalar, eşleşmeler. Mesajlar mesajlaşma modülünün kuralına göre kalır.
- **Konum:** Yalnızca il (81 ilden biri). Hassas konum alınmaz ve gösterilmez.
- **Güvenlik:** Engel her iki yönde havuzdan ve eşleşmelerden çıkarır (`blocks` tekrar kullanılır). Eşleşme profili ve fotoğrafları şikayet edilebilir (moderasyon `reports`, yeni hedef türleri). Platform ekibi kişinin eşleşme profilini kapatabilir.

### Eşleşme profili
- **Modlar:** Arkadaş, Sevgili ya da ikisi. Her mod ayrı bir destedir; bir modda geçilen kişi diğer modda yine görünebilir.
- **Bilgiler:** 2–6 fotoğraf (ilki kapak), doğum tarihi (yaş gösterilir), cinsiyet (kadın, erkek, ikili olmayan), il, 300 karakter "hakkımda", ilgi alanları (sosyal profildeki `profile_interests`), isteğe bağlı meslek ve eğitim.
- **Sevgili modunda ek:** aradığı cinsiyetler ve yaş aralığı (18–99). Eşleşme yalnızca **iki taraf da** birbirinin cinsiyet ve yaş tercihine uyuyorsa önerilir.
- **Duraklat:** Kişi profilini gizler; desteler ve beğeniler durur, mevcut eşleşmeler kalır.

### Havuz ve deste
- **Havuz:** eşleşme profili açık ve aynı modda olan, en az bir **ortak grubu** (üyelik ya da grup takibi) bulunan, aktif hesaplı, engel ilişkisi olmayan, daha önce bu modda kaydırılmamış ve eşleşilmemiş kişiler.
- **Sıralama:** seni süper beğenenler, öne çıkanlar (Premium), sonra ortak grup sayısı, sonra son etkinlik. Kartta "Ortak gruplarınız" adlarıyla yazar.
- **Kart (Tinder tarzı deste):** kartın tamamı fotoğraftır; kenarlara dokununca fotoğraflar geçer. Fotoğrafın üstünde ad ve yaş, meslek, il, ortak grup ve en fazla üç ilgi alanı (ortak olanlar kalpli); "i" düğmesi profilin tamamını (tüm fotoğraflar, hakkımda, eğitim, ilgi alanları, ortak gruplar) açar. Seni süper beğenen kişinin kartında "Seni süper beğendi" yazar. Kullanıcı adı ve sosyal profil bağlantısı eşleşmeden önce gösterilmez.
- **Hareketler:** sağa kaydır beğen, sola geç, yukarı süper beğen; kart sürüklenirken BEĞEN / GEÇ / SÜPER damgası belirir, bırakınca uçarak çıkar, arkadaki kart büyüyerek öne gelir. Altta aynı işler için düğmeler: Geri al · Geç · Süper beğen · Beğen · Öne çık.
- Okuma `public.match_deck(deck, page_size, min_age, max_age, in_province, with_interest, in_group)` ile yapılır; filtreler Premium ister (`premium_required`).

### Kaydırma ve eşleşme
- **Beğen / Geç / Süper beğen** (ve Premium'da **Geri al**, **Öne çık**) C# üzerinden yazılır: günlük haklar ve Premium kontrolü kural olduğu için (§2).
- **Süper beğeni:** bir beğenidir; ayrı günlük hakkı vardır (ücretsiz 1, Premium 5; admin değiştirir) ve beğeni hakkından düşmez. Beğenilen kişiye `match_super_liked` bildirimi gider, süper beğenen kişi onun destesinde en başa çıkar.
- **Geri al (Premium):** kişinin son kaydırması bir "geç" ise silinir ve kart destenin başına döner. Beğeniler geri alınmaz.
- **Öne çık (Premium):** Türkiye gününde bir kez, `boost_minutes` (varsayılan 30) dakika boyunca kişi ortak gruplarındaki destelerde en başta görünür (`match_boosts`).
- İki kişi aynı modda birbirini beğenince **eşleşme** oluşur. İkisine `match_created` bildirimi (push dahil) gider ve mesajlaşma modülünde mesaj isteği olmadan doğrudan sohbet açılır (`IMessagingMatches`).
- **Eşleşmeyi bitir:** iki taraf da eşleşmeyi bitirebilir. Sohbet ikisine de kapanır, kişiler birbirinin destesine bir daha çıkmaz.
- **İki modda eşleşme (kullanıcı kararı, 2026-10-27):** aynı iki kişi hem Arkadaş hem Sevgili olarak eşleşirse Eşleşmelerim'de tek kayıt görünür ve iki mod birlikte yazar (`my_matches()` kişi başına bir satır, `modes`). İkisinden biri "Yalnızca arkadaş kal" ya da "Yalnızca sevgili kal" diyerek diğer modu iki taraf için bitirir; sohbet ve takip sürer. Takip ve sohbet ancak son eşleşme de bitince kapanır.
- Kaydırmalar 90 gün saklanır; "geç" denen kişi 90 gün sonra yeniden önerilebilir. "Seni beğenenler" de aynı kuralı izler.
- Kaydırma yalnızca destedeki kişiye yapılır (`private.match_in_deck`: havuzda, bu modda beğenilmemiş, son 90 günde geçilmemiş, eşleşilmemiş). Aynı kişiyi API üzerinden yeniden kaydırmak `match.not_in_deck` döner; geçilen kişiye dönmenin yolu "Geri al"dır.

### Ücretli paketler (kullanıcı kararı, 2026-10-26)
Her özellik ayrı bir paket olarak satılır; kişi yalnızca istediğini alır. Arkadaş ve Sevgili modu için kural aynıdır.

| Paket (`slug`) | Açtığı özellik (`feature`) | Aylık | Yıllık |
|---|---|---|---|
| Eşleşmelerim (`matching_reveal`) | `reveal`: kiminle eşleştiğini görmek (ad, fotoğraflar, profil) | 49 ₺ · $1.99 | 490 ₺ · $19.90 |
| Eşleşme Sohbeti (`matching_chat`) | `chat` ve `reveal`: eşleştiklerine yazmak | 99 ₺ · $3.99 | 990 ₺ · $39.90 |
| Seni Beğenenler (`matching_admirers`) | `admirers`: seni beğenenlerin listesi, beğenerek anında eşleşme | 79 ₺ · $2.99 | 790 ₺ · $29.90 |
| Sınırsız Beğeni (`matching_unlimited`) | `unlimited`: sınırsız beğeni, geri al, filtreler | 79 ₺ · $2.99 | 790 ₺ · $29.90 |
| Süper Beğeni (`matching_super`) | `super`: günde 5 süper beğeni | 49 ₺ · $1.99 | 490 ₺ · $19.90 |
| Öne Çık (`matching_boost`) | `boost`: günde bir kez 30 dakika destelerin başında | 69 ₺ · $2.49 | 690 ₺ · $24.90 |
| Ekip Arkadaşı (`matching_teammates`) | `teammates`: ekip arkadaşı bölümüne giriş (öneriler, istekler, ekibim), istek göndermek ve kabul etmek, ekip arkadaşına yazmak (Faz 13). Paketsiz kişi yalnızca kendisini bekleyen istek sayısını görür | 49 ₺ · $1.99 | 490 ₺ · $19.90 |
| Hepsi Bir Arada (`matching_premium`) | Hepsi | 249 ₺ · $9.99 | 2.490 ₺ · $99.90 |

- **Ücretsiz:** eşleşme profili, kaydırma, günde 10 beğeni ve 1 süper beğeni (admin değiştirir), eşleştiğini bilmek. Kiminle eşleştiği gizlidir: Eşleşmelerim'de kilitli, bulanık bir kart, bildirimde kişi adı yoktur. Seni beğenenlerin yalnızca sayısını görür; fotoğraf telefona hiç gelmez.
- **Gizlilik SQL'de korunur:** `reveal` yoksa `matches` satırları okunmaz (RLS), eşleşilen kişinin eşleşme profili ve fotoğrafları görünmez (`private.can_view_match_profile`), `my_matches()` yalnızca kilitli kayıt döner. `match_created` bildirimi kişiyi taşımaz (aktör alıcının kendisidir), push "Yeni bir eşleşmen var!" der.
- **Eşleşme sohbeti:** yazmak `chat` ister (`message_blocker` → `match_chat_locked`); okumak ücretsizdir. Ekip arkadaşları Ekip Arkadaşı paketiyle yazışır; takip mesaj hakkı vermez (§3f). Grup sohbetleri ücretsizdir. Mevcut eşleşme sohbetleri silinmez, paket alınınca devam eder.
- **Eşleşmeyi bitirmek** (iki taraftan biri, platform askısı ya da tüm eşleşme verilerini silme) sohbeti kapatır ve karşılıklı takibi kaldırır (§3f).
- **Platform yöneticisi** (`platform_staff.role = 'admin'`) destek ve deneme için tüm özelliklere paketsiz sahiptir (`private.has_full_access`); durum yanıtında `full_access` döner (kullanıcı kararı, 2026-10-27).
- **Hak sorgusu:** `private.has_matching_feature(uid, feature)`; `matching_premium` her özelliği açar, `matching_chat` `reveal`'ı da açar. Paketler billing'de (`personal_plans`, `user_subscriptions`) tutulur (§7, Kişisel ürünler).
- **Satış:** her paket ayrı, aylık ve yıllık, ön ödemeli, otomatik yenileme yok, kalan sürenin ardına eklenir. Satın alma web'dendir; mobil durumu ve fiyatları gösterir.
- **Tanımlama:** platform yöneticisi bir kullanıcıya gerekçeyle 1–365 gün istediği paketi verebilir; `audit_log`'a yazılır (`personal_plan.granted`).
- **Kullanıcının paketleri (admin):** kullanıcı sayfasında kişinin bütün paket dilimleri (satın alınan ve tanımlanan, süren, sıradaki, biten) görünür. Platform yöneticisi oradan paket tanımlar ya da bir paketi iptal eder: o paketin süren ve sıradaki bütün dilimleri hemen biter (`cancel_reason = 'admin'`); "ödeme iade edildi" seçilirse bu dilimlerin ödenmiş siparişleri `refunded` olur. İade, ödeme sağlayıcısının panelinden ayrıca yapılır. `audit_log`: `personal_plan.canceled`.
- **Ekranlar:** deste, "Seni beğenenler" (`/matching/likes`), Paketler (`/matching/packages`: her paketin durumu; `/matching/packages/{slug}`: özellikler, fiyatlar, web'de satın alma), filtreler. Kilitli bir özelliğe dokununca o paketi ve Hepsi Bir Arada'yı öneren bir pencere açılır; sohbette yazma kutusunun yerinde paket çağrısı görünür.

### Bildirimler
`match_created` (yeni bir eşleşmen var; kişi adı içermez, push dahil, dokununca Eşleşmelerim açılır) ve `match_super_liked` (seni süper beğendi; dokununca deste açılır, o kişi en baştadır). İkisi de tercihlerden kapatılabilir (`match_alerts`). Eşleşme bitince bildirimi silinir; süper beğeni kaydı silinince (eşleşme verilerini silme, hesap silme) `match_super_liked` bildirimi de silinir. Sıradan beğeniler bildirim göndermez (bildirim yağmuru ve "Seni Beğenenler" paketi yüzünden); sayısı destede kalp simgesinde görünür.

### Admin
- **Eşleşme sayfası:** açık profiller (mod ve cinsiyete göre), son 24 saatte beğeni, süper beğeni, geç ve eşleşme, şu an öne çıkanlar, Premium üye sayısı (tanımlananlar ayrı) ve son 30 günün geliri.
- **İnceleme:** şikayet edilen eşleşme profilleri ve fotoğrafları. Fotoğraf kaldırma, eşleşme profilini kapatma (süreli ya da kalıcı). Hepsi `audit_log`'a yazılır (`match_profile.suspended`, `match_photo.removed`).
- **Ayarlar:** günlük ücretsiz beğeni, süper beğeni (ücretsiz ve Premium), öne çıkma süresi; Premium adı, fiyatları ve satış durumu; Premium tanımlama. Hepsi `audit_log`'a yazılır.

### Veri ve erişim
| Tablo | Okuma | Yazma |
|---|---|---|
| `match_profiles` | Kendisi, eşleştikleri, destesinde olanlar, platform ekibi (`private.can_view_match_profile`) | Kendisi (RLS, 18+ trigger); askı yalnızca C# (admin) |
| `match_photos`, Storage `match-photos` | Aynı kural; fotoğraflar gizli kovadadır, adresler imzalı ve 1 saatliktir | Kendisi (en fazla 6, kendi klasörü) |
| `match_swipes` | Kendisinin | Yalnızca C# (günlük haklar); süper beğeni trigger ile `match_super_liked` yazar |
| `match_boosts` | Kendisinin | Yalnızca C# (Premium, günde bir) |
| `matches` | İki taraf | Yalnızca C#; oluşunca trigger iki tarafa `match_created` yazar |
| `matching_settings` | Herkes (giriş yapmış) | Yalnızca C# (admin) |

- Okuma RPC'leri: `public.match_deck(…)`, `public.my_matches()`, `public.match_status()` (Premium, kalan beğeni ve süper beğeni, öne çıkma, mod başına bekleyen beğeni sayısı), `public.match_admirers(deck)` (Premium), `public.match_likes_left()`; kapak değişimi `public.swap_match_photos(first, second)`.
- **Tüm verileri sil** (`DELETE /me/matching`): profil, fotoğraflar (depo dahil), öne çıkmalar ve kişinin verdiği ve aldığı beğeniler silinir; satın alınan Premium süresi billing'de kalır. Eşleşmeleri biter; yalnızca "bitti" kaydı kalır ki açılmış sohbetler kapalı kalsın. Hesap kalıcı silinince `match-photos/<uid>/` klasörü de temizlenir.
- **Platform askısı:** `suspended_until` (süresiz için sonsuz). Askıdaki profil kimseye görünmez, eşleşmeleri biter; hesabın geri kalanı etkilenmez.

### C# uç noktaları
| Uç nokta | Açıklama |
|---|---|
| `POST /matching/swipes` | `targetId`, `mode`, `like`, `super`. Kişi destede olmalı; beğeni ve süper beğeni günlük haklara tabi (`match.like_limit`, `match.super_like_limit`; Premium'da beğeni sınırsız). Karşılıklı beğenide eşleşme; yanıt `matched`, `matchId`, `likesLeft` (Premium'da boş), `superLikesLeft` |
| `POST /matching/rewind` | Premium. Son kaydırma bir "geç" ise geri alır; yanıt `targetId`, `mode` (`match.nothing_to_rewind`) |
| `POST /matching/boost` | Premium, günde bir. Yanıt `endsAt` (`match.boost_used`) |
| `DELETE /matching/matches/{id}` | Eşleşmeyi bitir (iki taraf da) |
| `DELETE /me/matching` | Tüm eşleşme verilerini sil |
| `GET /admin/matching/stats` | Sayılar. Rol: `admin`, `moderator`, `support` |
| `POST /admin/matching/profiles/{userId}/suspension`, `DELETE …/suspension` | Profili kapat (`reason`, `until?`) / aç. Rol: `admin`, `moderator` |
| `POST /admin/matching/photos/{id}/removal` | Fotoğrafı kaldır (`reason`). Rol: `admin`, `moderator` |
| `PUT /admin/matching/settings` | `dailyFreeLikes`, `dailyFreeSuperLikes`, `dailyPremiumSuperLikes`, `boostMinutes`. Rol: `admin` |
| `GET /admin/matching/packages` | Her paket: ad, satış durumu, fiyatlar, paketli ve tanımlanan kişi sayısı, son 30 gün geliri. Rol: `admin`, `moderator`, `support` |
| `PUT /admin/matching/packages/{slug}` | Ad, satış durumu, dört fiyat (TRY/USD × aylık/yıllık). Rol: `admin` |
| `POST /admin/matching/packages/grants` | `username`, `slug`, `days` (1–365), `reason`. Rol: `admin` |
| `GET /admin/users/{id}/packages` | Kişinin bütün paket dilimleri (ürün, dönem, tarihler, kaynak: sipariş ya da tanımlama, sipariş durumu, iptal). Rol: `admin`, `moderator`, `support` |
| `POST /admin/users/{id}/packages` | Paket tanımla: `slug`, `days` (1–365), `reason`. Rol: `admin` |
| `POST /admin/users/{id}/packages/{slug}/cancellation` | Paketi iptal et (`reason`, `refunded`): süren ve sıradaki dilimler hemen biter. Rol: `admin` |

### Tablolar (sahip: matching)
`match_profiles`, `match_photos` (Storage `match-photos`), `match_swipes`, `matches`, `matching_settings`, `match_boosts`. Billing tarafında `personal_plans`, `personal_plan_prices`, `user_subscriptions` (§7, Kişisel ürünler).

## 3h. Güvenlik doğrulaması (Faz 15.8)

Kullanıcı isteği (2026-10-27): yabancı numara ve VPN ile konumunu farklı gösteren hesapları önlemek. Konum izni vermeyen uygulamayı kullanamaz. Telefon doğrulaması, bulunduğu ülkenin numarasıyla ve Google/Apple girişinde de zorunludur. Her yeni oturumda ikinci adım doğrulama istenir. Uyuşmazlıkta kademeli yaptırım uygulanır. Modül: **identity**.

### Kullanıcı kararları (2026-10-27)
- Yaptırım **kademeli**: kesin sinyalde otomatik ban, belirsiz sinyalde hesap kısıtlanır ve admin incelemesine düşer.
- SMS sağlayıcısı **Twilio Verify**. İkinci adım: **SMS**, isteğe bağlı olarak **doğrulama uygulaması (TOTP)**.
- Konum **gizlice işlenmez** (KVKK ve mağaza kuralları, ayrıca izin penceresini işletim sistemi gösterir). İzin ekranı amacı tek cümleyle söyler: "Hesap güvenliği ve sahte hesapların önlenmesi". Hangi sinyallerin nasıl karşılaştırıldığı arayüzde anlatılmaz. Aydınlatma metnine konum ve telefon işleme eklenir (admin panelinden yeni `privacy_notice` sürümü).

### Akış
1. Giriş (e-posta, Google, Apple). Oturum henüz doğrulanmamıştır.
2. **Konum:** uygulama konum izni ister. İzin yoksa uygulama açılmaz, ayarlara yönlendiren ekran kalır. İzin varsa sinyaller `POST /security/location` ile gönderilir.
3. **Telefon (bir kez):** numara alanının ülke kodu, sunucunun bildirdiği **izinli ülkeye** kilitlidir (`GET /security/status` → `allowedCountry`). SMS kodu Twilio Verify ile gider, `POST /security/phone/verify` ile doğrulanır. Bir numara tek hesapta olabilir.
4. **İkinci adım (her yeni oturumda):** kayıtlı numaraya SMS kodu ya da kuruluysa doğrulama uygulamasının kodu. Telefonun doğrulandığı oturum ayrıca ikinci adım istemez.
5. Oturum doğrulanınca istemci token'ını yeniler (`refreshSession`). Ardından KVKK onayları, onboarding ve uygulama gelir.
6. Uygulama her açılışta ve öne gelişte, son kontrolün üzerinden 30 dakika geçtiyse konumu yeniden gönderir. Sunucu son **24 saatte** konum kontrolü olmayan oturumu doğrulanmamış sayar.

### Uygulama
- `identity` paketi: `SecurityScreen` (`/security`) sunucunun bildirdiği adımı gösterir. `SecurityHeartbeat` açılışta ve öne gelişte (30 dakikada bir) konumu sessizce yeniden gönderir.
- Gate yalnızca adım `done` olunca KVKK ve profil verisini ister, çünkü öncesindeki token bunları okuyamaz. Sunucu oturumu doğrulanmış saydığı halde elde hâlâ `unverified` token varsa oturum yenilenir.
- Push cihaz kaydı, token rolü (`sessionRoleProvider`, core) `authenticated` olunca yapılır.
- Android: `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION` izinleri ve SIM ülkesi için `grupx/device` kanalı. iOS: `NSLocationWhenInUseUsageDescription`.
- Admin paneli aynı `SecurityScreen` ve `SecurityHeartbeat`'i kullanır. Personel rolü ancak oturum doğrulanınca okunur. Panelin "Güvenlik" sayfası `/security-reviews` yolundadır (`/security` doğrulama adımıdır).

### Sunucu tarafı zorlama (atlanamaz kısım)
- **Custom access token hook** (`private.custom_access_token_hook`): Supabase Auth her token üretişinde (giriş ve saatlik yenileme) çağırır. Zorlama açıksa ve oturum doğrulanmamışsa token'ın `role` claim'i `authenticated` yerine **`unverified`** olur.
- Doğrulanmış oturum şunların hepsini ister:
  - `verified_sessions` içinde token'ın `session_id` değeri,
  - doğrulanmış telefon,
  - `user_security.state = 'ok'`,
  - son 24 saatte konum kontrolü.
- `unverified` rolü Postgres'te yalnızca `legal_documents` okuyabilir. Diğer tüm RLS politikaları `authenticated` içindir, `SECURITY DEFINER` fonksiyonlar da yalnızca `authenticated`'e açıktır. Bu yüzden değiştirilmiş bir istemci bile veri okuyamaz, yazamaz, Storage ve Realtime'a erişemez.
- C# API'nin varsayılan yetki politikası `role = authenticated` ister. Yalnızca `/security/*`, `GET /account` ve `/me` uçları `unverified` rolünü de kabul eder.
- Yaptırım ve kısıtlama en geç bir token yenilemesinde (≤ 1 saat) etkili olur. Ban ise mevcut askı akışıyla oturumları hemen siler.
- Zorlama `security_settings.enforce` ile açılıp kapanır. Varsayılan **kapalı**: Twilio anahtarları gelene kadar kimse dışarıda kalmasın diye. Yalnızca `admin` değiştirir, işlem `audit_log`'a yazılır. API, SMS sağlayıcısı yapılandırılmamışsa zorlamayı açtırmaz (`security.sms_not_configured`). Yerelde Development ortamında sahte gönderici kodu API günlüğüne yazar.
- Platform ekibi de aynı akıştan geçer. Admin paneli aynı ekranları kullanır.

### Sinyaller ve karar
İstemci şunları gönderir:
- GPS koordinatı ve doğruluğu, sahte konum bayrağı (`isMocked`; Android ve iOS 15+),
- cihazın VPN bağlantısı bildirimi (Android'de etkin ağın `TRANSPORT_VPN` özelliği, diğerlerinde `connectivity_plus`),
- **yüklü VPN uygulamaları** (yalnızca Android, en çok 20 paket adı): `android.net.VpnService` servisini sunan uygulamalar. Manifest'te `<queries>` ile yalnızca bu servis sorgulanır; bütün uygulamaları tarama izni (`QUERY_ALL_PACKAGES`) kullanılmaz (Google Play kuralı),
- SIM ülkesi (yalnızca Android),
- platform.

Sunucu şunları kendisi bulur:
- koordinatın ülkesi, gömülü Natural Earth ülke sınırlarıyla (istemcinin söylediği ülke kullanılmaz),
- IP ülkesi (`Geo`, §7 Pazar).

Kesin koordinat **saklanmaz**, yalnızca türetilen ülkeler ve bayraklar saklanır.

| Sinyal | Sınıf | Sonuç |
|---|---|---|
| Sahte konum (`isMocked`) | Kesin | Otomatik ban |
| Telefon doğrulamasında izinli ülke dışından numara (arayüz bunu engeller, ancak değiştirilmiş istemci gönderir) | Kesin | Otomatik ban |
| Numara `phone_bans` listesinde | Kesin | Kod gönderilmez, ban |
| GPS ülkesi ≠ IP ülkesi | Belirsiz | Kısıtla + inceleme |
| VPN bildirimi | Belirsiz | Kısıtla + inceleme |
| SIM ülkesi ≠ GPS ülkesi | Belirsiz | Kısıtla + inceleme |
| Kayıtlı numaranın ülkesi ≠ GPS ülkesi (sonraki girişler) | Belirsiz | Kısıtla + inceleme |
| Yüklü VPN uygulaması (çalışmıyor) | Bilgi | Kullanıcıya uyarı mesajı, kısıtlama yok |
| GPS ülkesi bulunamadı (deniz, sınır yakını) | — | IP ülkesi kullanılır, işlem yok |

**Tespit anahtarları** (kullanıcı isteği, 2026-10-27; `security_settings`, yalnızca `admin`, varsayılan açık):
- `detect_vpn`: VPN bildirimi ve GPS/IP uyuşmazlığı sinyal üretir.
- `warn_installed_vpn`: yüklü VPN uygulaması uyarı üretir.
- `detect_phone_mismatch`: SIM ve kayıtlı numara uyuşmazlığı sinyal üretir.

Kesin sinyaller ve telefonun izinli ülkeye kilidi anahtarlardan etkilenmez. Kapalı bir anahtarın sinyali yine de kontrol kaydına yazılır (`signals` dışında, ham bayrak olarak), ancak karar üretmez.

**Uyarı:** konum kontrolünün yanıtı `warnings` listesi taşır (`vpn_installed`). Uygulama bunu oturum başına bir kez iletişim kutusu olarak gösterir: "Cihazınızda VPN uygulaması tespit edilmiştir. Lütfen bulunduğunuz ülkenin kurallarına uyum sağlayarak güvenli giriş yapın."

**Bilgisayar ve iPhone:** tarayıcı bir web sayfasına yüklü uygulamaları göstermez ve çalışan VPN'i doğrudan bildirmez. Web'de yalnızca IP ülkesi ile tarayıcı konumunun ülkesi karşılaştırılır. iOS yüklü uygulama listesi vermez.

- **İzinli ülke:** GPS ülkesi. Bulunamazsa IP ülkesidir.
- **Ban:** mevcut askı akışıyla (`account_status` + Supabase Auth ban) kalıcı uygulanır. Gerekçe kodu `security.*`, aktör `system`. Numara `phone_bans`'a eklenir.
- **Kısıtlama:** `user_security.state = 'restricted'` olur ve bir `security_reviews` kaydı açılır. Kullanıcı uyarı ekranı görür (kullanıcı kararı, 2026-10-27): "Konumunuz, kullandığınız telefon ve VPN tespit edilmiştir. Lütfen bulunduğunuz ülkenin kurallarına uyum sağlayarak güvenli giriş yapın." Hangi sinyalin tetiklendiği tek tek söylenmez. Konum adımı reddedilirse aynı uyarı o ekranda gösterilir; ekran hiçbir durumda boş kalmaz.
- **Admin incelemesi:** "Onayla" seçeneği kısıtlamayı kaldırır. Admin isterse `exempt_until` verir (en çok 90 gün; ör. yurt dışında yaşayan veya seyahatteki kullanıcı); bu süre boyunca belirsiz sinyaller kısıtlamaz. "Banla" seçeneği ban uygular. Her karar `audit_log`'a yazılır.
- Otomatik karara itiraz (KVKK m.11/g): kullanıcı destekten yazar, admin incelemesi itiraz yoludur. Otomatik banı yalnızca platform ekibi kaldırır.
- **Bilinen sınırlar:**
  - GPS ve SIM, köklü (root) cihazlarda taklit edilebilir. Değiştirilmemiş uygulama kanıtı (Play Integrity, App Attest) mağaza yayını gerektirir, Faz 17'ye bırakılır.
  - Web'de tarayıcı konumu masaüstünde IP'den türetilebilir. Web'de SIM ve VPN sinyali yoktur.
  - iOS SIM ülkesi vermez.

### Telefon
- Numara `PhoneNumbers` (libphonenumber) ile E.164'e çevrilir. Ülkesi ve türü (yalnızca `MOBILE` ya da `FIXED_LINE_OR_MOBILE`) sunucuda belirlenir.
- Twilio Lookup açıksa (`Security:Twilio:LookupLineType`), sanal ve VoIP numaralar reddedilir.
- SMS sınırları (`sms_sends`): kullanıcı başına saatte 5, günde 10; numara başına saatte 5. Doğrulama denemesini Twilio Verify sınırlar (kod başına 5). Uçlarda `Sensitive` rate limit vardır.
- TOTP: RFC 6238, SHA-1, 30 sn, 6 hane, ±1 adım. Gizli anahtar `totp_factors`'tadır (yalnızca service role). Aynı adım iki kez kullanılamaz.

### İnceleme hesabı muafiyeti (Faz 17a, kullanıcı kararı 2026-10-27)
- Mağaza inceleme ekipleri (Google Play) Türkiye konumu ve Türk numarası olmadan giriş yapamaz. Bu yüzden belirli hesaplar **kalıcı olarak** güvenlik doğrulamasından muaf tutulabilir: `user_security.review_exempt`.
- Muaf hesap için:
  - konum, telefon ve ikinci adım istenmez,
  - oturum doğrulanmış sayılır (`private.is_session_verified` ve token hook),
  - konum kontrolü gelirse kaydedilir, ama ban ya da kısıtlama üretmez (emülatörler sahte konum bildirir).
- Muafiyet yalnızca bu üçünü kapsar. Askıya alma, 18+ sınırı, KVKK onayları ve diğer kurallar aynen geçerlidir.
- Yalnızca platform yöneticisi (`admin`) açıp kapatır: `PUT /admin/users/{id}/security/review-exempt` (`exempt`, `note` zorunlu). İşlem `audit_log`'a yazılır (`security.review_exempt_changed`). Panelin kullanıcı sayfasında muaf hesap açıkça işaretlidir.
- Kural: muafiyet yalnızca inceleme için açılmış, gerçek kişiye ait olmayan hesaba verilir. Şifresi yalnızca mağaza konsoluna girilir.

### Parmak izi (passkey) ve Authenticator önerisi (15.8d, kullanıcı kararı 2026-10-27)
- **Passkey (WebAuthn)**, ikinci adım yöntemlerinden biridir:
  - Kullanıcı cihazın parmak izi, yüz tanıma ya da ekran kilidiyle (`userVerification: required`) imza atar; sunucu imzayı doğrular.
  - Anahtar cihazdan çıkmaz, kopyalanamaz. Değiştirilmiş bir istemci doğrulamayı atlayamaz.
  - Web'de Windows Hello, Mac Touch ID ve telefon tarayıcısı ile çalışır. Mobil uygulamada sonraki aşamada eklenir.
- Sunucu: `Fido2` (fido2-net-lib). Yapılandırma:
  - `Security:Passkeys:RelyingPartyId`: yerelde `localhost`, yayında alan adı.
  - `Security:Passkeys:Origins`: uygulama ve panel adresleri.
  - Tarayıcı WebAuthn'u yalnızca `https` ya da `localhost` üzerinde açar.
- Kayıt: doğrulanmış oturumda (zorlama kapalıysa her oturumda). Kullanıcı başına en çok 10 passkey. Tasdik (attestation) istenmez (`none`); aynı anahtar iki kez kaydedilmez.
- Meydan okuma (challenge): `webauthn_challenges`'ta kullanıcı ve amaç başına tek, 5 dakika geçerli, tek kullanımlık.
- İkinci adımda yöntem sırası: passkey > doğrulama uygulaması > SMS. İmza sayacı geriye giderse reddedilir (kopyalanmış anahtar belirtisi).
- **Authenticator önerisi:** telefon doğrulandıktan hemen sonra kullanıcıya "Parmak izi ekle / Google Authenticator ekle / Şimdi değil" önerisi gösterilir. Kurulan yöntem sonraki girişlerde varsayılan olur, SMS yedek kalır.

### Veri ve erişim
- Tabloların hepsinde RLS açık, istemciye politika **yok**. Okuma ve yazma C# (service role) ve hook üzerinden yapılır. Platform ekibi panelden C# ile okur.
- `location_checks` ve `sms_sends` **90 gün** saklanır, `AccountPurgeService` siler. `phone_bans` dolandırıcılık önleme amacıyla süresiz tutulur.
- Hesap silinince `phone_verifications`, `user_security`, `verified_sessions`, `totp_factors`, `passkeys` ve `webauthn_challenges` cascade ile silinir. `phone_bans` kalır. Süresi geçmiş meydan okumaları `AccountPurgeService` siler.
- Audit: `security.phone_verified`, `security.totp_enabled`, `security.totp_disabled`, `security.passkey_added`, `security.passkey_removed`, `security.restricted`, `security.banned`, `security.review_approved`, `security.review_banned`, `security.settings_changed`.

### Uç noktalar
| Uç nokta | Açıklama |
|---|---|
| `GET /security/status` | Zorlama açık mı, oturum doğrulandı mı, sıradaki adım (`location` / `phone` / `second_factor` / `restricted` / `done`), izinli ülke, kayıtlı numaranın maskesi, TOTP kurulu mu. `unverified` da çağırır |
| `POST /security/location` | Sinyaller (`latitude`, `longitude`, `accuracy`, `isMocked`, `vpn`, `simCountry?`, `platform`). Kararı uygular |
| `POST /security/phone/start` | `phone`: ülke ve tür kontrolü, SMS gönderimi |
| `POST /security/phone/verify` | `phone`, `code`: numarayı kaydeder, oturumu doğrular |
| `POST /security/second-factor/start` | Kayıtlı numaraya SMS |
| `POST /security/second-factor/verify` | `method` (`sms` / `totp`), `code`: oturumu doğrular |
| `POST /security/totp` | Doğrulanmış oturumda kurulum başlatır: gizli anahtar ve `otpauth://` adresi |
| `POST /security/totp/confirm` | `code`: kurulumu tamamlar |
| `DELETE /security/totp` | Kaldırır |
| `POST /security/passkeys/options` | Kayıt seçenekleri (WebAuthn JSON). Doğrulanmış oturum |
| `POST /security/passkeys` | `name?`, `response` (tarayıcının yanıtı): passkey'i kaydeder |
| `GET /security/passkeys`, `DELETE /security/passkeys/{id}` | Kendi passkey'leri; silme doğrulanmış oturumda |
| `POST /security/second-factor/passkey/options` | Giriş için imza seçenekleri |
| `POST /security/second-factor/passkey` | Tarayıcının imzası: oturumu doğrular |
| `GET /admin/security/settings`, `PUT /admin/security/settings` | Zorlama ve tespit anahtarları (`enforce`, `detectVpn`, `warnInstalledVpn`, `detectPhoneMismatch`; PUT'ta yalnızca gönderilenler değişir), sağlayıcı durumu. Her değişiklik `security.settings_changed`. Rol: `admin` |
| `GET /admin/security/reviews?status=` | İnceleme listesi (sinyal özeti). Rol: `admin`, `moderator` |
| `POST /admin/security/reviews/{id}/approval` | `exemptDays?` (0–90), `note`. Rol: `admin`, `moderator` |
| `POST /admin/security/reviews/{id}/ban` | `note`. Rol: `admin`, `moderator` |
| `GET /admin/users/{id}/security` | Kullanıcının durumu, numara maskesi, son kontroller, inceleme muafiyeti. Rol: `admin`, `moderator`, `support` |
| `PUT /admin/users/{id}/security/review-exempt` | `exempt`, `note`: inceleme hesabı muafiyeti. Rol: `admin` |

## 4. Flutter

### Klasörler
```
app/
  pubspec.yaml                 workspace kökü + melos yapılandırması
  analysis_options.yaml        ortak lint kuralları
  tool/setup_platforms.sh      platform klasörlerini (android, ios, web) üretir
  apps/social_app              kullanıcı uygulaması (iOS, Android, Web)
  apps/admin_panel             platform ekibi paneli (iOS, Android, Web)
  packages/core                Result<T>, Failure, ortak altyapı
  packages/design_system       tokenlar, tema, ortak bileşenler, font
  packages/features/<modül>    feature paketleri: identity, profile, groups, billing, support, feed, notifications, events, live, moderation, messaging, admin
```

- `core` ayrıca Supabase istemcisini (`supabaseClientProvider`), C# API istemcisini (`ApiClient`: Supabase oturum token'ını ekler, ProblemDetails'i `Failure`'a çevirir), `AppConfig`'i (`--dart-define`: `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `API_URL`), ortak kategorileri (`categoriesProvider`), görsel seçimini (`ImageUpload`, `pickGalleryImage`; ekranlar testte değiştirilebilen `PickImage` alır) ve tarih, para (`formatMoney`: `249 ₺`, `$9.99`) ve sayı biçimlendirmesini sağlar. `ApiClient`, ProblemDetails içeren 503 yanıtlarının başlığını da gösterir (ör. ödeme geçici olarak kapalı).
- Uygulamanın router'ı feature paketlerinin provider'larını birleştirir (oturum, onay, profil durumu). Feature'lar birbirini bilmez; bir feature'ın başka bir feature'ın ekranında yer alması gerekiyorsa uygulama bunu bağlar (ör. profil sayfasındaki "Gruplar" bölümü `ProfileScreen.sections` ile, grup ekranından profile geçiş `onOpenProfile` ile, grup sayfasındaki paket kartı `GroupScreen.sections` ile verilir; paket ve ödeme rotaları `/g/<handle>/plan` ve `/g/<handle>/plan/checkout` grubu uygulamada çözer ve `billing` ekranlarına kimliğini verir; canlı yayın kartı `GroupScreen.sections`, ana sayfadaki "Şimdi canlı" ve "Yaklaşanlar" bölümleri `HomeFeedScreen.top` (uygulamanın `HomePage`'i), `live_scheduled` ve `live_started` bildirimleri ile sesli uyarı şeridi `NotificationLinks.openLive` ve `LiveNotificationAlerts.openLive` ile bağlanır, yayın odası `/live/<id>` rotasındadır; mesaj butonu profilde `ProfileScreen.visitorActions`, Kaydedilenler ve Ekip arkadaşı bul kısayolları kendi profilinde `ProfileScreen.ownActions`, "Grup sohbeti" `GroupScreen.sections` ile verilir, sohbetler `/messages` ve `/messages/<id>` rotalarındadır).
- Sosyal uygulamanın sayfaları `HomeShell` içindedir (tam ekran hikâye, hikâye ekleme ve yayın odası hariç): telefonda ana hedeflerde (Bugün, Gruplar, Takvim, Ben) yüzen dok ve ortada Paylaş, geniş ekranda her sayfada etiketli yan menü (docs/DESIGN.md §7). Web'de Flutter'ın varsayılan hash URL stratejisi kullanılır (`/#/g/<handle>`).
- OAuth ve e-posta bağlantıları mobilde `com.grupx.app://auth-callback` deep link'ine döner. Şema paket adıyla aynıdır; eski `com.grupx.social` şeması, aynı telefonda kalan eski `com.grupx.social_app` uygulaması da sahiplendiği için girişi ona gönderiyordu (2026-10-28).

Platform klasörleri (`android/`, `ios/`, `web/`) ilk kurulumda `tool/setup_platforms.sh` ile bir kez üretilir ve repoya alınır. Sonraki platform ayarları (izinler, ikonlar, bundle id) bu klasörlerde yapılır.

### Feature paketi yapısı
```
lib/src/data/          Supabase / API erişimi, DTO'lar, repository implementasyonu
lib/src/domain/        entity'ler, repository arayüzleri
lib/src/presentation/  ekranlar, widget'lar, Riverpod provider'ları
```

### Kurallar
- Repository'ler `Result<T>` döner (`package:core`). Repository dışına exception sızmaz.
- Supabase Dart istemcisinde `order()` varsayılan olarak **azalan** sıralar; sıralama yönü her zaman açıkça yazılır.
- Ekranlarda ham hata metni gösterilmez. `Failure` türü ekranda Türkçe, kullanıcı dostu bir mesaja çevrilir.
- Durum yönetimi Riverpod 3, yönlendirme go_router ile yapılır.
- Uygulama kodunda doğrudan renk, boşluk, yarıçap veya yazı boyutu yazılmaz. Tüm değerler `design_system` tokenlarından gelir.
- Arayüz metinleri Türkçedir. Kod, değişken ve dosya adları İngilizcedir.

## 5. Backend (C#)

### Klasörler
```
backend/
  GrupX.slnx
  Directory.Build.props        net10.0, nullable, uyarılar hata
  Directory.Packages.props     merkezi paket sürümleri
  src/GrupX.Api                giriş noktası: auth, ProblemDetails, rate limit, endpoint kaydı
  src/GrupX.SharedKernel       Result, Error ve modüller arası ortak tipler
  src/Modules/GrupX.Modules.<Ad>            modül implementasyonu (internal)
  src/Modules/GrupX.Modules.<Ad>.Contracts  modülün dışa açık sözleşmeleri
  src/GrupX.SharedKernel       ayrıca: audit log yazıcısı, ActingUser (trigger'lara işlemi yapanı bildirir), ISupabaseStorage, RateLimitPolicies
  tests/GrupX.Api.Tests        entegrasyon ve birim testleri
```

### Kurallar
- Beklenen hatalar `Result` / `Result<T>` ile döner. HTTP katmanında `ToHttpResult()` ile RFC 9457 ProblemDetails'e çevrilir. Türler: doğrulama 400, yetkisiz 401, yasak 403, bulunamadı 404, çakışma 409, kural ihlali 422, bağımlılık kullanılamıyor (ör. ödeme sağlayıcısı) 503.
- Exception yalnızca beklenmeyen durumlar içindir. Bunları global exception handler yakalar ve 500 ProblemDetails döner. İç ayrıntı istemciye sızmaz.
- Kimlik doğrulama Supabase JWT ile yapılır. `Supabase:Url` yapılandırmasından issuer `{Url}/auth/v1` türetilir, audience `authenticated` olur.
  - `Supabase:JwtSecret` tanımlıysa HS256 simetrik anahtarla doğrulanır (yerel geliştirme, eski projeler).
  - Tanımlı değilse imza anahtarları issuer'ın OpenID metadata/JWKS uç noktasından alınır (asimetrik anahtarlar). **Varsayılan yol budur.** Yerel Supabase CLI (2.121+) de ES256 kullanır, bu yüzden yerelde `JwtSecret` gerekmez.
- Varsayılan yetkilendirme politikası kimliği doğrulanmış kullanıcı ister. Anonim uç noktalar `AllowAnonymous` ile açıkça işaretlenir.
- Faz 0 uç noktaları: `GET /health` (anonim, rate limit dışı) ve `GET /me` (JWT'deki kullanıcı kimliğini döner, auth zincirini uçtan uca doğrular).
- Rate limit: kullanıcı kimliğine (yoksa IP'ye) göre bölümlenmiş global sabit pencere limiti uygulanır. Hassas uç noktalara ayrıca daha sıkı politika eklenir (`RateLimitPolicies.Sensitive`: kullanıcı başına 10 dakikada 10 istek; sipariş oluşturma). Sağlayıcı bildirimleri (imzalı) rate limit dışıdır.
- İstemci IP'si: API ters proxy arkasındaysa yalnızca `ReverseProxy:KnownProxies` / `ReverseProxy:KnownNetworks` listesindeki proxy'lerin `X-Forwarded-For` başlığı kabul edilir; liste boşsa başlık yok sayılır.
- Gizli değerler (service role, JWT secret, PayTR, iyzico, LiveKit) yalnızca ortam değişkeni veya user-secrets ile verilir, repoya girmez.
- CORS: yalnızca `Cors:AllowedOrigins` listesindeki web kökenlerine izin verilir (yerelde `http://localhost:3000` sosyal uygulama, `http://localhost:3001` admin paneli).
- `dotnet build` hatasız ve uyarısız olmalıdır (`TreatWarningsAsErrors`).

## 6. Veritabanı (Supabase)

### Migration
- Veritabanı **yalnızca** `supabase/migrations/` altındaki numaralı SQL dosyalarıyla değişir (`0001_foundation.sql`, `0002_...`). Dashboard'dan elle değişiklik yapılmaz.
- Uygulanmış bir migration değiştirilmez. Düzeltme yeni migration ile yapılır.

### Güvenlik
- Her tabloda RLS açıktır. Politika yoksa erişim yoktur (varsayılan reddet).
- `anon` ve `authenticated` rollerine yalnızca gereken tablo yetkileri verilir. Yazma yetkisi gerekmeyen tablolarda `insert/update/delete` yetkisi geri alınır.
- `SECURITY DEFINER` fonksiyonlar API'ye açık olmayan `private` şemasında durur, `search_path = ''` ile tanımlanır ve tam nitelikli isimler kullanır.
- Yetki kontrolü hem C#'ta hem SQL'de yapılır. Grup yetkileri için `private.has_group_permission(group_id, permission)` kullanılır (§3b).
- **Rütbe kuralı:** Kimse kendisiyle eşit ya da daha yüksek rütbeli birine yaptırım uygulayamaz. Grup sahibi banlanamaz. Kural hem C#'ta hem SQL'de uygulanır.
- Her yeni tablo için yetkisiz erişimi engellediğini kanıtlayan pgTAP testi `supabase/tests/database/` altına yazılır. Ayrıca `public` şemasındaki tüm tabloların RLS'inin açık olduğunu genel bir test doğrular.

### Audit log
- `public.audit_log` değiştirilemezdir. `UPDATE`, `DELETE` ve `TRUNCATE` trigger ile her rol için (service role ve postgres dahil) engellenir.
- Kayıtları yalnızca backend (service role) ekler. İstemci rolleri yazamaz.
- Okuma yetkisi yalnızca platform ekibi (`platform_staff`) üyelerindedir.
- Rol, yaptırım, abonelik ve admin işlemleri audit log'a yazılır.
- KVKK: Audit log kişisel veri içermez, yalnızca kullanıcı kimliği (uuid) tutar. Hesap silindiğinde kimlik uuid olarak kalır ama artık hiçbir profile bağlanamaz. `ip` alanı yalnızca güvenlik amaçlıdır.

### Platform ekibi
- `public.platform_staff`: admin panelini kullanabilen kullanıcılar ve rolleri (`admin`, `moderator`, `support`).
- Kullanıcı yalnızca kendi kaydını okuyabilir (panel girişinde rol kontrolü için). Kayıtları yalnızca backend yönetir.
- Kontrol fonksiyonu: `private.is_platform_staff(roles text[] default null)`.

## 7. Abonelik ve ödeme (Faz 3)

Ürün kararları (2026-10-19): dört paket, ön ödemeli dönem (otomatik yenileme yok), yurt içi PayTR ve TL, yurt dışı iyzico ve USD, limit aşımında mevcut üyeler kalır ama yenisi alınmaz, yükseltmede kalan süre yeni pakete aktarılır.

### Paketler
`plans` tablosunda her paketin adı, kademesi (`tier`, yükseltme ve alt pakete geçişi belirler), limitleri ve satış durumu (`is_active`) bulunur. Fiyatlar `plan_prices` tablosundadır: her ücretli paket için TRY ve USD, aylık ve yıllık. Tutarlar kuruş veya sent cinsinden tamsayıdır.

| Paket (`slug`) | Kademe | Üye | Organizasyon / ay | Yayın dakikası / ay | Aylık | Yıllık |
|---|---|---|---|---|---|---|
| Ücretsiz (`free`) | 0 | 50 | 2 | 60 | — | — |
| Başlangıç (`starter`) | 1 | 250 | 10 | 600 | 249 ₺ · $9.99 | 2.490 ₺ · $99.90 |
| Pro (`pro`) | 2 | 1.000 | 40 | 3.000 | 699 ₺ · $24.99 | 6.990 ₺ · $249.90 |
| Topluluk (`community`) | 3 | 10.000 | 200 | 20.000 | 1.999 ₺ · $69.99 | 19.990 ₺ · $699.90 |

- Yıllık fiyat, aylık fiyatın 10 katıdır (2 ay bedava). Bu yalnızca başlangıç değeridir; fiyatlar admin panelinden ayrı ayrı değiştirilir.
- Aboneliği olmayan grup **Ücretsiz** paketi kullanır. Ücretsiz paket satın alınamaz ve fiyatı yoktur.
- Admin; paketin adını, limitlerini, fiyatlarını ve satış durumunu değiştirir (`plan.updated`). **Limit değişikliği** o paketteki tüm gruplara hemen uygulanır. **Fiyat değişikliği** yalnızca yeni siparişleri etkiler. Satıştan kaldırılan paket yeni siparişe kapanır; o paketteki abonelikler süresi bitene kadar devam eder. Yeni paket migration ile eklenir.

### Pazar: ülke, sağlayıcı ve para birimi
Pazar, isteğin geldiği IP'nin ülkesine göre **sunucuda** belirlenir:

| Ülke | Sağlayıcı | Para birimi |
|---|---|---|
| Türkiye (`TR`) | PayTR (iFrame API) | TRY |
| Diğer | iyzico (Checkout Form) | USD |

- Ülke şu sırayla bulunur:
  1. `Geo:CountryHeader` tanımlıysa ve istekte varsa o başlık. Yalnızca API, başlığı kendisi ekleyen bir proxy'nin arkasındaysa tanımlanır (ör. Cloudflare `CF-IPCountry`).
  2. `Geo:DatabasePath` ile verilen MaxMind DB biçimli ülke veritabanı (DB-IP Lite veya GeoLite2 Country). Veritabanı dosyası repoya girmez, ortama kurulur ve aylık güncellenir.
  3. Bulunamazsa `Geo:FallbackCountry` (varsayılan `TR`). Yerelde istek `127.0.0.1`'den geldiği için bu değer kullanılır; iyzico akışını yerelde denemek için `DE` gibi bir değer verilir.
- İstemci IP'si `HttpContext.Connection.RemoteIpAddress`'tir. API ters proxy arkasındaysa yalnızca `ReverseProxy:KnownProxies` ve `ReverseProxy:KnownNetworks` listesindeki proxy'lerin `X-Forwarded-For` başlığına güvenilir. Liste boşsa başlık yok sayılır.
- Pazar istemciden alınmaz. İstemci yalnızca ekranda gördüğü para birimini siparişe yazar. Sunucunun belirlediği pazar bundan farklıysa sipariş reddedilir (`billing.market_changed`, 409) ve ekran fiyatları yeniden yükler.
- VPN ile pazar değiştirmek mümkündür. Bu bir güvenlik açığı değildir: iki sağlayıcı da gerçek ödeme alır, tutar sunucudaki fiyat listesinden gelir.

### Abonelik modeli: ön ödemeli dönem
- Kart saklanmaz, otomatik yenileme yoktur. Aylık (1 takvim ayı) ya da yıllık (1 yıl) dönem tek seferde ödenir.
- `group_subscriptions` her grubun **zaman çizelgesidir**: birbiriyle çakışmayan `[starts_at, ends_at)` dilimleri. Çakışmayı veritabanı exclusion constraint ile engeller.
- Grubun paketi, şu an içinde bulunulan dilimin paketidir. Dilim yoksa paket Ücretsiz'dir. Süre bitince grup kendiliğinden Ücretsiz pakete döner; zamanlanmış bir iş gerekmez.
- Ödeme kesinleştiği anda yeni dilim şöyle yerleştirilir:

| Satın alma | Kural |
|---|---|
| **Yükseltme** (şu anki paketten yüksek kademe; Ücretsiz'den ilk satın alma dahil) | Hemen başlar. Şu anki ve ileri tarihli dilimlerin kalan süresi yeni pakete fiyatla oranlanarak eklenir. Eski dilimler `upgraded` nedeniyle kapatılır. |
| **Yenileme** (aynı kademe) ve **alt pakete geçiş** | Zaman çizelgesinin sonuna eklenir. |

- Aktarılan süre = Σ (dilimin kalan süresi × eski paketin günlük fiyatı ÷ yeni paketin günlük fiyatı). Günlük fiyat, siparişin para birimindeki güncel liste fiyatının dönemin gün sayısına bölümüdür (ay 30, yıl 365 gün). Böylece farklı para birimiyle alınmış dilimler kur gerekmeden aktarılır. Örnek: 10 günü kalan aylık Başlangıç, aylık Pro'ya yükseltilirse 10 × 249 ÷ 699 ≈ 3,6 gün eklenir.
- Zaman çizelgesi bugünden 400 günden ileriye uzanıyorsa yenileme ve alt pakete geçiş alınamaz (`billing.timeline_too_long`). Yükseltme her zaman alınabilir.
- Paket ekranı, satın almadan önce her seçenek için tahmini başlangıç ve bitiş tarihini ve aktarılacak süreyi gösterir. Kesin değerler ödemenin kesinleştiği anda hesaplanır.
- Bitişe 7 gün kala, ileri tarihli dilim yoksa grup sayfasında ve paket ekranında yenileme hatırlatması görünür. E-posta ve push hatırlatması Faz 4'te bildirimlerle gelir.
- Sahiplik devrinde paket grupla birlikte kalır. Grup silinirse kalan süre iade edilmez, siparişler muhasebe kaydı olarak kalır.

### Satın alma akışı
1. **Yalnızca web'de** grup sahibi paket ekranını açar (`billing.manage`; yalnızca sahipte olan yetki). `GET /billing/groups/{id}/offer` pazarı, satıştaki paketlerin fiyatlarını ve her seçenek için satın alma türünü ve tahmini tarihleri döner.
2. Sahip fatura bilgilerini girer (ad, soyad, telefon, adres, şehir, ülke) ve Ön Bilgilendirme Formu ile Mesafeli Satış Sözleşmesi'ni onaylar. `POST /billing/groups/{id}/orders` siparişi `pending` olarak açar. Tutarı fiyat listesinden alır, sağlayıcıda ödeme oturumu başlatır ve ödeme sayfasının adresini döner.
3. Tarayıcı sağlayıcının ödeme sayfasına gider. Kart bilgisi GrupX'e hiç gelmez.
4. Ödeme **yalnızca sunucu tarafında** kesinleşir:
   - **PayTR:** Mağaza panelinde tanımlı bildirim adresine (`POST /billing/paytr/notify`) gelen isteğin `hash` değeri doğrulanır: `base64(HMAC-SHA256(merchant_key, merchant_oid + merchant_salt + status + total_amount))`. Yanıt düz metin `OK`'dir; PayTR `OK` alana kadar tekrar dener.
   - **iyzico:** Tarayıcının döndüğü callback (`POST /billing/iyzico/callback`, imzasız) ve mağaza panelinde tanımlı webhook (`POST /billing/iyzico/webhook`, `X-IYZ-SIGNATURE-V3` imzalı) yalnızca tetikleyicidir. Sonuç her zaman sunucunun iyzico'ya kendi anahtarıyla (IYZWSv2) sorduğu ödeme detayından alınır. Ödeme `SUCCESS` ve dolandırıcılık durumu onaylı (`fraudStatus = 1`) değilse sipariş beklemede kalır.
   - Tutar, para birimi ya da sipariş numarası eşleşmezse abonelik açılmaz. Sipariş `failed` (`amount_mismatch`) olur ve audit log'a `billing.payment_mismatch` yazılır.
   - Bildirimler idempotenttir; aynı sipariş ikinci kez işlenmez. `failed` bir sipariş sonradan gelen başarılı bildirimle `paid` olabilir; `paid` bir sipariş geri dönmez.
   - İstemcinin "ödedim" bildirimi hiçbir şeyi değiştirmez.
5. Kullanıcı uygulamaya döner (`/#/g/<handle>/plan?order=<id>`). Ekran sipariş durumunu Supabase'den okuyarak kesinleşmeyi bekler.

- **Mobil uygulama** yalnızca grubun paketini, limitlerini ve dönem sonunu gösterir. Fiyat, satın alma düğmesi ya da web'e yönlendirme göstermez; sebep Apple ve Google'ın uygulama içi ödeme kurallarıdır.
- Sağlayıcının anahtarları yapılandırılmamışsa o pazarda satın alma kapalıdır (`billing.provider_unavailable`, 503).
- Sipariş oluşturma uç noktası kullanıcı başına ayrıca sıkı rate limit altındadır.

### Sipariş durumları
`pending` → `paid` ya da `failed`; `failed` → `paid`; `paid` → `refunded`.

- `refunded` durumuna yalnızca admin geçirir: iade sağlayıcının panelinden yapılır, ardından admin panelinden abonelik "iade edildi" olarak iptal edilir.
- Siparişin tutarı, paketi, dönemi, para birimi, sağlayıcısı ve alıcısı oluştuktan sonra değişmez. Bunu trigger korur.
- Ödenmemiş siparişler `pending` kalır. Admin panelinde bir saatten eski olanlar "yarım kaldı" olarak görünür.

### Limitler
- **Üye limiti:** Üye eklenirken (serbest katılım, davet kabulü, istek onayı) hem C# (`Groups` modülü, `IGroupPlanLimits` sözleşmesiyle) hem `group_members` ekleme trigger'ı (`private.group_plan_limits`) kontrol eder. Grup sahibi grubu oluştururken limite takılmaz. Hata kodu `group.member_limit_reached`'tir.
- **Limit aşımı** (süre bitti, alt pakete geçildi ya da admin limiti düşürdü): kimse gruptan çıkarılmaz. Üye sayısı limitin altına inene kadar yeni üye alınmaz. Sahip ve `members.approve` yetkisi olanlar grup sayfasında uyarı görür.
- Aylık organizasyon (§3d) ve yayın dakikası (§8) limitleri aynı iki katmanlı yöntemle kontrol edilir.

### Hukuki ve KVKK
- `legal_documents` tablosuna `distance_sales` türü eklenir (Ön Bilgilendirme Formu ve Mesafeli Satış Sözleşmesi). Bu metnin `audience` değeri `purchase`'dır: kayıtta istenmez, satın alırken onaylanır. `pending_legal_documents` yalnızca `audience = 'signup'` metinlerini döner. Onaylanan sürüm siparişte saklanır. Metin taslaktır.
- Fatura bilgileri siparişte saklanır. Yasal saklama yükümlülüğü nedeniyle (VUK, 10 yıl) hesap silinince de kalır. Siparişte alıcı, yabancı anahtar olmadan uuid olarak tutulur.
- Aydınlatma metni, ödeme ve fatura amacıyla işlenen bu verileri kapsayacak şekilde hukuki incelemede güncellenmelidir.
- e-Arşiv fatura kesimi v1 kapsamı dışındadır. Muhasebe, siparişleri admin panelinden takip eder.

### Erişim (RLS)
| Tablo | Okuma | Yazma |
|---|---|---|
| `plans`, `plan_prices` | Herkes | Backend, yalnızca platform `admin`'i adına (trigger) |
| `group_subscriptions` | `billing.manage` (sahip) ve platform ekibi | Backend: ödeme kesinleşmesi (sistem) ve admin iptali |
| `billing_orders` | Siparişin alıcısı ve platform ekibi | Backend |

- `public.group_plan(group_id)` RPC'si grubun üyelerine ve platform ekibine grubun güncel paketini, limitlerini, üye sayısını, dönem sonunu ve zaman çizelgesinin sonunu döner.
- Trigger'lar ikinci katmandır: sipariş durum geçişlerini ve değişmez alanları korur. Aboneliği yalnızca ödenmiş ve aynı grup, paket ve döneme ait bir siparişle açtırır. Çakışan dilime izin vermez. Plan ve fiyat değişikliğini yalnızca platform `admin`'i adına kabul eder.

### Audit log
`subscription.activated` (sistem; paket, dönem, sipariş, tutar, aktarılan süre), `subscription.canceled` (admin; neden, iade), `billing.payment_mismatch` (sistem), `plan.updated` (admin). Grup kayıtlarında `group_id` doludur.

### C# uç noktaları (Faz 3)
| Uç nokta | Açıklama |
|---|---|
| `GET /billing/groups/{id}/offer` | Pazar (ülke, sağlayıcı, para birimi), seçenekler (paket × dönem: tutar, tür, tahmini başlangıç ve bitiş, aktarılan süre, alınabilir mi), sözleşme sürümü. `billing.manage` |
| `POST /billing/groups/{id}/orders` | Sipariş ve ödeme oturumu (`planSlug`, `period`, `currency`, `salesTermsVersion`, `billing`). Yanıt: `orderId`, `paymentUrl`. `billing.manage` |
| `GET /billing/me/plans/{slug}/offer` | Kişisel ürün teklifi: pazar, ürün adı, kalan süre (`activeUntil`), dönemler (tutar, tahmini başlangıç ve bitiş), satış açık mı, sözleşme sürümü |
| `POST /billing/me/plans/{slug}/orders` | Kişisel sipariş (`period`, `currency`, `salesTermsVersion`, `billing`). Yanıt: `orderId`, `paymentUrl` |
| `POST /billing/paytr/notify` | PayTR bildirimi (anonim, hash doğrulamalı, yanıt `OK`) |
| `POST /billing/iyzico/callback?order=` | iyzico'dan dönüş (anonim). Sonucu iyzico'dan sorar, uygulamaya 303 ile yönlendirir. |
| `POST /billing/iyzico/webhook` | iyzico bildirimi (anonim, `X-IYZ-SIGNATURE-V3` doğrulamalı) |
| `GET /admin/billing/stats` | Aktif ücretli abonelik, ücretli grup, bu ayın ve son 12 ayın geliri (para birimine göre). Rol: `admin` |
| `GET /admin/billing/orders?q=&status=&provider=&page=` | Siparişler (grup adı veya adresiyle arama). Rol: `admin`, `support` |
| `GET /admin/billing/subscriptions?q=&page=` | Aktif ve ileri tarihli abonelikler. Rol: `admin`, `support` |
| `GET /admin/plans` | Paketler ve fiyatları. Rol: `admin`, `support` |
| `PUT /admin/plans/{slug}` | Paketi güncelleme (ad, limitler, satış durumu, fiyatlar). Rol: `admin` |
| `POST /admin/subscriptions/{id}/cancellation` | Aboneliği iptal (`reason`, `refunded`). Şu anki dilim hemen biter, ileri tarihli dilim başlamaz. `refunded` ise sipariş `refunded` olur. Rol: `admin` |
| `POST /admin/groups/{id}/plan` | Gruba paket tanımlama (`slug`, `days` 1–365, `reason` 3–500). Rol: `admin` |
| `POST /admin/groups/{id}/plan/cancellation` | Grubun bütün paketini iptal (`reason`, `refunded`). Rol: `admin` |
| `GET /admin/billing/providers` | PayTR ve iyzico kurulumu: anahtar var mı, test mi, panele girilecek bildirim adresleri, eksikler. Anahtar döndürmez. Rol: `admin` |
| `POST /admin/billing/providers/{provider}/check` | Anahtarları sağlayıcıya sorar: PayTR'da ödenmeyecek 1 TL'lik test siparişine token, iyzico'da imzalı taksit sorgusu. Para çekilmez. Rol: `admin` |

`GET /admin/groups/{id}` yanıtına grubun güncel paketi ve abonelik geçmişi eklenir. Geçmişteki her dilim satın alındıysa tutarını ve sağlayıcısını, tanımlandıysa tanımlayanı ve gerekçesini, iptal edildiyse iptal gerekçesini taşır.

### Yönetici işlemleri (kullanıcı isteği, 2026-10-28)
- **Paket tanımlama:** Platform yöneticisi, admin panelinde grup sayfasından gruba Ücretsiz dışında herhangi bir paketi istediği gün sayısı kadar (1–365) tanımlar. Açıklama zorunludur. Dilim siparişsiz ve dönemsiz açılır, `granted_by` ve `grant_reason` alanlarına yazılır. Yerleşim satın almayla aynı kurala uyar:
  - Daha yüksek kademe hemen başlar. Kalan süre, aylık TL liste fiyatıyla oranlanarak eklenir ve eski dilimler `upgraded` ile kapanır.
  - Aynı ya da daha düşük kademe zaman çizelgesinin sonuna eklenir.
  - Böylece ödenmiş süre kaybolmaz. Tanımlanan sürenin yükseltmede aktarılan değeri de aylık fiyatla hesaplanır. 400 gün sınırı yönetici için uygulanmaz.
- **Paketi iptal:** Grubun süren ve sıradaki bütün dilimleri hemen biter (`cancel_reason = 'admin'`); grup Ücretsiz pakete döner. "Ödeme iade edildi" seçilirse bu dilimlerin ödenmiş siparişleri `refunded` olur. Tek bir dilim de iptal edilebilir.
- **Gerekçeler veritabanında:** Tanımlama gerekçesi `grant_reason`, her yönetici iptalinin gerekçesi `cancel_note` sütununa yazılır ve sonradan değişmez (trigger). Ayrıca `audit_log`'a da yazılır: `subscription.granted`, `subscription.canceled`, `group_plan.canceled`.
- **Veritabanı koruması:** Siparişsiz dilimi yalnızca platform yöneticisi kendi adına açabilir. Ücretsiz paket tanımlanamaz. İptal gerekçesi yalnızca yönetici iptaliyle birlikte yazılır (`group_subscriptions_guard`, migration `0045`). Grup sahibinin paket ekranında tanımlanan dönem "GrupX tanımladı" olarak görünür.

### Kişisel ürünler (Faz 15.6b)
- Grup paketlerinin yanında kişinin kendisi için aldığı ürünler: `personal_plans` (eşleşme paketleri ve Ekip Arkadaşı, §3g Ücretli paketler), `personal_plan_prices`. Fiyat ve satış durumu yalnızca platform yöneticisince değişir (trigger).
- `billing_orders` bir grup paketini **ya da** bir kişisel ürünü taşır (`personal_plan_slug`; o zaman grup alanları boştur, `billing_orders_product`). Sipariş açılışı aynı tetikleyiciyle korunur: alıcı kendisi, tutar liste fiyatı.
- Ödeme doğrulanınca `user_subscriptions`'a yeni dilim eklenir: kişinin kalan süresinin hemen ardına (aylık bir ay, yıllık bir yıl). Dilimler aynı ürün için çakışamaz (exclusion). Kalan süre 400 günü aşıyorsa yeni süre satılmaz (`billing.too_far_ahead`).
- Yönetici tanımlaması (`grant_reason`, `granted_by`) da aynı tabloya, aynı kuralla eklenir; siparişsiz dilimi yalnızca platform yöneticisi açabilir.
- Hak sorgusu: `private.has_matching_feature(uid, feature)` (herhangi bir eşleşme paketi: `private.has_matching_premium(uid)`), kalan süre `private.personal_plan_until(uid, slug)`.
- Ödeme bildirimi alıcının hesabı kalıcı silindikten sonra gelirse sipariş "ödendi" olur ama süre açılmaz; durum uyarı olarak loglanır (grubu silinmiş grup siparişindeki gibi).
- Ödeme dönüşü: web'de `/#/matching/packages/<slug>?order=<id>`; ekran siparişi bekler ve paket açılınca yenilenir. Mobil uygulama fiyatları ve durumu gösterir, satın almayı web'e bırakır.
- Admin sipariş listesi kişisel siparişleri ürün adı ve alıcıyla gösterir; aylık gelir grafiği hepsini kapsar.

### Yapılandırma
`Billing:AppUrl` (dönüş adresleri için web uygulaması, ör. `https://grupx.app`) ve `Billing:PublicApiUrl` (iyzico callback'i için API'nin dışarıdan erişilen adresi) tanımlanır. Ayrıca:
- `Billing:Paytr:MerchantId`, `MerchantKey`, `MerchantSalt`, `TestMode`
- `Billing:Iyzico:ApiKey`, `SecretKey`, `BaseUrl` (sandbox: `https://sandbox-api.iyzipay.com`)
- `Geo:*`

Anahtarlar yalnızca ortam değişkeni veya user-secrets ile verilir (yerelde `backend/scripts/payment-keys.ps1`). API açılışta her sağlayıcının durumunu ve eksikleri (boş ya da yerel `PublicApiUrl`, test modu) günlüğe yazar. İmzası tutmayan bildirim reddedilir ve uyarı olarak loglanır. Üyelikten canlıya adımlar: `docs/PAYMENTS.md`.

## 7b. Destek ve geri bildirim (Faz 3.5)

Ürün kararları (2026-10-19): her kullanıcı platform ekibine mesaj gönderir. Grup yöneticileri mesajlarına yönettikleri bir grubu ekleyebilir. Renk mesajın türünü gösterir. Platform ekibi yanıt verir ve durumu değiştirir; kullanıcı bunları uygulamada görür. Mesajlara en fazla 3 ekran görüntüsü eklenebilir. Veriler `support` modülünün kendi tablolarında tutulur.

### Mesaj türleri
| Tür (`kind`) | Ad | Renk | İkon | Ne için |
|---|---|---|---|---|
| `problem` | Sorun | Kırmızı (`error`) | uyarı üçgeni | Bir şey bozuk ya da çalışmıyor |
| `request` | Talep | Sarı (`warning`) | yapılacak listesi | Bir işlem isteniyor: hesap, grup, ödeme, veri |
| `suggestion` | İstek | Yeşil (`success`) | ampul | Yeni özellik ya da öneri |

### Durumlar
`open` (Yeni) → `in_progress` (İnceleniyor) → `resolved` (Çözüldü) ya da `closed` (Kapatıldı).

- Durumu yalnızca platform ekibi değiştirir. Ekip ilk yanıtı verdiğinde `open` mesaj kendiliğinden `in_progress` olur.
- Kullanıcı `resolved` bir mesaja yanıt yazarsa mesaj yeniden `open` olur.
- `closed` mesaja yanıt yazılamaz; kullanıcı yeni mesaj açar.
- Durumlar nötr rozetle gösterilir. Kırmızı, sarı ve yeşil yalnızca türü anlatır.

### Veri
| Tablo | İçerik |
|---|---|
| `support_tickets` | Gönderen (`user_id`), isteğe bağlı grup (`group_id`), tür, konu (3–120), durum, son mesaj zamanı ve kimden geldiği (`user` / `staff`), kullanıcının son okuma zamanı |
| `support_messages` | Yazışma: yazan (`user` / `staff`), metin (1–4000), ekler (en fazla 3 dosya yolu) |
| Storage `support-attachments` | **Gizli** bucket. Dosya yolu `<user_id>/<ticket_id>-<n>.<uzantı>`. En fazla 5 MB; JPEG, PNG veya WebP. |

- **Kullanıcının kendi verisine basit yazma** olduğu için mesaj açma ve yanıt yazma Flutter → Supabase üzerinden yapılır; RLS korur.
  - Mesaj ve ilk yazışma, `public.create_support_ticket` RPC'siyle tek transaction'da açılır. RPC `security invoker`'dır, RLS altında çalışır.
  - Kullanıcı yalnızca kendi mesajını okur, yalnızca kendi mesajına `user` olarak yazar ve yalnızca kendi okuma zamanını günceller.
- **Grup eklemek** için gönderenin o grupta `group.edit` yetkisi (sahip ya da Yönetici) olmalıdır. Yönettiği gruplar `public.my_managed_groups()` ile listelenir.
- **Kötüye kullanım sınırı** (trigger): kullanıcı başına 24 saatte en fazla 5 mesaj açılır, saatte en fazla 20 yanıt yazılır.
- **Platform ekibinin yanıtı ve durum değişikliği** C# API'den geçer (admin işlemi). İkisi de audit log'a yazılır: `support.replied`, `support.status_changed`.
- **Ekler:** sahibi kendi klasörüne yükler ve okur. Platform ekibi tüm ekleri okur. Ekranlar dosyayı süreli imzalı adresle gösterir.
- **Hesap silinince** mesajlar `on delete cascade` ile silinir. Kalıcı silme işi `support-attachments/<uid>/` klasörünü de temizler. Grup silinirse mesaj kalır, grup bağlantısı boşalır.
- Platform ekibinin her üç rolü (`admin`, `moderator`, `support`) mesajları görür, yanıtlar ve durumlarını değiştirir.

### Arayüz
- **Sosyal uygulama:** Ayarlar'da "Destek ve geri bildirim" bulunur; yeni yanıt varsa sayısı görünür. Destek ekranında kullanıcının mesajları, durumları ve okunmamış yanıt işareti listelenir.
  - **Yeni mesaj:** tür seçimi (renkli kartlar), yönetilen grup (varsa), konu, açıklama, en fazla 3 görsel.
  - **Mesaj ekranı:** yazışma ve yanıt kutusu.
  - Grup yöneticisi grup sayfasından o grup için mesaj açabilir.
- **Admin paneli:** "Destek" sayfasında türe göre renkli sayaç kartları (Sorunlar kırmızı, Talepler sarı, İstekler yeşil, Yanıt bekleyen) bulunur. Liste arama, tür ve durum filtresi içerir; her satırda tür ikonu ve rengi gösterilir. Detayda yazışma, ekler, gönderen ve grup bağlantıları, yanıt kutusu ve durum seçimi yer alır.

### C# uç noktaları
| Uç nokta | Açıklama |
|---|---|
| `GET /admin/support/stats` | Açık (Yeni + İnceleniyor) mesaj sayısı türe göre; yanıt bekleyen sayısı |
| `GET /admin/support/tickets?q=&kind=&status=&page=` | Mesajlar (konu, kullanıcı adı, grup adı ile arama). Önce yanıt bekleyenler, sonra son mesaja göre |
| `GET /admin/support/tickets/{id}` | Mesaj, gönderen, grup, yazışma |
| `POST /admin/support/tickets/{id}/messages` | Ekip yanıtı (`body`) |
| `PUT /admin/support/tickets/{id}/status` | Durum değiştirme (`status`) |

Rol: `admin`, `moderator`, `support`.

## 8. Canlı sesli yayın (Faz 7)

Ürün kararları (2026-10-20): yayını grup sahibi ve Yöneticiler başlatır. Yalnızca grup üyeleri katılır. X Spaces benzeri sesli oda: sahnede konuşmacılar, aşağıda dinleyiciler, el kaldırma. Emoji tepkileri, yazılı yorumlar ve planlı yayın (hatırlatmalı) vardır. Gruptan ban ve susturma Faz 6'da bağlandı (§3e): banlı ya da çıkarılan kişi üye olmadığı için katılamaz, susturulan kişi yalnızca dinler.

- LiveKit kullanılır. Token yalnızca C# backend'de üretilir. Atılan kullanıcıya o yayın için token verilmez.
- Moderasyon sunucu tarafında yapılır (LiveKit server API). İstemcinin yayın izni (`canPublish`) ve katılımcı öznitelikleri (rol, el, susturma) yalnızca sunucu tarafından değiştirilir. İstemci, kapatılan mikrofonunu kendisi açamaz.

### Yayın
`live_broadcasts`: grup, sunucu (`host_id`, başlatan ya da planlayan), başlık (3–80), durum ve zamanlar. LiveKit odasının adı yayının kimliğidir.

| Durum | Anlamı | Geçiş |
|---|---|---|
| `scheduled` | Planlı; `scheduled_at` en az 5 dakika, en fazla 30 gün ileride | `live` (sunucu başlatır) ya da `canceled` |
| `live` | Yayında (`started_at`) | `ended` |
| `ended` | Bitti (`ended_at`, `end_reason`) | — |
| `canceled` | Planlı yayın iptal edildi ya da zamanından 1 saat sonra başlatılmadı | — |

- Bir grupta aynı anda en fazla **bir** canlı yayın ve **beş** planlı yayın olur.
- `end_reason`: `host` (sunucu bitirdi), `moderator` (grup yöneticisi bitirdi), `admin` (platform ekibi acil kapattı), `limit` (aylık dakika doldu), `host_left` (sunucu 2 dakikadan uzun süre odada değil), `empty` (oda kapandı).
- Kayıtlar geçmiş olarak kalır; grup silinince `on delete cascade` ile gider.

### Roller ve yetkiler
Yayın içindeki roller: **Sunucu** (yayını başlatan), **Konuşmacı** (sahnede, mikrofonu olabilir), **Dinleyici**. Sahnede sunucu dahil en fazla 10 kişi bulunur.

| Yetki | Açıklama | Roller (sahip dışında) |
|---|---|---|
| `live.start` | Yayın başlatma ve planlama | admin |
| `live.moderate` | Grubun her yayınında sahneye alma ve indirme, mikrofon kapatma ve açma, odadan atma, yorum silme, yayını bitirme ve planlı yayını iptal etme | admin, discipline, moderator |

- Sunucu kendi yayınında `live.moderate` yetkilerinin hepsine sahiptir. Sunucu ve `live.moderate` yetkilileri bu bölümde **yayın yöneticisi** diye anılır.
- **Rütbe kuralı:** Başkasına yapılan her yaptırımda (sahneden indirme, mikrofon kapatma ve açma, atma, yorum silme, yayını bitirme, planlı yayını iptal) işlemi yapanın grup rütbesi hedefinkinden **kesinlikle büyük** olmalıdır. Başkasının yayınını bitirmek ya da iptal etmek sunucuya yapılan bir işlemdir. Sunucu kendi yayınında rütbe aranmadan bitirir ve iptal eder; sahneye davet yaptırım değildir.
- Herkes kendi elini kaldırır ve indirir, sahneden kendisi iner, kendi yorumunu siler, yöneticinin kapatmadığı mikrofonunu kendisi açıp kapatır.

### Akış
1. **Başlatma:** `live.start` yetkilisi başlığı yazar ve yayını başlatır. Aylık dakika kalmış ve grupta başka canlı yayın olmamalıdır. API kaydı `live` olarak açar ve LiveKit odasını oluşturur. Planlı yayını yalnızca sunucusu, planlanan zamandan en çok 15 dakika önce başlatır.
2. **Katılma:** Üye yayına girince API token verir: grup üyesi, hesabı aktif, yayın canlı ve kullanıcı bu yayından atılmamış olmalıdır. Token 10 dakika geçerlidir ve odaya girişte kullanılır; bağlı istemcinin token'ını LiveKit yeniler. Kimlik (`identity`) kullanıcı uuid'sidir; görünen ad ve profil fotoğrafının yolu (`avatar` özniteliği) token'la gelir. Dinleyicinin `canPublish` izni yoktur. Herkes veri mesajı (tepki) gönderebilir; kimse kendi özniteliğini değiştiremez.
3. **El kaldırma:** Dinleyici elini kaldırır (`hand` özniteliği). Yayın yöneticileri kaldırılan elleri görür.
4. **Sahneye alma:** Yayın yöneticisi dinleyiciyi sahneye alır: `canPublish` açılır, rol `speaker` olur, el iner. Sahneden indirme izni geri alır.
5. **Mikrofon kapatma:** Yayın yöneticisi bir konuşmacının mikrofonunu kapatır: `canPublish` kapanır, `muted` özniteliği konur, kişi sahnede kalır. Mikrofonu yalnızca yayın yöneticisi yeniden açar.
6. **Atma:** Yayın yöneticisi kişiyi odadan çıkarır; kişi bu yayına bir daha giremez (`live_kicks`).
7. **Bitirme:** Sunucu ya da rütbesi sunucudan yüksek `live.moderate` yetkilisi yayını bitirir; oda kapanır, herkes çıkar.
8. **Gözetim** (`LiveMonitor`, 30 saniyede bir): odası kapanmış yayını `empty`, sunucusu 2 dakikadan uzun süre odada olmayan yayını `host_left`, aylık dakikası dolan grubun yayınını `limit` nedeniyle bitirir. Zamanından 1 saat sonra başlatılmamış planlı yayını iptal eder.

### Dakika limiti
- Ay, Türkiye saatiyle takvim ayıdır. Kullanılan dakika, o ay içinde kalan canlı yayın sürelerinin toplamıdır (biten yayınlar için `ended_at`, süren için şu an).
- Limit grubun paketindeki `monthly_live_minutes` değeridir (§7).
- Dakika kalmamışsa yayın başlatılamaz (`live.minutes_exhausted`). Kontrol hem C#'ta hem `live_broadcasts` trigger'ında yapılır. Süren yayın, dakika dolunca gözetim tarafından bitirilir. Başlatma ekranı kalan dakikayı gösterir.

### Yorumlar
- `live_comments`: yazar, metin (1–300), zaman. Yayının yorumlarını grubun üyeleri okur; yorumlar Realtime ile canlı akar.
- Yorum yazmak **kullanıcının kendi basit yazmasıdır** (Flutter → Supabase, RLS): grup üyesi, hesap aktif, yayın canlı ve kişi atılmamış olmalı. Sınır: dakikada 20 yorum (trigger).
- Kişi kendi yorumunu siler. Başkasının yorumunu yayın yöneticisi API üzerinden siler (`live.comment_removed`).
- Yorumlar yayın kaydıyla birlikte kalır.

### Tepkiler
Emoji tepkileri (❤️ 👏 😂 🔥 😮 🙌) LiveKit veri mesajıdır (`reaction` konusu). Saklanmaz, ekranda uçarak görünür. İstemci saniyede en fazla 3 tepki gönderir.

### Planlı yayın ve hatırlatma
- Planlı yayın grup sayfasında "Yaklaşan" olarak görünür. Üye "Hatırlat" der (`live_reminders`, kullanıcının kendi basit yazması; yalnızca planlı yayına).
- Yayın planlanınca grubun bütün üyelerine (yayıncı hariç) `live_scheduled` bildirimi gider (trigger). Yayın iptal edilirse bu bildirimler silinir.
- Yayın başlayınca grubun bütün üyelerine `live_started` bildirimi gider (trigger). Canlı yayın bildirimlerini tercihlerinden kapatan üye bildirim almaz; "Hatırlat" demişse yine alır.
- Bu bildirimler uygulama kapalıyken push ile gider (§3c, Push).

### Arayüz
- **Grup sayfası:** Canlı yayın varsa mor→mavi gradyanlı "CANLI" kartı ve katıl düğmesi; yaklaşan planlı yayınlar ve "Hatırlat"; `live.start` yetkilisine gradyanlı "Yayın başlat" düğmesi (hemen ya da planla).
- **Ana sayfa:** Üye olunan gruplardaki canlı yayınlar hikaye çubuğunun üstünde, gradyan halkalı "CANLI" rozetle görünür.
- **Yayın odası:** başlık, CANLI rozeti, katılımcı sayısı ve süre; sahnedekiler büyük avatar, konuşurken halka; dinleyiciler küçük avatar ızgarası; alt çubukta el kaldırma ya da mikrofon, tepkiler, yorumlar ve çıkış. Yayın yöneticisi bir kişiye dokununca işlem menüsü açılır.
- Mikrofon izni, kişi sahneye alınıp mikrofonunu ilk kez açtığında istenir.

### Veri ve erişim
| Tablo | Okuma | Yazma |
|---|---|---|
| `live_broadcasts` | Grubun üyeleri ve platform ekibi | Backend |
| `live_kicks` | Platform ekibi | Backend |
| `live_comments` | Grubun üyeleri ve platform ekibi | Kendi yorumunu ekleme ve silme (RLS); başkasınınkini backend siler |
| `live_reminders` | Kişinin kendisi | Kendi kaydı (RLS) |

- Trigger'lar ikinci katmandır: başlatma ve planlamada `live.start`, durum geçişleri, aynı anda tek canlı yayın, dakika limiti ve yorum kuralları.
- `public.my_live_broadcasts()` üye olunan gruplardaki canlı yayınları (ana sayfa), `public.group_live(group_id)` grubun canlı ve planlı yayınlarını ve kalan dakikayı döner.

### Audit log
`live.started`, `live.ended` (neden), `live.force_ended` (admin, gerekçe), `live.canceled`, `live.speaker_removed`, `live.muted`, `live.unmuted`, `live.kicked`, `live.comment_removed`. Kayıtların `group_id` alanı doludur. Sahneye davet, el kaldırma ve kişinin kendi işlemleri yazılmaz.

### C# uç noktaları
| Uç nokta | Açıklama |
|---|---|
| `POST /groups/{id}/live` | Yayın başlatma ya da planlama (`title`, `scheduledAt?`). `live.start` |
| `POST /live/{id}/start` | Planlı yayını başlatma (sunucu) |
| `DELETE /live/{id}` | Planlı yayını iptal (sunucu ya da `live.moderate` + rütbe) |
| `POST /live/{id}/end` | Yayını bitirme (sunucu ya da `live.moderate` + rütbe) |
| `POST /live/{id}/token` | Katılım: LiveKit adresi, token ve kişinin rolü |
| `PUT /live/{id}/hand`, `DELETE /live/{id}/hand` | Kendi elini kaldırma / indirme |
| `PUT /live/{id}/speakers/{userId}` | Sahneye alma (yayın yöneticisi) |
| `DELETE /live/{id}/speakers/{userId}` | Sahneden indirme (kendisi; ya da yayın yöneticisi + rütbe) |
| `PUT /live/{id}/muted/{userId}`, `DELETE /live/{id}/muted/{userId}` | Mikrofonu kapatma / açma (yayın yöneticisi + rütbe) |
| `POST /live/{id}/kicks/{userId}` | Odadan atma (yayın yöneticisi + rütbe) |
| `DELETE /live/{id}/comments/{commentId}` | Başkasının yorumunu silme (yayın yöneticisi + rütbe) |
| `GET /admin/live?status=&page=` | `live` (katılımcı sayısıyla), `scheduled` (planlanan zaman ve duyurulan üye sayısıyla) ya da `ended` yayınlar; her yayında kaç kişiye bildirim gittiği. Rol: `admin`, `moderator`, `support` |
| `POST /admin/live/{id}/end` | Acil kapatma (`reason`). Rol: `admin`, `moderator` |

### Yapılandırma
`LiveKit:Url` (istemcinin bağlandığı adres, ör. `wss://live.grupx.app`), `LiveKit:ApiUrl` (sunucu API'si; boşsa `Url`'in http karşılığı), `LiveKit:ApiKey`, `LiveKit:ApiSecret`. Anahtarlar tanımlı değilse yayın kapalıdır (`live.unavailable`, 503). Yerelde LiveKit Docker'da `--dev` modunda çalışır (§9).

## 8b. Yönetim paneli: analiz ve denetim (Faz 15.7)

Kullanıcı isteği (2026-10-27): panel her modülü, yazışmaları ve işlemleri ayrıntılı ama düzenli gösterir; istatistikler profesyonel grafiklerle sunulur.

### Genel bakış (15.7a)
- Panelin açılış sayfasıdır (`/overview`). Üstte tarih aralığı: 7, 30, 90 ya da 365 gün (varsayılan 30).
- **Günler Türkiye saatine göredir** (`Europe/Istanbul`); 365 günlük aralık haftalık toplanır, diğerleri günlük.
- **KPI kartları:** seçili dönemin toplamı, bir önceki eşit uzunluktaki dönemle farkı (yüzde; önceki dönem sıfırsa "yeni") ve mini eğri. Kartlar: yeni kullanıcı, aktif kullanıcı, yeni grup, gönderi, mesaj, eşleşme, gelir (TRY ve USD ayrı, iade düşülmüş), açılan şikayet.
- **Aktif kullanıcı:** o gün en az bir şey yazan kişi: gönderi, yorum, beğeni, emoji tepkisi, mesaj, eşleşme kaydırması ya da gruba katılma. Dönemin aktif kullanıcısı tekil kişi sayısıdır. Yalnızca okuyan kişi sayılmaz (okuma kaydı tutulmaz).
- **Grafikler:** kullanıcı büyümesi (yeni ve aktif kullanıcı), etkileşim (gönderi, yorum, mesaj, tepki), eşleşme (beğeni, süper beğeni, eşleşme), gelir (ödenen siparişler, para birimine göre), moderasyon (açılan ve incelenen şikayet). Her grafikte açıklama, eksen etiketleri ve dokununca / üzerine gelince değerler; boş dönemde boş durum metni.
- `GET /admin/analytics/overview?days=7|30|90|365`. Rol: `admin`, `moderator`, `support`; gelir ölçüleri yalnızca faturalamayı gören rollere (`admin`, `support`) döner. 365 günlük aralık 52 tam haftadır; haftalık görünümde aktif kullanıcı noktası o haftanın günlük ortalamasıdır.
- Grafikler `fl_chart` ile çizilir; bağımlılık yalnızca `features/admin`'dedir. Renkler tasarım sistemi tokenlarından gelir.

### Hukuki metin yönetimi (15.7, §3a KVKK)
- `/admin/legal` sayfası hukuki metinleri yönetir: KVKK aydınlatma (`privacy_notice`), kullanım koşulları (`terms`), açık rıza (`explicit_consent`), mesafeli satış (`distance_sales`). Rol: **yalnızca `admin`**; görüntüleme de dâhil (metinler hassastır).
- Her tür sürümlüdür. Sayfa, türleri ve her türün sürümlerini listeler: sürüm no, başlık, yayın zamanı, **güncel mi** (yayınlanmış en yüksek sürüm), **kaç onay bağlı**, taslak mı (yayın zamanı gelecekte).
- **Yeni sürüm yayınla:** başlık, gövde ve yayın zamanı (şimdi ya da ileri tarih). Sürüm no otomatik (`max+1`). `audience` türden türetilir. İleri tarihli sürüm o ana kadar kimseye görünmez ve güncel sayılmaz.
- **Düzenle / sil:** yalnızca **hiç onay bağlı olmayan** sürümde. Onay bağlı sürüm değişmezdir (yeni sürüm açılır). Kural API'de ve `legal_documents_guard` trigger'ında çift korunur.
- Her işlem `audit_log`'a yazılır: `legal.published`, `legal.updated`, `legal.deleted`.

| Uç nokta | Açıklama |
|---|---|
| `GET /admin/legal` | Türler ve sürümleri (sürüm, başlık, yayın zamanı, güncel mi, onay sayısı, audience). Rol: `admin` |
| `GET /admin/legal/{kind}/{version}` | Bir sürümün tam gövdesi (düzenleme için). Rol: `admin` |
| `POST /admin/legal/{kind}` | Yeni sürüm yayınla (`title`, `body`, `publishedAt?`). Rol: `admin` |
| `PUT /admin/legal/{kind}/{version}` | Onay bağlı değilse düzenle (`title`, `body`, `publishedAt`). Rol: `admin` |
| `DELETE /admin/legal/{kind}/{version}` | Onay bağlı değilse sil. Rol: `admin` |

## 10. Google Play (Faz 17a, kullanıcı kararları 2026-10-27)

### Uygulama kimliği ve imza
- Paket adı **`com.grupx.app`**. Yayından sonra değişmez. Firebase'de bu adla ayrı bir Android uygulaması vardır (`google-services.json`).
- Sürüm `pubspec.yaml`'daki `version`'dan gelir (`1.0.0+1`; `+` sonrası her yüklemede artar).
- **Play App Signing** kullanılır. Bizdeki anahtar yalnızca *yükleme anahtarıdır*.
  - Anahtar ve şifreleri repoya girmez; `%USERPROFILE%\.grupx\upload-keystore.jks` ve `android/key.properties` (gitignore) dosyalarındadır.
  - Kaybolursa Play Console'dan yükleme anahtarı sıfırlanır.
  - `key.properties` yoksa sürüm derlemesi debug anahtarıyla imzalanır; bu yalnızca yerel deneme içindir.
- Play'e **App Bundle** yüklenir: `flutter build appbundle --release`.

### Ağ
- Sürüm derlemesinde şifresiz (http) trafik kapalıdır. API ve Supabase `https` olmalıdır.
- Ev ağı APK'sı için şifresiz trafik yalnızca açıkça istenince açılır: `--android-project-arg=lanHttp=true`. Bu derleme Play'e yüklenmez.

### Ödeme (Play kuralı)
- Android uygulamasında **satış yoktur**. Paket satın alma ekranları, fiyatlar ve web'e yönlendiren hiçbir metin ya da bağlantı Android'de gösterilmez.
- Kullanıcı paketlerin **durumunu** görür (aktif mi, ne zaman biter). Satın alma yalnızca web'dedir.
- Kural tek yerden uygulanır: `purchasesOnThisPlatformProvider` (billing) yalnızca web'de `true`. Satın alma, ödeme ve fiyat ekranları buna bakar.

### Herkese açık sayfalar (web uygulaması, girişsiz)
- `/gizlilik`: en güncel aydınlatma metni (Play'deki gizlilik politikası bağlantısı).
- `/kosullar`: kullanım koşulları.
- `/hesap-silme`: hesap ve veri silmenin nasıl yapıldığı ve 30 günlük süre (Play'in istediği web bağlantısı).

### İzinler ve Play beyanları
- Konum: yalnızca uygulama açıkken (`ACCESS_FINE/COARSE_LOCATION`). Arka planda konum yok. İzinden önce amaç ekranı gösterilir.
- Mikrofon: yalnızca canlı yayında sahneye alınınca.
- `QUERY_ALL_PACKAGES` yok; yalnızca VPN servisleri sorgulanır (`<queries>`).
- Ayrıntılı beyan cevapları, veri güvenliği formu, içerik derecelendirmesi ve mağaza metinleri: `docs/PLAY_STORE.md`.

### Sunucu
- Yayında API, LiveKit, web uygulaması ve panel tek sunucuda, Docker Compose ile çalışır. Caddy otomatik `https` verir.
- Kurulum dosyaları `deploy/` klasöründe, adımlar `docs/DEPLOY.md`'de.

## 9. Test ve "bitti" tanımı

Bir faz şu koşullar sağlanınca biter:
- Fazdaki tüm maddeler çalışıyor.
- pgTAP RLS testleri, C# testleri ve kritik Flutter testleri geçiyor.
- Fazın admin paneli karşılığı yapılmış.
- `flutter analyze` ve `dotnet build` hatasız ve uyarısız.
- `docs/` güncel.

| Komut | Nerede |
|---|---|
| `bash tool/setup_platforms.sh` | `app/` (ilk kurulumda bir kez) |
| `flutter pub get`, `flutter analyze`, `melos run test` | `app/` |
| `dotnet build`, `dotnet test` | `backend/` |
| `supabase start`, `supabase db reset`, `supabase test db` | repo kökü |
| `docker run --rm -d --name grupx-livekit -p 7880:7880 -p 7881:7881 -p 7882:7882/udp livekit/livekit-server:v1.9.1 --dev --bind 0.0.0.0 --node-ip 127.0.0.1` | Yerel LiveKit (`devkey` / `secret`). Telefon için `adb reverse tcp:7880` ve `tcp:7881` (ses TCP üzerinden akar). |
