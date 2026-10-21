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

`core, identity, profile, groups, billing, support, feed, notifications, events, moderation, live, messaging, admin`

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
| `public.group_follows` | groups | 4 |
| `public.posts`, `public.post_media`, `public.post_hashtags` | feed | 4 |
| `public.post_likes`, `public.comments`, `public.comment_likes`, `public.saved_posts` | feed | 4 |
| `public.stories`, `public.story_views`, `public.highlights`, `public.highlight_stories` | feed | 4 |
| Storage `media` | feed | 4 |
| `public.notifications` | notifications | 4 |
| `public.notification_preferences` | notifications | 9 |
| `public.events`, `public.event_attendees`, `public.polls`, `public.poll_options`, `public.poll_votes` | events | 5 |
| Storage `event-images` | events | 5 |
| `public.live_broadcasts`, `public.live_kicks`, `public.live_comments`, `public.live_reminders` | live | 7 |
| `public.reports`, `public.moderation_cases`, `public.case_votes`, `public.sanctions`, `public.sanction_appeals` | moderation | 6 |

Her yeni tablo bu listeye eklenir. Okuma amaçlı SQL yardımcı fonksiyonları (`private.is_account_visible` gibi) başka modülün tablosunu okuyabilir; yazamaz.

## 3a. Kimlik ve Profil (Faz 1)

### Hesap yaşam döngüsü
- Kayıt: e-posta + şifre (**e-posta doğrulaması zorunlu**), Google, Apple. Şifre sıfırlama e-postayla yapılır.
- `auth.users` kaydı oluşunca trigger `account_status` satırını `active` olarak açar.
- Giriş sonrası zorunlu sıra: **KVKK onayları → onboarding → uygulama.** Router bu sırayı zorlar.
- Durumlar (`account_status.status`):
  - `active`: normal.
  - `suspended`: platform ekibi askıya aldı. Supabase Auth'ta da ban uygulanır (giriş ve token yenileme kapanır). `suspended_until` geçince hesap kendiliğinden aktif sayılır. Profil başkalarına gizlenir, kullanıcı kendi verisine yazamaz.
  - `pending_deletion`: kullanıcı silme istedi. Profil başkalarına **hemen gizlenir**. Kullanıcı giriş yapabilir ve yalnızca "silmeyi geri al" ekranını görür. 30 gün sonra backend kalıcı olarak siler.
- Kalıcı silme (`AccountPurgeService`, saatlik): storage dosyaları (`avatars/<uid>/`, `covers/<uid>/`) ve `auth.users` kaydı silinir. Bağlı satırlar `on delete cascade` ile gider. `audit_log` kaydı (`account.purged`) kalır, yalnızca uuid içerir.

