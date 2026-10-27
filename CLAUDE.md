# GrupX — Proje Talimatı (Claude için)

Bu dosya her oturumda otomatik okunur. Projenin ne olduğunu, nasıl çalışılacağını ve hangi kuralların asla çiğnenmeyeceğini anlatır. Ayrıntılar `docs/` altındadır; çelişki olursa `docs/ARCHITECTURE.md` geçerlidir.

---

## 1. Ürün

GrupX; müzik grupları, yürüyüş, koşu, bisiklet, doğa, spor, sanat gibi **her türden sosyal grubu tek çatı altında toplayan**, X ve Instagram kalitesinde, profesyonel bir sosyal platformdur. Mobil (iOS, Android) ve web'de çalışır. Ayrıca mobil ve web'de çalışan ayrı bir **admin paneli** vardır.

### Kullanıcılar
- Kayıt olur, kendi **profil sayfasını** oluşturur (avatar, kapak, biyografi, katıldığı gruplar, gönderiler).
- Platformda sosyalleşir: gönderi paylaşır, beğenir, yorum yapar, kullanıcıları ve grupları takip eder.
- İstediği gruplara katılır (serbest, istekle veya davetle).

### Grup sahipleri
- Grup oluşturur ve grubun **profil sayfasını** yönetir: kapak, logo, tanıtım, kurallar, bağlantılar.
- Grup sayfasından şunları yapar:
  - **Organizasyon** oluşturma: tarih, yer, kapasite, tanıtım görseli.
  - **Katılım ücreti** bilgisi: v1'de yalnızca bilgi amaçlı gösterilir, platform para toplamaz.
  - **Anket** açma.
  - Duyuru ve tanıtım paylaşma.
- Yönetici, moderatör ve disiplin kurulu üyelerini atar.
- Grubun üye sayısına ve yaptığı organizasyonlara göre **abonelik paketi** satın alır.

### Grup içi roller
Bir üye birden fazla role sahip olabilir. Parantez içindeki sayı rütbedir.

| Rol | Rütbe | Yetki |
|---|---|---|
| Grup Sahibi | 100 | Her şey, ödeme, rol atama |
| Yönetici | 80 | İçerik, organizasyon, anket, üye yönetimi, canlı yayın başlatma ve moderasyonu |
| Disiplin Kurulu | 60 | Şikayet dosyası, oylama, uyarı, susturma, çıkarma, ban, canlı yayın moderasyonu |
| Moderatör | 50 | İçerik ve yorum denetimi, şikayet ön inceleme, anlık susturma, canlı yayın moderasyonu |
| Üye | 10 | Katılım, paylaşım, canlı yayına katılma |

**Rütbe kuralı:** Kimse, kendisiyle eşit ya da daha yüksek rütbeli birine yaptırım uygulayamaz. Grup sahibi banlanamaz.

### Disiplin kurulu
- Herhangi bir üyeyi **gruptan çıkarabilir, banlayabilir (süreli veya kalıcı), sesini kapatıp açabilir, uyarabilir**.
- Süreç: şikayet → moderatör ön incelemesi → disiplin dosyası → kurul oylaması (varsayılan salt çoğunluk, grup bazında ayarlanabilir) → yaptırım → itiraz hakkı.
- Acil durumda (ör. canlı yayında taciz) moderatör veya kurul üyesi anlık susturma ve yayından atma yapabilir.
- Her işlem değiştirilemez `audit_log` tablosuna yazılır.

### Canlı sesli yayın
- Grup sahibi ve Yöneticiler canlı yayın açar (hemen ya da planlı). Yalnızca grup üyeleri katılır ve yayında **sesli sohbet** eder; emoji tepkisi ve yazılı yorum gönderir.
- Yayında konuşmacılar ve dinleyiciler vardır. Dinleyici el kaldırır, yetkili kişi onu konuşmacı yapar ya da konuşmacılıktan alır.
- Moderasyon **sunucu tarafında** yapılır: mikrofonu kapatma ve açma, odadan atma, gruptan banlama. İstemci kapatılan mikrofonunu kendisi açamaz.
- Yayından atılan kullanıcıya o yayın için token verilmez. Gruptan ban ve susturma Faz 6'da bağlanır.
- Altyapı: **LiveKit**. Token C# backend'de üretilir.
- Yayın dakikası paket limitine bağlıdır.

### Abonelik ve ödeme
- Grup sahipleri paket satın alır. Paketlerin limitleri: maksimum üye sayısı, aylık organizasyon sayısı, aylık canlı yayın dakikası.
- Aboneliği olmayan grup ücretsiz paketin limitlerini kullanır.
- Ödeme sağlayıcısı isteğin IP'sinin ülkesine göre seçilir: Türkiye'de **PayTR** (TL), yurt dışında **iyzico** (USD). Ödeme yalnızca sağlayıcının doğrulanmış bildirimiyle sunucuda kesinleşir.
- Paketler ön ödemelidir (aylık / yıllık, otomatik yenileme yok). Üst pakete geçişte kalan süre aktarılır.
- Satın alma web'den yapılır, mobil uygulama yalnızca paket durumunu gösterir. Sebep: Apple ve Google'ın uygulama içi ödeme kuralları.
- Limitler hem API'de hem veritabanında (trigger) korunur.

### Admin paneli
Platform ekibi (admin, moderatör, destek) için. Kullanıcı ve grup yönetimi, abonelikler ve gelir, platform genelinde şikayetler, aktif yayınlar ve acil kapatma, analitik. **Her fazın admin karşılığı o fazın içinde yapılır**, sona bırakılmaz.

---

## 2. Tasarım (AAA)

- **Ferah, sakin, profesyonel.** Kullanıcıyı boğmayan, kullanım keyfini artıran, içeriği öne çıkaran bir arayüz.
- **Zemin:** her ekranın arkasında beyazdan açık mora ve açık pembeye yumuşak geçen bir zemin (`GxBackdrop`) vardır; içerik bu zeminin üstünde **beyaz kartlarda** durur. Kullanıcı isteğiyle 2026-10-22'de eklendi.
- **Topluluk merkezli, X/Instagram kalıbı değil:** ana sayfa "Bugün" (canlı, yaklaşan organizasyonlar, sonra akış); içerik hafif tonlu zemin üzerinde beyaz kartlarda; profil ve grup başında kimlik kartı (taşan avatar yok).
- Renkler **hafif tonlarda** mor, mavi, siyah ve beyaz:
  - Mor `#6E56CF`: ana aksiyon, soft zemin `#F3F0FF`
  - Mavi `#2F6FE0`: ikincil aksiyon ve bilgi, soft zemin `#EAF2FF`
  - Yumuşak siyah `#1F2033`: metin; ikincil metin `#5C5F77`
  - Zemin `#FFFFFF`; yüzeyler `#FAFAFD` ve `#F4F4F8`; kenar çizgileri `#ECECF2`
  - Zemin geçişi: açık mor `#EEE8FF`, açık pembe `#FFE6F3`, beyaz (yalnızca sayfa zemininde)
- Mor→mavi gradyan **yalnızca** canlı yayın rozeti ve "yayın başlat" butonunda kullanılır.
- Yazı tipi: **Plus Jakarta Sans**.
- Boşluklar 4'ün katlarıdır. Köşe yarıçapları: 8, 12, 16 ve 24.
- Gölge yerine ince kenar çizgisi kullanılır.
- Kullanıcı avatarı daire, grup avatarı yuvarlatılmış karedir.
- Yüklenirken iskelet (skeleton) gösterilir. Her boş listede ikon, tek cümle açıklama ve bir aksiyon bulunur.
- WCAG AA kontrast, en az 44×44 dokunma alanı, %130 yazı ölçeğinde bozulmayan düzen.
- Tüm değerler `app/packages/design_system` tokenlarından gelir. **Uygulama kodunda doğrudan renk veya boyut değeri yazılmaz.**
- Ayrıntılar: `docs/DESIGN.md`