### KVKK
- Hukuki metinler `legal_documents` tablosunda sürümlüdür (`kind`, `version`). Zorunlu türler: `terms` (kullanım koşulları), `privacy_notice` (aydınlatma metni), `explicit_consent` (açık rıza: verilerin yurt dışındaki sunucularda işlenmesi).
- Kullanıcının her zorunlu türün **en güncel sürümünü** onaylamış olması gerekir. Yeni sürüm yayınlanınca onay ekranı yeniden gösterilir.
- `consents` yalnızca ekleme yapılan bir kayıttır. Kullanıcı yalnızca kendi adına ekler (kendi verisine basit yazma), değiştiremez ve silemez.
- Metinler taslaktır; yayından önce hukuki incelemeden geçmelidir.

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
| `POST /groups` | Grup oluşturma (`handle`, `name`, `categorySlug`, `joinPolicy`, `about`). Oluşturan sahip ve üye olur. |
| `PATCH /groups/{id}` | Profil düzenleme (`group.edit`): ad, kategori, katılım tipi, tanıtım, kurallar, bağlantılar, logo ve kapak yolu. Yalnızca gönderilen alanlar değişir. |
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
| feed | `posts`, `post_media`, `post_hashtags`, `post_likes`, `comments`, `comment_likes`, `saved_posts`, `stories`, `story_views`, `highlights`, `highlight_stories`, Storage `media` |
| notifications | `notifications` (kayıtları diğer modüllerin tablolarındaki trigger'lar oluşturur) |

C#'ta `GrupX.Modules.Profile` (takip ve engelleme) ve `GrupX.Modules.Feed` (gönderi oluşturma, düzenleme, silme; admin kaldırma) modülleri eklenir. Bildirimlerin C# kodu yoktur.

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
- **Türler:** `like`, `comment`, `reply`, `comment_like`, `mention`, `follow`, `follow_request`, `follow_accepted`, `event_promoted`, `event_updated`, `event_canceled`, `event_reminder` (Faz 5, §3d), `live_started` (Faz 7, §8), `case_vote`, `sanction_applied`, `appeal_submitted`, `appeal_decided` (Faz 6, §3e).
- **Oluşturma:** Bildirimleri ilgili tablolardaki trigger'lar oluşturur. Kişi kendi işlemi için bildirim almaz; engel varsa bildirim oluşmaz.
- **Silme:** Beğeni geri alınınca, yorum silinince ya da takip bırakılınca ilgili bildirim de silinir.
- **Erişim:** Alıcı okur, okundu işaretler ve siler; başka hiçbir rol yazamaz.
- **Arayüz:** Ekranda bildirimler Bugün / Bu hafta / Daha önce diye gruplanır. Bekleyen takip istekleri en üstte toplanır. Okunmamış sayısı gezinmede görünür.
- **Push:** Push bildirimi (FCM/APNs) Firebase proje bilgileri gelince bu kayıtlardan gönderilir.
- **Tercihler** (Faz 9, `notification_preferences`): kişi organizasyon hatırlatmalarını (1 gün önce, 1 saat önce) ve organizasyon değişikliği/iptali bildirimlerini kapatabilir. Kayıt yoksa hepsi açıktır. Kişinin kendi basit yazmasıdır (RLS). Bildirimi yazan fonksiyonlar tercihi okur (`private.wants_notification`); kapalı türde kayıt hiç oluşmaz. Diğer türler (katılım onayı, sıra yükselmesi, yaptırım vb.) kişiyi doğrudan ilgilendirdiği için kapatılamaz.

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

### C# uç noktaları (Faz 4)
| Uç nokta | Açıklama |
|---|---|
| `POST /users/{id}/follow` | Takip et; yanıt `following` ya da `requested` |
| `DELETE /users/{id}/follow` | Takibi bırak ya da isteği geri al |
| `POST /me/follow-requests/{userId}/approval` | İsteği kabul et |
| `DELETE /me/follow-requests/{userId}` | İsteği reddet |
| `DELETE /me/followers/{userId}` | Takipçiyi çıkar |
| `POST /users/{id}/block` / `DELETE /users/{id}/block` | Engelle / engeli kaldır |
| `POST /posts` | Gönderi (`caption`, `media[]`, `groupId?`, `commentsDisabled`, `hideLikeCount`) |
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
`event_promoted`, `event_updated`, `event_canceled`, `event_reminder`, `event_approved`, `event_declined` (bildirim kaydında `event_id`). Organizasyon oluşturulduğunda toplu bildirim gönderilmez; organizasyon grup sayfasında ve grubu takip edenlerin ilgisine görünür.

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

### Veri ve erişim
| Tablo | Okuma | Yazma |
|---|---|---|
| `events` | Herkes (grup görünürse) | Backend |
| `event_attendees` | Grubun üyeleri ve kişinin kendisi | Backend |
| `polls`, `poll_options` | Grubun üyeleri | Backend |
| `poll_votes` | Kendi oyları; açık anketlerde grubun üyeleri | Kendi oyu (RLS) |
| Storage `event-images` | Herkes | `events.manage` (kendi grubunun klasörü) |

### Audit log
`event.created`, `event.updated`, `event.canceled` (gerekçe), `event.canceled_by_admin` (gerekçe), `event.attendee_approved`, `event.attendee_declined`, `poll.created`, `poll.closed`, `poll.deleted`. Kayıtların `group_id` alanı doludur. Katılım ve oy kişinin kendi işlemidir; yazılmaz.

### C# uç noktaları
| Uç nokta | Açıklama |
|---|---|
| `POST /groups/{id}/events` | Organizasyon oluşturma (`events.manage`, aylık limit) |
| `PUT /events/{id}` | Düzenleme (`events.manage`); formun tamamı gönderilir |
| `POST /events/{id}/cancellation` | İptal (`reason`, `events.manage`) |
| `POST /events/{id}/attendance` | Katılma; yanıt `going`, `waitlisted` (ve sıra) ya da onaylı katılımda `requested` |
| `DELETE /events/{id}/attendance` | Vazgeçme ya da isteği geri alma; sıradaki yükselir |
| `POST /events/{id}/requests/{userId}/approval` | Katılım isteğini onaylama (`events.manage`) |
| `DELETE /events/{id}/requests/{userId}` | Katılım isteğini reddetme (`events.manage`) |
| `GET /events/{id}/calendar.ics` | Takvime ekle (oturum gerekmez) |
| `POST /groups/{id}/polls` | Anket açma (`question`, `options[]`, `allowsMultiple`, `isAnonymous`, `closesAt?`, `eventId?`) |
| `POST /polls/{id}/close`, `DELETE /polls/{id}` | Anketi kapatma / silme (`events.manage`) |
| `GET /admin/events?q=&status=&page=` | Organizasyonlar (`upcoming` / `past` / `canceled`). Rol: `admin`, `moderator`, `support` |
| `POST /admin/events/{id}/cancellation` | Platform ekibinin iptali (`reason`). Rol: `admin`, `moderator` |

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
  packages/features/<modül>    feature paketleri: identity, profile, groups, billing, support, feed, notifications, events, live, admin
```

- `core` ayrıca Supabase istemcisini (`supabaseClientProvider`), C# API istemcisini (`ApiClient`: Supabase oturum token'ını ekler, ProblemDetails'i `Failure`'a çevirir), `AppConfig`'i (`--dart-define`: `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `API_URL`), ortak kategorileri (`categoriesProvider`), görsel seçimini (`ImageUpload`, `pickGalleryImage`) ve tarih, para (`formatMoney`: `249 ₺`, `$9.99`) ve sayı biçimlendirmesini sağlar. `ApiClient`, ProblemDetails içeren 503 yanıtlarının başlığını da gösterir (ör. ödeme geçici olarak kapalı).
- Uygulamanın router'ı feature paketlerinin provider'larını birleştirir (oturum, onay, profil durumu). Feature'lar birbirini bilmez; bir feature'ın başka bir feature'ın ekranında yer alması gerekiyorsa uygulama bunu bağlar (ör. profil sayfasındaki "Gruplar" bölümü `ProfileScreen.sections` ile, grup ekranından profile geçiş `onOpenProfile` ile, grup sayfasındaki paket kartı `GroupScreen.sections` ile verilir; paket ve ödeme rotaları `/g/<handle>/plan` ve `/g/<handle>/plan/checkout` grubu uygulamada çözer ve `billing` ekranlarına kimliğini verir; canlı yayın kartı `GroupScreen.sections`, ana sayfadaki canlı yayın şeridi `HomeFeedScreen.top`, `live_started` bildirimi `NotificationLinks.openLive` ile bağlanır, yayın odası `/live/<id>` rotasındadır).
- Sosyal uygulamanın ana hedefleri (Gruplar, Profil) `HomeShell` içindedir: telefonda alt gezinme çubuğu, geniş ekranda yan ray. Web'de Flutter'ın varsayılan hash URL stratejisi kullanılır (`/#/g/<handle>`).
- OAuth ve e-posta bağlantıları mobilde `com.grupx.social://auth-callback` deep link'ine döner.

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
  1. `Billing:Geo:CountryHeader` tanımlıysa ve istekte varsa o başlık. Yalnızca API, başlığı kendisi ekleyen bir proxy'nin arkasındaysa tanımlanır (ör. Cloudflare `CF-IPCountry`).
  2. `Billing:Geo:DatabasePath` ile verilen MaxMind DB biçimli ülke veritabanı (DB-IP Lite veya GeoLite2 Country). Veritabanı dosyası repoya girmez, ortama kurulur ve aylık güncellenir.
  3. Bulunamazsa `Billing:Geo:FallbackCountry` (varsayılan `TR`). Yerelde istek `127.0.0.1`'den geldiği için bu değer kullanılır; iyzico akışını yerelde denemek için `DE` gibi bir değer verilir.
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
| `POST /billing/paytr/notify` | PayTR bildirimi (anonim, hash doğrulamalı, yanıt `OK`) |
| `POST /billing/iyzico/callback?order=` | iyzico'dan dönüş (anonim). Sonucu iyzico'dan sorar, uygulamaya 303 ile yönlendirir. |
| `POST /billing/iyzico/webhook` | iyzico bildirimi (anonim, `X-IYZ-SIGNATURE-V3` doğrulamalı) |
| `GET /admin/billing/stats` | Aktif ücretli abonelik, ücretli grup, bu ayın ve son 12 ayın geliri (para birimine göre). Rol: `admin` |
| `GET /admin/billing/orders?q=&status=&provider=&page=` | Siparişler (grup adı veya adresiyle arama). Rol: `admin`, `support` |
| `GET /admin/billing/subscriptions?q=&page=` | Aktif ve ileri tarihli abonelikler. Rol: `admin`, `support` |
| `GET /admin/plans` | Paketler ve fiyatları. Rol: `admin`, `support` |
| `PUT /admin/plans/{slug}` | Paketi güncelleme (ad, limitler, satış durumu, fiyatlar). Rol: `admin` |
| `POST /admin/subscriptions/{id}/cancellation` | Aboneliği iptal (`reason`, `refunded`). Şu anki dilim hemen biter, ileri tarihli dilim başlamaz. `refunded` ise sipariş `refunded` olur. Rol: `admin` |