---

## 3. Teknoloji ve mimari

| Katman | Teknoloji |
|---|---|
| Mobil + Web | Flutter (Dart pub workspace + Melos), Riverpod, go_router |
| Backend | C# .NET 10, ASP.NET Core Minimal API, **modüler monolit** |
| Veri | Supabase: Auth, Postgres + RLS, Storage, Realtime |
| Ses | LiveKit |
| Ödeme | PayTR (yurt içi), iyzico (yurt dışı) |
| Push | FCM / APNs |

### Altın kural: veri nereden geçer?
- **Okuma:** Flutter → Supabase (RLS korur).
- **Kullanıcının yalnızca kendi verisine basit yazma:** Flutter → Supabase. Örnekler: kendi profili, beğeni, yorum.
- **Başkasını etkileyen, kural, para veya yetki içeren her yazma:** Flutter → **C# API** → Supabase. Örnekler: rol atama, ban, susturma, abonelik, yayın tokenı, gruba katılma (limit kontrolü).
- **Service role anahtarı yalnızca C#'tadır.** Flutter'a asla girmez.

### Klasörler
```
docs/        ARCHITECTURE.md (kurallar), ROADMAP.md (fazlar), DESIGN.md
app/         apps/social_app, apps/admin_panel, packages/core, packages/design_system, packages/features/<modül>
backend/     src/GrupX.Api, src/GrupX.SharedKernel, src/Modules/GrupX.Modules.<Ad>
supabase/    migrations/ (numaralı SQL), tests/database/ (pgTAP)
```

### Modüller
core, identity, profile, groups, billing, support, feed, notifications, events, moderation, live, messaging, admin.

- Her modül Flutter'da ve C#'ta aynı isimle yaşar ve kendi tablolarının sahibidir.
- Modüller birbirinin tablosuna doğrudan yazmaz; birbirinin iç koduna da erişmez. Flutter'da feature paketleri birbirini import etmez. C#'ta bir modül başka bir modülün yalnızca `*.Contracts` projesine referans verebilir.

---

## 4. Çalışma kuralları (ihlal edilmez)

1. **Faz faz ilerlenir. Bir faz bitmeden sonrakine başlanmaz.** Kullanıcı açıkça istemedikçe sonraki faza geçme.
2. **Gereksiz kod yazılmaz.** Şu an kullanılmayan soyutlama, boş katman, "ileride lazım olur" diye eklenen paket ve placeholder ekran yok. Gerekmeyen bağımlılık eklenmez.
3. **Faz "bitti" tanımı:**
   - Fazdaki tüm maddeler çalışıyor.
   - Testler geçiyor: pgTAP RLS testleri, C# testleri, kritik Flutter testleri.
   - Fazın admin paneli karşılığı var.
   - `flutter analyze` ve `dotnet build` **hatasız ve uyarısız**.
   - `docs/` güncel.
4. **Güvenlik:**
   - Her tabloda RLS açık ve varsayılan reddet.
   - Her yeni tablo için yetkisiz erişimi engellediğini kanıtlayan pgTAP testi yazılır.
   - Yetki kontrolü hem C#'ta hem SQL'de (`has_group_permission`) yapılır.
   - Rütbe kuralı uygulanır.
   - Rol, yaptırım, abonelik ve admin işlemleri `audit_log`'a yazılır.
   - Rate limit, webhook imza doğrulaması, KVKK (aydınlatma, açık rıza, hesap ve veri silme).
5. **Veritabanı yalnızca migration ile değişir.** Dashboard'dan elle değişiklik yapılmaz.
6. **C#'ta hatalar `Result` ile döner** ve ProblemDetails'e çevrilir. Exception yalnızca beklenmeyen durumlar içindir.
7. **Flutter'da** her feature içinde `data / domain / presentation` katmanları bulunur. Repository'ler `Result<T>` döner. Ekranlara ham hata metni gösterilmez.
8. **Kural değişecekse önce `docs/ARCHITECTURE.md` güncellenir, sonra kod yazılır.**
9. Arayüz metinleri **Türkçe**dir. Kod, değişken ve dosya adları İngilizcedir.
10. Bir işi bitirince ne yaptığını kısaca özetle ve bir sonraki adımı öner. Emin olmadığın ürün kararlarını tahmin etme; kullanıcıya sor.

---

## 5. Yol haritası

| Faz | İçerik | Durum |
|---|---|---|
| 0 | Temel: dokümanlar, workspace, tasarım sistemi, migration 0001, C# iskeleti | ✅ Bitti (2026-10-18) |
| 1 | Kimlik ve Profil: kayıt/giriş (e-posta, Google, Apple), onboarding, profil sayfası, hesap silme, admin kullanıcı yönetimi | ✅ Bitti (2026-10-18), OAuth kimlik bilgileri bekleniyor |
| 2 | Gruplar, Roller ve Üyelik: kategoriler, grup sayfası, katılım tipleri, yetki kataloğu, rol atama, rütbe kuralı | ✅ Bitti (2026-10-19) |
| 3 | Abonelik ve Paketler: paket limitleri, PayTR (yurt içi) + iyzico (yurt dışı), web'den satın alma, admin gelir görünümü | ✅ Bitti (2026-10-19), sağlayıcı anahtarları bekleniyor |
| 3.5 | Destek ve Geri Bildirim: kullanıcı ve grup yöneticisi mesajları (sorun, talep, istek), admin yanıtı ve durum | ✅ Bitti (2026-10-19) |
| 4 | Akış, Takip ve Bildirimler: gönderi, medya, beğeni/yorum, takip, keşfet, push | ✅ Bitti (2026-10-20); Android push 2026-10-26'da bağlandı, iOS (APNs) ve web (VAPID) anahtarları bekleniyor |
| 5 | Organizasyonlar ve Anketler: organizasyon, katılım, ücret bilgisi, anket, hatırlatma | ✅ Bitti (2026-10-20) |
| 6 | Moderasyon ve Disiplin Kurulu: şikayet, dosya, oylama, yaptırımlar, itiraz | ✅ Bitti (2026-10-21) |
| 7 | Canlı Sesli Yayın: LiveKit, konuşmacı/dinleyici, el kaldırma, sunucu tarafı moderasyon | ✅ Bitti (2026-10-20), kullanıcı isteğiyle Faz 4–6'dan önce |
| 8 | Organizasyon eksikleri: katılım koşulları, ekipman, onaylı katılım, takvime ekle, yeni kategoriler | ✅ Bitti (2026-10-21) |
| 9 | Takvim: kişisel ve grup takvimi, çakışma, bildirim tercihleri | ✅ Bitti (2026-10-21) |
| 10 | Organizasyon sonrası: bağlı gönderiler, değerlendirme, geçmiş | ✅ Bitti (2026-10-21) |
| 11 | Katkı ve rozetler (sunucuda doğrulanan olaylar) | ✅ Bitti (2026-10-21) |
| 12 | Görevler ve ortak hedefler | ✅ Bitti (2026-10-21) |
| 13 | Ekip arkadaşı bulma | ✅ Bitti (2026-10-21) |
| 14 | Harita ile keşif (Stadia; ücretli plan yayında onayla) | ✅ Bitti (2026-10-22) |
| 15 | Mesajlaşma: birebir ve grup içi, engelleme | ✅ Bitti (2026-10-22) |
| 15.5 | Görsel kimlik: topluluk merkezli tasarım (kullanıcı isteği) | ✅ Bitti (2026-10-22) |
| 15.6 | Eşleşme: ortak gruplardan arkadaş ve sevgili eşleşmesi, freemium (kullanıcı isteği) | ✅ Bitti (2026-10-26, dal `gelistirme/eslesme`): 15.6a çekirdek, 15.6b Tinder tarzı deste ve özellik başına ayrı ücretli paketler (eşleşmeleri görme, eşleşme sohbeti, seni beğenenler, sınırsız beğeni, süper beğeni, öne çık, hepsi bir arada; web'den satın alma) |
| 15.7 | Yönetim paneli: analiz ve denetim (kullanıcı isteği) | Duraklatıldı (dal `gelistirme/admin-analitik`): 15.7a genel bakış ve hukuki metin yönetimi bitti (2026-10-27); 15.7b modül analizleri, 15.7c denetim sırada |
| 15.8 | Güvenlik doğrulaması: zorunlu konum, ülkeye kilitli telefon doğrulaması, ikinci adım, kademeli yaptırım (kullanıcı isteği) | ✅ Kod bitti (2026-10-27, dal `gelistirme/guvenlik-dogrulama`): 15.8a sunucu, 15.8b uygulama, 15.8c yönetim paneli. Bulutta açmak için migration + hook push, Twilio anahtarları ve aydınlatma metni güncellemesi bekleniyor |
| 16 | Yapay zekâ asistanı: yalnızca maliyet ve gizlilik değerlendirmesi | |
| 17 | Yayına hazırlık: karanlık tema, performans, güvenlik testi, analitik, mağaza | |

Fazların maddeleri ve ayrıntıları: `docs/ROADMAP.md`

---

## 6. Şu anki görev

**Faz 4, 5, 6 ve 7 (Faz 7 kullanıcı isteğiyle öne alındı) tamamlandı (2026-10-21).** Açık kalanlar: Google/Apple OAuth istemci bilgileri; iOS push için APNs anahtarı ve web push için VAPID anahtarı (Firebase projesi `grupx-08706`; Android push çalışıyor); PayTR mağaza hesabı ve iyzico anahtarları; LiveKit sunucusu (üretim); KVKK, aydınlatma ve mesafeli satış metinlerinin hukuki incelemesi. Kullanıcı 2026-10-21'de topluluk hareketi planını (Faz 8–17, `docs/ROADMAP.md`) onayladı; Faz 8–15 ve kullanıcı isteğiyle Faz 15.5 (görsel kimlik) bitti; sıradaki Faz 16 (Yapay zekâ asistanı: yalnızca maliyet ve gizlilik değerlendirmesi). Proje Git deposudur: her faz kendi dalında yapılır, `main` çalışan sürümdür. Ücretli servis onaysız açılmaz.

Yerel çalıştırma:
- Repo kökü: `supabase start` (Docker gerekir), `supabase db reset`, `supabase test db`. Anahtarlar: `supabase status -o env`.
- `backend/`: `dotnet build`, `dotnet test` (DB testleri için Supabase açık olmalı). API: `Supabase__ServiceRoleKey=<SERVICE_ROLE_KEY> ASPNETCORE_ENVIRONMENT=Development ASPNETCORE_URLS=http://localhost:5089 dotnet run --project src/GrupX.Api`
- `app/`: `dart run melos run analyze`, `dart run melos run test`. Uygulama: `flutter run -d chrome --web-port 3000 --dart-define=SUPABASE_URL=http://127.0.0.1:54321 --dart-define=SUPABASE_PUBLISHABLE_KEY=<ANON_KEY> --dart-define=API_URL=http://localhost:5089` (admin paneli için `--web-port 3001`).
- Doğrulama e-postaları yerelde Mailpit'e düşer: http://127.0.0.1:54324
- Push: API'ye `Push__CredentialsPath=<Firebase servis hesabı JSON yolu>` verilir (yerelde `C:\Users\Fırat\.grupx\firebase-adminsdk.json`; repoya girmez). Yoksa push kapalıdır, bildirimler yalnızca uygulama içinde kalır. Uygulamanın Firebase yapılandırması `app/apps/social_app/lib/firebase_options.dart` ve `android/app/google-services.json`'dadır (`flutterfire configure` ile üretilir).
- Moderasyon: süresi dolan dosyaları `ModerationMonitor` dakikada bir kapatır (`Moderation__MonitorInterval`, sıfır kapatır).
- Canlı yayın: `docker run --rm -d --name grupx-livekit -p 7880:7880 -p 7881:7881 -p 7882:7882/udp livekit/livekit-server:v1.9.1 --dev --bind 0.0.0.0 --node-ip 127.0.0.1`. API'ye `LiveKit__ApiKey=devkey LiveKit__ApiSecret=secret` ortam değişkenleri verilir (adres `appsettings.Development.json`'da). Anahtarlar yoksa yayın 503 ile kapalıdır. Telefonda `adb reverse tcp:7880 tcp:7880` ve `tcp:7881` gerekir (ses TCP üzerinden akar).
- Demo verisi: `supabase/seed.sql` (`supabase db reset` ile yüklenir; yalnızca yerel). Demo kullanıcı, platform yöneticisi, örnek hesaplar, gruplar (sahiplik, roller, bekleyen istek ve davet, askıdaki grup), paket ödemeleri ve destek mesajları içerir; giriş bilgileri dosyanın başında. pgTAP testleri seed verisinden bağımsızdır.
- Telefona kurulan ev ağı APK'sı (kablo gerekmez, aynı Wi-Fi ve açık bilgisayar): sunucular bilgisayarın Wi-Fi adresiyle açılır (`ASPNETCORE_URLS=http://0.0.0.0:5089`, `LiveKit__Url=ws://<IP>:7880`, LiveKit `--node-ip <IP>`), APK `SUPABASE_URL=http://<IP>:54321` ve `API_URL=http://<IP>:5089` ile derlenir; adres `network_security_config.xml`'de şifresiz izinlidir (şu an `192.168.10.200`). Kullanıcı adındaki `ı` yüzünden APK `subst G:` ile ASCII yoldan ve `--no-tree-shake-icons` ile derlenir.
- Web'de rotalar hash ile açılır: `http://localhost:3000/#/g/doga.yuruyus`.
- `db reset` veritabanı konteynerini yeniden başlatır; çalışan API'nin ilk isteği eski bağlantı yüzünden 500 dönebilir, sonrakiler normaldir.
- Güvenlik doğrulaması (Faz 15.8, `docs/ARCHITECTURE.md` §3h): `security_settings.enforce` varsayılan kapalı, admin panelinden açılır. Twilio için `Security__Twilio__AccountSid/AuthToken/VerifyServiceSid` (isteğe bağlı `Security__Twilio__LookupLineType=true`). Anahtar yoksa Development ortamında SMS kodu API günlüğüne yazılır (`DEVELOPMENT SMS code`). Token hook'u `supabase/config.toml`'da açık; bulutta `supabase config push` ile ayrıca açılmalıdır.
- Harita: döşemeler API'den geçer (`/map/tiles`). Yerelde OpenStreetMap kullanılır (`appsettings.Development.json`, düşük hacim); yayında `Map__ApiKey` (Stadia) gerekir, yoksa harita 503 ile kapalıdır.
- Ödeme: sağlayıcı anahtarları yoksa satın alma 503 ile kapalıdır. Sandbox için `Billing__Paytr__MerchantId/MerchantKey/MerchantSalt` ve `Billing__Iyzico__ApiKey/SecretKey` (BaseUrl varsayılanı iyzico sandbox) ortam değişkenleriyle verilir. Yerelde istek 127.0.0.1'den geldiği için pazar `Geo__FallbackCountry` ile seçilir (varsayılan `TR` → PayTR; `DE` → iyzico). PayTR bildirimi ve iyzico webhook'u dışarıdan erişilebilen bir adres ister (`Billing__PublicApiUrl`, sağlayıcı panelindeki bildirim adresi).