`GET /admin/groups/{id}` yanıtına grubun güncel paketi ve abonelik geçmişi eklenir.

### Yapılandırma
`Billing:AppUrl` (dönüş adresleri için web uygulaması, ör. `https://grupx.app`) ve `Billing:PublicApiUrl` (iyzico callback'i için API'nin dışarıdan erişilen adresi) tanımlanır. Ayrıca:
- `Billing:Paytr:MerchantId`, `MerchantKey`, `MerchantSalt`, `TestMode`
- `Billing:Iyzico:ApiKey`, `SecretKey`, `BaseUrl` (sandbox: `https://sandbox-api.iyzipay.com`)
- `Billing:Geo:*`

Anahtarlar yalnızca ortam değişkeni veya user-secrets ile verilir.

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
- Yayın başlayınca hatırlatma isteyenlere uygulama içi `live_started` bildirimi gider (trigger). Push bildirimi Firebase bilgileri gelince bu kayıtlardan gönderilir.

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
| `GET /admin/live?status=&page=` | Canlı (katılımcı sayısıyla) ve geçmiş yayınlar. Rol: `admin`, `moderator`, `support` |
| `POST /admin/live/{id}/end` | Acil kapatma (`reason`). Rol: `admin`, `moderator` |

### Yapılandırma
`LiveKit:Url` (istemcinin bağlandığı adres, ör. `wss://live.grupx.app`), `LiveKit:ApiUrl` (sunucu API'si; boşsa `Url`'in http karşılığı), `LiveKit:ApiKey`, `LiveKit:ApiSecret`. Anahtarlar tanımlı değilse yayın kapalıdır (`live.unavailable`, 503). Yerelde LiveKit Docker'da `--dev` modunda çalışır (§9).

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
