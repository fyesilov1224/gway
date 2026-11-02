# GWAY — Yol Haritası

Fazlar sırayla yapılır. Bir faz `docs/ARCHITECTURE.md` §9'daki "bitti" tanımını karşılamadan sonrakine geçilmez. Her fazın admin paneli karşılığı o fazın içindedir.

---

## Faz 0 — Temel

- [x] Dokümanlar: `ARCHITECTURE.md`, `ROADMAP.md`, `DESIGN.md`
- [x] Flutter pub workspace + Melos: `social_app`, `admin_panel`, `core`, `design_system`
- [x] Tasarım sistemi: renk, boşluk, yarıçap, tipografi tokenları; tema; Plus Jakarta Sans; temel bileşenler (buton, avatar, iskelet, boş durum)
- [x] `core`: `Result<T>` ve `Failure`
- [x] İki uygulamanın açılış ekranı, Riverpod + go_router kurulumu
- [x] Migration `0001_foundation.sql`: `private` şeması, `audit_log` (değiştirilemez), `platform_staff`, `private.is_platform_staff`
- [x] pgTAP testleri: RLS genel kontrolü, `audit_log` ve `platform_staff` erişim testleri
- [x] C# iskeleti: `Gway.Api` (Supabase JWT, ProblemDetails, rate limit, `/health`), `Gway.SharedKernel` (`Result`, `Error`), testler
- [x] Admin karşılığı: `admin_panel` uygulaması ve `platform_staff` tablosu
- [x] Yerel doğrulama (2026-10-18): `flutter analyze` temiz, Flutter 34/34 test, `dotnet build` 0 hata 0 uyarı, C# 19/19 test, pgTAP 28/28 test, gerçek Supabase token'ıyla `/me` uçtan uca doğrulandı

## Faz 1 — Kimlik ve Profil

- [x] Kayıt ve giriş: e-posta + şifre (doğrulama zorunlu, şifre sıfırlama), Google, Apple
- [ ] Google ve Apple OAuth istemci bilgileri (`SUPABASE_AUTH_EXTERNAL_*`) girilip gerçek cihazda denenecek
- [x] KVKK: sürümlü hukuki metinler, onay ekranı, "Hukuki metinler" sayfası (metinler **taslak**, hukuki inceleme bekliyor)
- [x] Onboarding: ad, kullanıcı adı (anlık uygunluk kontrolü), avatar, ilgi alanları (ortak `categories`)
- [x] Profil sayfası: kapak, avatar, ad, @kullanıcı adı, biyografi, katılım tarihi, ilgi alanları (gruplar Faz 2'de, gönderiler Faz 4'te eklenecek)
- [x] Profil düzenleme: fotoğraflar, ad, kullanıcı adı (30 günde bir), biyografi, ilgi alanları
- [x] Hesap silme: 30 gün bekleme, geri alma, saatlik kalıcı silme işi (storage dahil), audit log
- [x] Admin: platform ekibi girişi ve yetki kontrolü, kullanıcı arama/listeleme, detay (onaylar, geçmiş), askıya alma ve askıyı kaldırma (Auth ban + oturum sonlandırma), audit log
- [x] Doğrulama (2026-10-18): `flutter analyze` temiz, Flutter 73/73, `dotnet build` 0 hata 0 uyarı, C# 36/36, pgTAP 88/88, uçtan uca API senaryosu 32/32, iki uygulamanın web derlemesi

## Faz 2 — Gruplar, Roller ve Üyelik

Ürün kararları (2026-10-19): davet yalnızca uygulama içi (kullanıcı adıyla), tüm gruplar herkese görünür, grubun tek kategorisi var, rolleri yalnızca grup sahibi atar. Ayrıntılar: `ARCHITECTURE.md` §3b.

- [x] Kategoriler: ortak `categories` (core); grup başına tek kategori, keşfette kategori filtresi
- [x] Grup oluşturma (anlık adres uygunluk kontrolü) ve grup profil sayfası: kapak, logo, tanıtım, kurallar, bağlantılar, yönetim ekibi
- [x] Katılım tipleri: serbest, istekle (onay/ret, geri alma), davetle (kullanıcı adıyla davet, kabul/ret, geri alma); gruptan ayrılma
- [x] Yetki kataloğu (`group_permissions`, `group_role_permissions`), `private.has_group_permission`, `public.my_group_permissions`
- [x] Roller: Sahip (100), Yönetici (80), Disiplin Kurulu (60), Moderatör (50), Üye (10). Bir üyenin birden fazla rolü olabilir.
- [x] Rol atama ve alma, sahiplik devri, grup silme (C# API); rütbe kuralı C#'ta ve trigger'larda
- [x] Grup düzenleme: görseller (`group-images`), ad, kategori, katılım tipi, tanıtım, kurallar, bağlantılar
- [x] Profil sayfasında "Gruplar" bölümü; sosyal uygulamada alt gezinme (Gruplar / Profil)
- [x] Grup sahibi hesap silme isteğinde bulunamaz (önce devir ya da silme)
- [x] Admin: grup listesi (sayaçlar, arama, durum filtresi), detay (bilgiler, yönetim ekibi, işlem geçmişi), askıya alma ve askıyı kaldırma
- [x] Doğrulama (2026-10-19): `flutter analyze` temiz, Flutter 100/100, `dotnet build` 0 hata 0 uyarı, C# 73/73, pgTAP 150/150, uçtan uca senaryo 27/27 (Flutter sorguları gerçek şemada + API), iki uygulamanın web derlemesi ve ekran kontrolü

## Faz 3 — Abonelik ve Paketler

Ürün kararları (2026-10-19): yurt içi PayTR (TL), yurt dışı iyzico (USD), pazar isteğin IP'sinin ülkesine göre sunucuda belirlenir; dört paket (Ücretsiz, Başlangıç, Pro, Topluluk); ön ödemeli aylık/yıllık dönem, otomatik yenileme yok; yükseltme hemen başlar ve kalan süre fiyatla oranlanarak aktarılır; limit aşımında kimse çıkarılmaz, yeni üye alınmaz. Ayrıntılar: `ARCHITECTURE.md` §7.

- [x] Paket tanımları ve limitleri (`plans`, `plan_prices`): maksimum üye, aylık organizasyon, aylık yayın dakikası; TRY ve USD, aylık ve yıllık fiyat
- [x] Ücretsiz paket varsayılanı; grubun paketi zaman çizelgesinden (`group_subscriptions`) hesaplanır, süre bitince kendiliğinden Ücretsiz'e döner
- [x] Pazar: IP → ülke (güvenilir proxy başlığı, MaxMind DB biçimli ülke veritabanı, varsayılan ülke); `X-Forwarded-For` yalnızca tanımlı proxy'lerden
- [x] PayTR (iFrame API, token ve bildirim hash'i) ve iyzico (Checkout Form, IYZWSv2, ödeme detayı sorgusu, `X-IYZ-SIGNATURE-V3` webhook); ödeme yalnızca sunucu tarafında kesinleşir, idempotent, tutar/para birimi kontrolü
- [x] Yükseltme, yenileme ve alt pakete geçiş kuralları; teklif ekranında tahmini tarihler ve aktarılan süre
- [x] Web'den satın alma (paket ekranı, ödeme ekranı: fatura bilgileri, Ön Bilgilendirme Formu ve Mesafeli Satış Sözleşmesi onayı, sağlayıcıya yönlendirme, dönüşte durum takibi); mobilde yalnızca durum
- [x] Grup sayfasında paket kartı (sahip), limit dolunca uyarı (onay yetkisi olanlar), bitişe 7 gün kala hatırlatma; web'de "Paket al" / "Paketi yükselt" butonu ve Gruplar ekranında sahibin gruplarını paketleriyle listeleyen "Paketler" sekmesi (kullanıcı isteği, 2026-10-28)
- [x] Admin: grup sayfasından gruba istenen paketi gün sayısıyla tanımlama ve grubun bütün paketini iptal etme; açıklama zorunlu, tanımlama ve iptal gerekçeleri veritabanında (`grant_reason`, `cancel_note`, migration `0045`; pgTAP `35_group_plan_grants`, C# ve Flutter testleri; kullanıcı isteği, 2026-10-28)
- [x] Limit koruması: üye limiti API'de (`IGroupPlanLimits`) ve `group_members` trigger'ında; organizasyon ve yayın dakikası limitleri Faz 5 ve 7'de bağlanacak
- [x] Admin: Abonelikler (bu ayın geliri, son 12 ayın aylık geliri, bekleyen ödemeler, ödeme ve abonelik listeleri), Paketler (limit, fiyat, satış durumu düzenleme), grup detayında paket ve zaman çizelgesi, iade işaretli abonelik iptali
- [x] Doğrulama (2026-10-19): `flutter analyze` temiz, Flutter 119/119, `dotnet build` 0 hata 0 uyarı, C# 105/105, pgTAP 207/207, uçtan uca senaryo 41/41 (gerçek veritabanı ve API, yerel sahte PayTR/iyzico, DB-IP Lite ile IP → ülke), iki uygulamanın web derlemesi ve ekran kontrolü
- [x] Bağlantıya hazırlık (2026-10-28): admin panelinde "Ödeme sağlayıcıları" kartı (durum, panele girilecek bildirim adresleri, eksikler, "Bağlantıyı dene"), açılışta kurulum günlüğü, imzası tutmayan bildirim uyarısı, yerel anahtar betiği (`backend/scripts/payment-keys.ps1`), rehber `docs/PAYMENTS.md`
- Açık: PayTR mağaza hesabı ve iyzico sandbox/canlı anahtarları; mesafeli satış ve aydınlatma metinlerinin hukuki incelemesi; e-Arşiv fatura (v1 kapsamı dışı)

## Faz 3.5 — Destek ve Geri Bildirim

Kullanıcı isteğiyle Faz 4'ten önce eklendi (2026-10-19). Kararlar: renk türü gösterir (Sorun kırmızı, Talep sarı, İstek yeşil), veriler `support` modülünün kendi tablolarında, ekip yanıtı ve durum kullanıcıya görünür, en fazla 3 ekran görüntüsü. Ayrıntılar: `ARCHITECTURE.md` §7b.

- [x] Mesaj açma (tür, konu, açıklama, en fazla 3 ekran görüntüsü; grup yöneticileri için grup seçimi), kendi mesajlarını ve yanıtları görme, yanıt yazma (`support_tickets`, `support_messages`, RPC `create_support_ticket`, `my_managed_groups`)
- [x] Okunmamış yanıt işareti; Ayarlar'da ve grup sayfasında giriş noktası
- [x] Kötüye kullanım sınırları (günde 5 mesaj, saatte 20 yanıt), gizli ek deposu (`support-attachments`), hesap silinince mesajlar ve ekler temizlenir
- [x] Admin: türe göre renkli sayaçlar ve liste (tür, durum, arama, yanıt bekleyenler önce), yazışma ve ekler, yanıt ve durum değiştirme, audit log (`support.replied`, `support.status_changed`)
- [x] Tasarım sistemi: `warning` (sarı) ve `success` (yeşil) tokenları, AA kontrast testleriyle
- [x] Düzeltme (Faz 1): saatlik hesap silme işi, veritabanı kısa süre erişilemez olduğunda artık API'yi durdurmuyor; hatayı kaydedip sonraki turda tekrar deniyor
- [x] Doğrulama (2026-10-19): `flutter analyze` temiz, Flutter 135/135, `dotnet build` 0 hata 0 uyarı, C# 109/109, pgTAP 244/244, uçtan uca senaryo 26/26 (gerçek RLS ve Storage, admin API), iki uygulamanın web derlemesi ve ekran kontrolü

## Faz 4 — Akış, Takip ve Bildirimler

Ürün kararları (2026-10-19): Instagram takip modeli (açık/gizli hesap, istek, engelleme, karşılıklı takip "Arkadaş"); video Supabase Storage'da (60 sn, 50 MB); çoklu medya, kaydetme, etiket ve bahsetme, yorum yanıtları; hikayeler ve öne çıkanlar; keşfet; uygulama içi bildirimler; grup gönderileri ve grup takibi. Ayrıntılar: `ARCHITECTURE.md` §3c.

- [x] Takip: açık/gizli hesap, istek kabul/ret, takipçi çıkarma, engelleme, arkadaş göstergesi, takipçi/takip listeleri, kullanıcı arama ve takip butonu
- [x] Gönderi: 10'a kadar fotoğraf/video, açıklama, etiket, bahsetme, düzenleme, silme, yorumları kapatma, beğeni sayısını gizleme
- [x] Beğeni (çift dokunma), yorum, yanıt, yorum beğenisi, kaydetme, paylaşım bağlantısı
- [x] Hikayeler (24 saat), görenler, arşiv, öne çıkanlar
- [x] Ana akış, keşfet, etiket sayfaları, önerilen hesaplar
- [x] Grup gönderileri (`posts.publish`), grup takibi
- [x] Uygulama içi bildirimler. Push bildirimleri (FCM): Android 2026-10-26'da bağlandı (`push_devices`, C# `PushDispatcher`); iOS için APNs, web için VAPID anahtarı bekleniyor. Admin: "Bildirimler" sayfası (push durumu, cihazlar, son 24 saatte teslim ve kuyruk, tür dağılımı).
- [x] Admin: içerik görüntüleme, kaldırma ve geri alma, yorum kaldırma
- [x] Doğrulama (2026-10-20): `flutter analyze` temiz, tüm Flutter testleri geçiyor, `dotnet build` 0 hata 0 uyarı, C# 129/129, pgTAP 392/392

## Faz 5 — Organizasyonlar ve Anketler

Ürün kararları (2026-10-20): organizasyonları herkes görür, yalnızca üyeler katılır; kapasite dolunca bekleme listesi; anketlerde çoklu seçim, gizli oy, bitiş zamanı ve organizasyona bağlı anket; hatırlatmalar 1 gün ve 1 saat önce. Ayrıntılar: `ARCHITECTURE.md` §3d.

- [x] Organizasyon: başlık, açıklama, tarih ve saat (bitiş isteğe bağlı), yer ve harita/çevrim içi bağlantı, kapasite, kapak görseli (`event-images`); düzenleme ve iptal (`events.manage`)
- [x] Katılım ve kapasite kontrolü; bekleme listesi ve otomatik sıra yükseltme (trigger), gruptan ayrılınca gelecek katılımların silinmesi
- [x] Katılım ücreti bilgisi (yalnızca bilgi, para toplanmaz; ekranda açıkça yazar)
- [x] Aylık organizasyon limiti (paket, Türkiye saatiyle takvim ayı, C# + trigger)
- [x] Anketler: 2–10 seçenek, çoklu seçim, gizli oy, bitiş zamanı, organizasyona bağlı anket; oy kullanıcının kendi yazması (RLS), sonuçlar ve açık ankette oy verenler
- [x] Bildirimler ve hatırlatmalar: `event_promoted`, `event_updated`, `event_canceled`, `event_reminder` (1 gün ve 1 saat önce, `EventReminderService`)
- [x] Arayüz: grup sayfasında Organizasyonlar ve Anketler bölümleri, organizasyon sayfası (`/e/<id>`), oluşturma/düzenleme formu
- [x] Admin: organizasyonlar sayfası (arama, yaklaşan/geçmiş/iptal filtresi), platform ekibinin iptali (audit log)
- [x] Doğrulama (2026-10-20): `flutter analyze` temiz, tüm Flutter testleri geçiyor (events 10, admin 37), `dotnet build` 0 hata 0 uyarı, C# 135/135, pgTAP 427/427; gerçek API ve Supabase ile uçtan uca deneme (oluşturma, katılım, bekleme listesi, anket ve oy, organizasyon ve grup sayfaları)

## Faz 6 — Moderasyon ve Disiplin Kurulu

Kararlar (2026-10-21):
- Grupla ilgili şikayet grubun moderasyonuna, grup dışındaki şikayet platform ekibine gider.
- Kurulu Disiplin Kurulu üyeleri 72 saat oylar; kurulu olmayan grupta sahip karar verir.
- İtirazı sahip karara bağlar; sahip dosyada tarafsa platform ekibi bağlar.
- Oylamasız tek yaptırım, dosya açarak uygulanan 24 saatlik acil susturmadır.

Ayrıntılar: `ARCHITECTURE.md` §3e.

- [x] Şikayet: gönderi, yorum, organizasyon, canlı yayın yorumu ve kullanıcı. Kullanıcının kendi yazmasıdır (RLS). Hedeften grup, kişi ve kanıt kopyası doldurulur. Günde 20 şikayet sınırı vardır; şikayet eden gizli kalır.
- [x] Ön inceleme (`reports.review`): reddetme, şikayet edilen yorumu ya da canlı yayın yorumunu kaldırma (rütbe kuralı), dosya açma. Aynı hedefin şikayetleri birlikte kapanır.
- [x] Disiplin dosyası ve kurul oylaması: oy verenler dosya açılırken belirlenir (kurul, yoksa sahip). Karar eşiği salt çoğunluk, üçte iki ya da oybirliğidir; sahip ayarlar. Erken karar ya da 72 saat sonunda verilen oylara göre karar çıkar. `ModerationMonitor` süresi dolanları kapatır.
- [x] Yaptırımlar: uyarı, susturma (1–90 gün), çıkarma, ban (1–365 gün ya da kalıcı). Ban katılmayı, isteği ve daveti engeller; susturma grup yorumlarını ve canlı yayında konuşmayı kapatır. Groups, feed ve live trigger'larına ve C# servislerine bağlandı.
- [x] Acil susturma (`members.mute`): dosya açılırken 24 saate kadar uygulanır, karar çıkınca kalkar. Kişi yayındaysa hemen sahneden iner; çıkarılan ya da banlanan kişi odadan atılır.
- [x] İtiraz: 7 gün içinde bir kez yapılır. Sahip karar verir; sahip tarafsa platform ekibi karar verir. Kaldırılan yaptırım biter.
- [x] Bildirimler: `case_vote`, `sanction_applied`, `appeal_submitted`, `appeal_decided`.
- [x] Arayüz:
  - "Şikayet et" alt sayfası: gönderi, yorum, profil, organizasyon, canlı yayın yorumu ve üye menüsünde.
  - Grup sayfasında moderasyon kartı.
  - Moderasyon ekranı (`/g/<handle>/moderation`): şikayetler, dosyalar ve oylama, yaptırımlar ve itirazlar, karar eşiği.
  - Üye menüsünde "Disiplin dosyası aç".
  - "Grup yaptırımlarım" (`/me/sanctions`) ve itiraz.
- [x] Admin: Şikayetler sayfası (kapsam ve durum filtresi, şikayet eden ve hedef, reddet / işlem yapıldı) ve platformun itirazları.
- [x] Doğrulama (2026-10-21): `flutter analyze` temiz, tüm Flutter testleri geçiyor (moderation 7, admin 41, groups 17), `dotnet build` 0 hata 0 uyarı, C# 141/141, pgTAP 485/485; gerçek API ve Supabase ile uçtan uca deneme (şikayet, gizli şikayet eden, dosya ve acil susturma, kurul oyu, yaptırım, itiraz, moderasyon ekranı ve Yaptırımlarım). Migration `0013` itiraz kuralını `SECURITY DEFINER` yapan düzeltmedir.
- [x] Yasa dışı faaliyet ve platform bildirimi (kullanıcı kararı, 2026-10-28; `ARCHITECTURE.md` §3e): ban dosyası kategoriyle işaretlenir, onaylanınca hesap askıya alınır ve kanıtlı `platform_referrals` kaydı açılır. Admin panelinde Şikayetler → "Yasa dışı": banla (süreli ya da kalıcı; kişisel paketler ve sahibi olduğu grupların paketleri iadesiz iptal, gruplar askıya) ya da temize çıkar, kolluk durumu ve kaydı. Kayıtta ve mevcut kullanıcılara onaylatılan `community_rules` sözleşmesi; onay kutusu metin sonuna kadar okunmadan işaretlenmez. Migration `0046`; pgTAP `36_platform_referrals`, C# ve Flutter testleri. Doğrulama (2026-10-28): `flutter analyze` temiz, 17 Flutter paketinin testleri geçiyor, `dotnet build` 0 hata 0 uyarı, C# 210/210, pgTAP 869/869. Metin taslaktır, hukuki incelemeden geçmelidir.

## Faz 7 — Canlı Sesli Yayın

Kullanıcı isteğiyle Faz 4–6 bitmeden yapıldı (2026-10-20). Kararlar: yayını grup sahibi ve Yöneticiler başlatır, yalnızca grup üyeleri katılır; emoji tepkileri, yazılı yorumlar ve planlı yayın (hatırlatmalı) vardır. Ayrıntılar: `ARCHITECTURE.md` §8.

- [x] LiveKit; C#'ta token üretimi (yalnızca mikrofon, öznitelikleri yalnızca sunucu değiştirir) ve oda yönetimi (Twirp API, SDK'sız)
- [x] Konuşmacı / dinleyici, el kaldırma, sahneye alma ve indirme (sahnede en fazla 10 kişi)
- [x] Sunucu tarafı moderasyon: mikrofon kapatma / açma, odadan atma, yorum silme, yayını bitirme; rütbe kuralı C#'ta ve trigger'larda (`live.start`, `live.moderate`)
- [x] Atılan kullanıcıya o yayın için token verilmemesi. Gruptan ban ve susturma Faz 6'da bu kontrole bağlanır.
- [x] Yayın dakikası paket limiti (Türkiye saatiyle takvim ayı, C# + trigger); dakika dolunca yayın kendiliğinden biter
- [x] Gözetim: odası kapanan, sunucusu 2 dakikadan uzun ayrılan ve dakikası dolan yayınları bitirir; zamanı geçen planlı yayını iptal eder
- [x] Emoji tepkileri (LiveKit veri mesajı), yazılı yorumlar (Realtime), planlı yayın; planlanınca ve başlayınca bütün üyelere `live_scheduled` / `live_started` bildirimi, uygulama açıkken sesli uyarı (2026-10-26)
- [x] Arayüz: grup sayfasında canlı kartı, yaklaşanlar ve "Yayın başlat"; ana sayfada canlı yayınlar şeridi; yayın odası (sahne, dinleyiciler, konuşma halkası, yönetici menüsü, tepkiler, yorumlar)
- [x] Admin: şu an canlı yayınlar (katılımcı sayısıyla), planlı yayınlar (zaman ve duyurulan üye sayısı, 2026-10-26), geçmiş, acil kapatma (audit log)
- [x] Doğrulama (2026-10-20): `flutter analyze` temiz, tüm Flutter testleri geçiyor (live 10, admin 34), `dotnet build` 0 hata 0 uyarı, C# 129/129, pgTAP 392/392; gerçek LiveKit ile iki kullanıcılı uçtan uca deneme (bağlanma, mikrofon yayını, el kaldırma, sahneye alma, Realtime yorum)

## Topluluk hareketi planı (2026-10-21)

Ürün vaadi: "Yalnızca paylaşım yapma; topluluğunu bul, ekibini kur ve birlikte harekete geç." Mevcut kod incelendi. Organizasyon, takvim verisi, moderasyon ve yönetim araçlarının büyük kısmı zaten vardı. Bu yüzden yeni modüller mevcut tabloların üzerine kurulur; ikinci bir etkinlik, gönderi, profil ya da bildirim sistemi yazılmaz.

Kararlar:
- Sıra aşağıdaki gibidir; mesajlaşma ekip arkadaşı bulmanın arkasına alındı.
- Gizli topluluk şimdilik yoktur.
- Motosiklet, kamp ve satranç kategorileri eklenir.
- Ücretli servis (harita sağlayıcısı, yapay zekâ) kullanıcı onayı olmadan açılmaz.
- Kişilerin konumu tutulmaz.

## Faz 8 — Organizasyon Eksikleri

- [x] Katılım koşulları ve gerekli ekipman (trigger ile kırpma ve sınırlar)
- [x] İsteğe bağlı onaylı katılım: `requested` durumu, yönetici onayı (kapasiteye göre katılımcı ya da bekleme listesi) ve reddi, `event_approved` / `event_declined` bildirimleri, audit log
- [x] "Takvime ekle": `GET /events/{id}/calendar.ics` (RFC 5545, oturumsuz, paket gerektirmez)
- [x] Yeni kategoriler: Motosiklet, Kamp, Satranç; organizasyon sayfasında grubun kategorisi
- [x] Admin: organizasyon listesinde onaylı katılım ve bekleyen istek sayısı
- [x] Doğrulama (2026-10-21): `flutter analyze` temiz, tüm Flutter testleri geçiyor (events 13), `dotnet build` 0 hata 0 uyarı, C# 143/143, pgTAP 507/507; gerçek API ile uçtan uca deneme (onaylı organizasyon, istek, onay, takvim dosyası, iki rolün ekranı)

## Faz 9 — Takvim

- [x] Kişisel takvim ("Takvimim", ana sayfa üst çubuğundan; isteğe bağlı olarak gruplarımın tüm organizasyonları) ve grup takvimi (Organizasyonlar bölümünden); gün, hafta ve ay görünümü
- [x] Çakışma: takvimde "Çakışıyor" işareti, organizasyon sayfasında "Bu saatte başka bir organizasyonun var"
- [x] Bildirim tercihleri (Ayarlar → Bildirim tercihleri): 1 gün önce, 1 saat önce, değişiklik ve iptaller; kapalı türde kayıt hiç oluşmaz
- [x] Takvim organizasyon tablolarını okur (`calendar_events`); ayrı veri kaynağı yok, C# değişikliği gerekmedi
- [x] Admin: gerekmedi; takvim kişisel bir görünüm, organizasyonlar admin panelinde zaten var
- [x] Doğrulama (2026-10-21): `flutter analyze` temiz, tüm Flutter testleri geçiyor (events 17, notifications 7), C# 143/143, pgTAP 523/523; gerçek veriyle uçtan uca deneme (Ayşe'nin takvimi, aynı gündeki iki organizasyonun çakışması, tercih ekranı)

## Faz 10 — Organizasyon Sonrası

- [x] Anılar: organizasyona bağlı gönderiler (mevcut gönderi altyapısı; yalnızca katılanlar ve yöneticiler, organizasyon başladıktan sonra; C# + trigger), organizasyon sayfasında "Anılar" ve "Anı paylaş", gönderi kartında "Anı · organizasyon"
- [x] Değerlendirme: katılanlar bitişten sonra 30 gün içinde 1–5 yıldız ve yöneticilere not; herkes yalnızca ortalamayı görür; "Nasıldı?" bildirimi (tercihlerden kapatılabilir)
- [x] Özet ("Nasıl geçti?"), grubun sıradaki organizasyonları önerisi ve "Geçmiş organizasyonlar" sayfası
- [x] Admin: organizasyon listesinde puan ortalaması ve anı sayısı
- [x] Düzeltme: uygulamanın "upsert" ile kaydettiği bildirim tercihleri ve değerlendirmeler için eksik sütun yetkisi (migration 0018; Faz 9'dan kalan hata uçtan uca denemede bulundu)
- [x] Doğrulama (2026-10-21): `flutter analyze` temiz, tüm Flutter testleri geçiyor (events 19), `dotnet build` 0 hata 0 uyarı, C# 144/144, pgTAP 544/544; gerçek API ile uçtan uca deneme (anı yükleme ve paylaşma, değerlendirme, değerlendirme isteği, katılan ve yönetici ekranları, geçmiş)

## Faz 11 — Katkı ve Rozetler

Kararlar (2026-10-21): organizasyon bitince "katılıyor" görünen herkes katılmış sayılır, düzenleyen gelmeyenleri işaretler; rozetler görünür, sıralama yoktur.

- [x] Yoklama: yönetici bitişten sonra 7 gün içinde "gelmedi" işaretler ya da kaldırır (C# + trigger, audit log); gelmeyen değerlendirme ve anı ekleyemez
- [x] Katkı puan tablosunda tutulmaz, kayıtlardan hesaplanır: katılım, düzenleme (en az 2 katılımcı), anı, değerlendirme; beğeni ve takipçi sayılmaz
- [x] Rozetler tek katalogdan (`badge_catalog`): İlk adım, Müdavim, Yol arkadaşı, Kâşif, Düzenleyici, Usta düzenleyici, Anı biriktiren, Geri bildirimci, `<Kategori>` tutkunu
- [x] Profilde "Topluluk katkısı" ve "Rozetler nasıl kazanılır?"; grup üye listesinde gruptaki katılım ve düzenleme; organizasyon sayfasında yoklama; gizli hesabın katkısı gizli
- [x] Admin: kullanıcı detayında katkı sayıları ve "gelmedi" işaretleri
- [x] Doğrulama (2026-10-21): `flutter analyze` temiz, tüm Flutter testleri geçiyor (events 22, groups 18), `dotnet build` 0 hata 0 uyarı, C# 145/145, pgTAP 561/561; gerçek API ile uçtan uca deneme (yoklama ve geri alma, üyenin yoklama alamaması, profil rozetleri, yoklama ekranı, üye listesi)

## Faz 12 — Görevler ve Ortak Hedefler

Kararlar (2026-10-21): kişisel, grup, takım hedefleri ve onaylı görevler; hedefleri sahip ve Yöneticiler açar; ödül görev rozetidir.

- [x] Hedefler: başlık, açıklama, tür, ölçüt (katılım, düzenleme, anı), hedef sayı, en fazla 92 günlük dönem; grupta en fazla 5 aktif hedef (C# + trigger, audit log)
- [x] İlerleme sunucuda, Faz 11 katkı kurallarıyla ve yalnızca o grubun dönemindeki kayıtlardan sayılır; istemci ilerleme yazamaz
- [x] Takım hedefi: yönetici takımları kurar (üye bir hedefte tek takımda), takımın ortak sayacı
- [x] Onaylı görev: üye "Yaptım" ve not (RLS), yönetici onaylar ya da reddeder
- [x] Tamamlanma kalıcı kaydedilir (iş + görev onayı), `goal_completed` bildirimi ve profilde "Hedef: …" rozeti
- [x] Arayüz: grup sayfasında "Hedefler" ve "Hedef oluştur", hedef sayfası (`/goals/<id>`) ilerleme, takımlar, bildirimler ve tamamlayanlarla
- [x] Admin: "Hedefler" sayfası (durum filtresi, tamamlayan sayısı, iptal)
- [x] Düzeltme: metin girilen iki pencere (görev bildirimi, organizasyon iptali) kapanırken silinmiş denetleyiciyi kullanıyordu; testler yakaladı
- [x] Doğrulama (2026-10-21): `flutter analyze` temiz, tüm Flutter testleri geçiyor (events 26, admin 42), `dotnet build` 0 hata 0 uyarı, C# 146/146, pgTAP 583/583; gerçek API ile uçtan uca deneme (üç hedef, görev bildirimi, tamamlanma ve rozet, yönetici ekranı)

## Faz 13 — Ekip Arkadaşı

Kararlar (2026-10-21): önerilerde yalnızca "Ekip arıyorum"u açanlar görünür; il isteğe bağlıdır, yalnızca eşleştirmede kullanılır ve profilde görünmez; kabul edilen istek takipten ayrı bir "Ekip arkadaşları" ilişkisi kurar.

- [x] Tercihler (RLS, yalnızca sahibi okur): "Ekip arıyorum", seviye, uygun zamanlar, 81 ilden biri, 140 karakter not; Ayarlar → "Ekip arkadaşı tercihleri"
- [x] Açıklanabilir öneriler: ortak ilgi, il, grup, seviye ve zaman puanı; her öneri nedenleriyle gösterilir. Gizli, engelli, pasif hesaplar ve mevcut ilişkiler elenir; il hiçbir yanıtta dönmez
- [x] İstek (C# + trigger): 200 karakter mesaj; 24 saatte 20 istek ve aynı kişiye bir istek (geri çekilenler de sayılır); kabul, ret, geri çekme, karşılıklı istekte otomatik kabul; ekip arkadaşlığını bitirme
- [x] Engelleme istekleri ve ekip arkadaşlığını siler; şikayet profildeki "Şikayet et" ile
- [x] Bildirimler: `teammate_request`, `teammate_accepted`; geri çekilen isteğin bildirimi silinir
- [x] Arayüz: "Ekip arkadaşı bul" (ana akıştan; Öneriler / İstekler / Ekibim), profilde "Ekip arıyor · seviye" ve "Ekip arkadaşın" rozetleri, menüde istek işlemleri, kendi profilinde bekleyen istek uyarısı
- [x] Admin: kullanıcı ayrıntısında "Ekip arkadaşı" paneli (arıyor mu, ekip sayısı, son 24 saatte gönderilen ve bekleyen istekler; il gösterilmez)
- [x] Düzeltme (0022): uçtan uca denemede tekrar eden "kabul etti" bildirimleri görüldü; geri çekme ile günlük sınırın aşılabildiği fark edildi. İstek günlüğü ve bildirim temizliği eklendi
- [x] Doğrulama (2026-10-21): `flutter analyze` temiz, tüm Flutter testleri geçiyor (profile 15), `dotnet build` 0 hata 0 uyarı, C# 148/148, pgTAP 612/612; gerçek API ile uçtan uca deneme (tercihler, öneri nedenleri, istek, kabul, rozetler, bildirim, yönetici paneli)

## Faz 14 — Harita ile Keşif

Kararlar (2026-10-21): sağlayıcı karşılaştırması sonrası flutter_map + Stadia Maps (geliştirme ücretsiz planda; ücretli plan yayına çıkarken onayla); grubun konumu il, buluşma noktası haritada iğne, adres arama yok; haritada yalnızca gelecekteki açık organizasyonlar ve aktif gruplar.

- [x] İller tablosu (81 il, merkez koordinatı); grubun ili (oluşturma ve düzenleme, `group.edit`, trigger)
- [x] Organizasyonun buluşma noktası (iğne, isteğe bağlı; düzenleme kuralları diğer alanlarla aynı)
- [x] Harita verisi (`map_items`): görünen alandaki aktif gruplar ve gelecekteki açık organizasyonlar, kategori filtresi
- [x] Döşemeler C# API üzerinden: anahtar sunucuda, kullanıcının IP'si sağlayıcıya gitmez; bellek önbelleği, kişi başı dakikada 600 istek
- [x] Arayüz: "Harita" (Gruplar sayfasından; harita ve liste görünümü, aynı ildeki grupları birleştiren işaretçi), organizasyon sayfasında küçük harita ve "Yol tarifi", formda iğne seçici, grup formunda il, grup sayfasında il; atıf her haritada
- [x] Admin: organizasyon listesinde buluşma noktası ve "Buluşma noktasını kaldır" (admin, moderatör; audit log), grup ayrıntısında il
- [x] Düzeltmeler: harita ilk açılışta Türkiye'nin batısını kesiyordu (artık sınırlara sığdırılıyor); grup işaretçisinin seçimi her çizimde kayboluyordu; atıf dar ekranda taşıyordu
- [x] Doğrulama (2026-10-22): `flutter analyze` temiz, tüm Flutter testleri geçiyor (events 31), `dotnet build` 0 hata 0 uyarı, C# 151/151, pgTAP 632/632; gerçek API ile uçtan uca deneme (iller, buluşma noktası, döşeme proxy'si, harita, liste, organizasyon sayfası)

## Faz 15 — Mesajlaşma

Kararlar (2026-10-22): ekip arkadaşları ve karşılıklı takipleşenler doğrudan yazar, diğerlerinin ilk mesajı "Mesaj istekleri"ne düşer; her grubun tek sohbeti vardır; mesaj metin ve fotoğraftır; şikayet edilen mesajda platform ekibi yalnızca o mesajı ve önceki 5 mesajı görür.

- [x] Birebir sohbet (C# + trigger): istek kutusu, kabul ve ret, gizli hesaba yalnızca takipçiler, günde 20 yeni istek, dakikada 30 mesaj
- [x] Grup sohbeti: grup oluşunca açılır, yalnızca üyeler okur ve yazar; susturulan üye yazamaz; "Yalnızca yöneticiler yazsın" (`group.edit`, audit log)
- [x] Mesaj: metin (2.000 karakter) ve tek fotoğraf (özel depo, imzalı adres); kendi mesajını herkesten silme; okundu bilgisi ("Görüldü", istek kabul edilene kadar gizli); Realtime ile anlık güncelleme
- [x] Engelleme: iki yönde de yazılamaz, yeni sohbet açılamaz, engellenenin grup mesajları gösterilmez; hesap silinince mesajlar da silinir
- [x] Şikayet: grup sohbeti mesajı grubun moderasyon masasına (kaldırma, rütbe kuralı), birebir mesaj platform ekibine
- [x] Arayüz: ana akışta okunmamış sayılı mesaj ikonu, "Mesajlar" (Sohbetler / İstekler), sohbet ekranı (fotoğraf, gün ayracı, uzun basınca kopyala / sil / şikayet et), profilde mesaj butonu, grup sayfasında "Grup sohbeti"
- [x] Admin: şikayetlerde "Mesajı incele" (mesaj ve önceki 5 mesaj; her görüntüleme audit log'a yazılır) ve "Mesajı kaldır" (admin, moderatör)
- [x] Doğrulama (2026-10-22): `flutter analyze` temiz, tüm Flutter testleri geçiyor (messaging 8), `dotnet build` 0 hata 0 uyarı, C# 156/156, pgTAP 669/669; gerçek API ile uçtan uca deneme (arkadaşla sohbet, fotoğraf, istek ve kabul öncesi yanıt engeli, grup sohbeti, "Görüldü", şikayet, admin incelemesi ve kaldırma)

## Faz 15.5 — Görsel Kimlik (kullanıcı isteği)

Karar (2026-10-22): arayüz X ve Instagram kalıbından çıkarılır, **topluluk merkezli** bir düzene geçer. Palet (mor, mavi, siyah, beyaz) ve Plus Jakarta Sans korunur; özgünlük düzenden, kartlardan, tonlardan ve hiyerarşiden gelir. Veri, API ve modül sınırları değişmez.

- [x] Tasarım sistemi: hafif tonlu zemin ve beyaz kartlar (`GwCard`), kimlik tonları (`GwTone`), `GwHeroCard` (kapak kartın içinde, avatar adın yanında; X tarzı taşan avatar yok), `GwSectionHeader`, `GwDateTile`, `GwTag`; hap seçici sekmeler, yuvarlak köşeli ızgara (3 sütun, 8 boşluk)
- [x] Gezinme: telefonda yüzen dok (Bugün, Gruplar, ortada Paylaş, Takvim, Ben), geniş ekranda etiketli yan menü (Bildirimler, Mesajlar, Paylaş ve "Gruplarım"); yan menü tam ekran medya ve yayın odası dışında her sayfada kalır
- [x] "Bugün" ana sayfası: selamlama, Şimdi canlı, Yaklaşanlar (gruplarının organizasyonları), Hikâyeler (küçük çipler), Akış; bildirimler, mesajlar ve arama üst çubukta
- [x] Gönderi kartı: kart içinde medya, başlıkta zaman, sayılı beğeni / yorum / paylaş
- [x] Profil ve grup sayfası: kimlik kartı, profilde istatistik kutuları ve ilgi alanı etiketleri, grup araçları ve bölümler ayrı kartlarda; öne çıkanlar çip rafı
- [x] Giriş ve kayıt: geniş ekranda tanıtım paneli, form kartı (admin girişinde tanıtım yok)
- [x] Admin paneli: yeni tema ve giriş kartı; ek ekran gerekmedi
- [x] Doğrulama (2026-10-22): `flutter analyze` temiz, tüm Flutter testleri geçiyor, telefon (420) ve geniş (1440) ekran görüntüleriyle kontrol

## Faz 15.6 — Eşleşme (kullanıcı isteği, onaylandı 2026-10-26)

Kararlar (2026-10-26): ortak gruplardan havuz, kart kaydırma, Arkadaş ve Sevgili modları, freemium, web ödemesi. Kurallar: `docs/ARCHITECTURE.md` §3g.

### 15.6a — Eşleşme çekirdeği
- [x] Eşleşme profili: 18 yaş kontrolü, açık rıza, modlar, fotoğraflar (2–6), cinsiyet ve tercih (Sevgili), il, hakkımda, ilgi alanları, duraklatma, tüm verileri silme
- [x] Havuz ve deste (ortak gruplar, iki yönlü tercih uyumu, engel), kart kaydırma arayüzü
- [x] Beğen / geç (C#, günlük sınır), karşılıklı beğenide eşleşme, eşleşme ekranı, doğrudan sohbet
- [x] Eşleşmeler listesi, eşleşmeyi bitirme, şikayet ve engelleme
- [x] Bildirimler: `match_created` (push dahil), tercih; `match_liked` 15.6b'ye kaldı (Premium'a bağlı)
- [x] Admin: eşleşme sayfası, şikayet incelemesi, fotoğraf kaldırma, profili kapatma, günlük beğeni sınırı
- [x] pgTAP (27), C# (4) ve Flutter (eşleşme 6, admin 2) testleri; `flutter analyze` ve `dotnet build` temiz (2026-10-26)

### 15.6b — Premium
- [x] Billing: kişisel ürün (`matching_premium`), aylık / yıllık, PayTR ve iyzico ile web'den satın alma, kalan sürenin ardına ekleme
- [x] Sınırsız beğeni, beni kimler beğendi, gelişmiş filtreler, geri al, öne çık; süper beğeni (ücretsiz 1, Premium 5) ve `match_super_liked` bildirimi (kullanıcı isteği: Tinder tarzı)
- [x] Tinder tarzı deste: tam ekran fotoğraflı kart, sağa / sola / yukarı kaydırma, damgalar, uçarak çıkma, alt aksiyon çubuğu, profil ayrıntısı
- [x] Mobilde durum ve fiyatlar, satın alma web'de
- [x] Admin: günlük haklar, Premium fiyatları ve satış durumu, Premium üyeler ve gelir, Premium tanımlama, kişisel siparişler
- [x] pgTAP (27), C# (3 yeni), Flutter (eşleşme 10, billing 2 yeni, admin) testleri; `flutter analyze` ve `dotnet build` temiz (2026-10-26)
- [x] Kullanıcı kararı (2026-10-26): tek Premium yerine özellik başına ayrı paketler (Eşleşmelerim, Eşleşme Sohbeti, Seni Beğenenler, Sınırsız Beğeni, Süper Beğeni, Öne Çık, Hepsi Bir Arada). Ücretsiz kullanıcı kiminle eşleştiğini göremez, eşleşmesine yazamaz (SQL'de korunur); pgTAP 28_matching_packages (16), C# sohbet kilidi testi, Flutter kilitli eşleşme testleri
- [x] Kullanıcı kararı (2026-10-26): birebir mesaj yalnızca eşleşenler (Eşleşme Sohbeti paketiyle) ve ekip arkadaşları arasında; takip mesaj hakkı vermez, yabancıya istek gönderilemez, eski sohbetler okunur ama yazılamaz; eşleşme bitince karşılıklı takip kalkar (migration 0031, `public.can_message`). pgTAP 24 ve 28, C# ve Flutter mesajlaşma testleri güncellendi
- [x] Kullanıcı kararı (2026-10-26): Ekip Arkadaşı paketi (49 ₺ / ay, Hepsi Bir Arada'ya dahil): ekip arkadaşı isteği göndermek ve ekip arkadaşına yazmak paket ister; listeyi görmek ve gelen isteği kabul etmek ücretsiz (migration 0032). Eşleşme ekranı üst çubuğu telefonda taşmayacak şekilde sadeleştirildi
- [x] Kullanıcı kararı (2026-10-27): iki modda eşleşen kişi tek kayıtta "Arkadaş · Sevgili" olarak görünür; kişi hangisinin kalacağını seçer (migration 0033)
- [x] Kullanıcı kararı (2026-10-27): kişisel fotoğraf ve videolara yalnızca sahibi, eşleşenleri ve ekip arkadaşları yorum yazar; diğerleri emoji tepkisi bırakır (😍 😂 😮 👏 🔥 🙏, `post_reactions`); grup paylaşımları açık kalır (migration 0034, pgTAP 29_post_reactions)
- [x] Kullanıcı kararı (2026-10-27): ekip arkadaşı bölümüne giriş paketle (öneriler, istekler, kabul); paketsiz kişi bekleyen istek sayısını görür. Platform yöneticisi tüm paketlere paketsiz sahiptir (migration 0035)
- [x] Kullanıcı isteği (2026-10-27): ekip arkadaşı tercihleri yeni tasarım ve yeni seçenekler (aktiviteler, hedefler, sıklık, 6 zaman dilimi, ekip büyüklüğü, araç, ekipman); öneri puanı ve gerekçeleri bunları da kullanır (migration 0036)

- [x] İnceleme düzeltmeleri (2026-10-27): süper beğeni ücretsiz beğeniden düşmez, kaydırma yalnızca destedeki kişiye, "Seni beğenenler" 90 gün kuralı, süper beğeni bildirimi silmeyle gider, hesap silinince `match-photos` temizlenir, silinmiş alıcının ödemesi takılmaz (migration 0037); gönderi emoji tepkisi upsert izni (migration 0038)
- [x] Admin: kullanıcı sayfasından paket tanımlama ve iptal (iade dahil); sohbette gönderenin profil fotoğrafı (kullanıcı istekleri, 2026-10-27)

## Faz 15.7 — Yönetim Paneli: Analiz ve Denetim (kullanıcı isteği, onaylandı 2026-10-27)

Ayrıntılar: `docs/ARCHITECTURE.md` §8b. Her aşama bitince kullanıcıya gösterilir.

### 15.7a — Genel bakış
- [x] Panelin açılış sayfası: tarih aralığı (7 / 30 / 90 / 365 gün), "Şu an" özeti, önceki dönemle karşılaştırmalı KPI kartları ve mini grafikleri, zaman grafikleri (kullanıcı büyümesi ve aktif kullanıcı, etkileşim, mesajlar, eşleşme, gelir, moderasyon, gruplar ve canlı yayın); her grafikte açıklama, değer kutusu ve tablo görünümü
- [x] `GET /admin/analytics/overview`; günler Türkiye saatine göre, yıl 52 hafta; gelir yalnızca faturalamayı gören rollere
- [x] Grafikler `fl_chart` ile, yalnızca admin paketinde; seri renkleri tasarım sisteminde (`GwColors.chartSeries`, renk körlüğü için doğrulandı)
- [x] C# (1), Flutter (genel bakış masaüstü ve telefon, biçimlendirme) testleri; `flutter analyze` ve `dotnet build` temiz (2026-10-27)

### 15.7b — Modül analizleri
- [ ] Her modül sayfasında grafikli analiz: kullanıcılar, gruplar, içerik, mesajlaşma, eşleşme, gelir, canlı yayın, organizasyon, moderasyon, destek

### 15.7c — Denetim
- [ ] Ayrıntılı kullanıcı sayfası: etkinlik zaman çizelgesi, grupları, paylaşımları, şikayetleri, konuşmaları
- [ ] Konuşmalar: üst bilgi serbest; içerik gerekçeyle açılır, her açılış `audit_log`'a yazılır ve panelde görünür; aydınlatma metnine eklenir (kullanıcı kararı, 2026-10-27)
- [ ] İşlem kaydı görüntüleyici (`audit_log`), genel arama, CSV dışa aktarma
- [ ] Testler; `flutter analyze` ve `dotnet build` temiz; docs güncel

## Faz 15.8 — Güvenlik Doğrulaması (kullanıcı isteği, onaylandı 2026-10-27)

Ayrıntılar: `docs/ARCHITECTURE.md` §3h. Kararlar: kademeli yaptırım, Twilio Verify, SMS + isteğe bağlı doğrulama uygulaması; konum gizli işlenmez.

### 15.8a — Sunucu
- [x] Migration `0040`: güvenlik tabloları, `unverified` rolü, custom access token hook, zorlama anahtarı (varsayılan kapalı); hook yerel Supabase Auth ve PostgREST ile denendi (unverified token profillere 403 alır, hukuki metinleri okur)
- [x] C#: `Geo` ortak çekirdeğe taşındı; konumdan ülke (Natural Earth 1:50m, kıyıda 11 km tolerans), sinyal kararı, Twilio Verify ve Lookup, telefon ve ikinci adım, TOTP, otomatik ban ve inceleme, 90 gün saklama; admin uçları
- [x] Varsayılan yetki politikası `role = authenticated`
- [x] pgTAP (`33_security_verification`) ve C# (`SecurityTests`, `SecurityRulesTests`) testleri; `dotnet build` temiz (2026-10-27)

### 15.8b — Uygulama
- [x] Konum izni ekranı (izinsiz uygulama açılmaz, aydınlatma metni okunabilir), sinyal gönderimi (açılış ve 30 dakikada bir öne geliş), Android SIM ülkesi (`gway/device` kanalı)
- [x] Telefon doğrulama (ülke kodu kilitli), ikinci adım ekranı (SMS ya da uygulama), kısıtlı hesap ekranı; ayarlarda "İki adımlı doğrulama" ve QR'lı uygulama kurulumu
- [x] Router sırası: güvenlik → KVKK → onboarding; push kaydı token rolü `authenticated` olunca yapılır
- [x] Flutter testleri (güvenlik ekranları, %130 yazı, gate, push); yerel uçtan uca deneme: giriş → konum → telefon → SMS → ana sayfa ve ikinci girişte SMS ile ikinci adım; token rolü `authenticated` (2026-10-27)

### 15.8c — Yönetim paneli
- [x] Panel girişi aynı akıştan geçer (rol ancak oturum doğrulanınca okunur)
- [x] "Güvenlik" sayfası (`/security-reviews`, admin ve moderatör): incelemeler (onayla ve 0/30/90 gün muafiyet, banla), zorlama anahtarı (yalnızca admin, SMS sağlayıcısı durumu); kullanıcı sayfasında güvenlik özeti, son konum kontrolleri ve işlem geçmişinde güvenlik kayıtları
- [x] Testler (panel ekranları masaüstü ve telefon, destek rolü, gate); `flutter analyze` ve `dotnet build` temiz; docs güncel. Yerel uçtan uca deneme: admin girişi → ikinci adım → gerçek VPN incelemesi → 30 gün muafiyetle onay (2026-10-27)
- [ ] Bulut: `0039`/`0040` migration'ları ve token hook'u (`supabase config push`), Twilio Verify hesabı ve anahtarları, aydınlatma metnine konum ve telefon işleme (yeni `privacy_notice` sürümü), ardından zorlamayı açma — kullanıcı onayıyla

### 15.8d — Parmak izi ve Authenticator önerisi (kullanıcı kararı, 2026-10-27)
- [x] Passkey (WebAuthn, `Fido2`) ile ikinci adım: kayıt, giriş, ayarlarda liste ve silme (web; mobil uygulama sonra); yöntem sırası passkey > uygulama > SMS
- [x] Telefon doğrulandıktan sonra "Parmak izi / Google Authenticator ekle" önerisi; kurulan yöntem varsayılan
- [x] pgTAP, C# (yazılım doğrulayıcıyla gerçek imza, tekrar oynatma ve başka hesap reddi), Flutter testleri; Chrome sanal doğrulayıcısıyla uçtan uca deneme: telefon → öneri → parmak izi ekle → yeniden giriş → parmak iziyle doğrulama, token `authenticated` (2026-10-27)

## Faz 15.9 — Gruplar Arası Denge (kullanıcı isteği, onaylandı 2026-10-28; `docs/ARCHITECTURE.md` §3b)

Aynı türdeki gruplar üye "çalınmasından" şikâyet eder; üyeyi kısıtlamadan gruplar arası görünürlük kısıtlanır.
- [x] Üyelik gizliliği: üye listesinin tamamı yalnızca grubun üyelerine; yönetim ekibi herkese; "Gruplarımı profilimde göster" ayarı (varsayılan kapalı)
- [x] Davet sınırı: grup başına 24 saatte 50 davet (C# ve trigger)
- [x] Aynı saatte organizasyona katılınca diğerinden vazgeçme önerisi
- [x] Organizasyon formunda aynı gün, aynı il ve kategorideki diğer organizasyon sayısı (isimsiz)
- [x] pgTAP (887/887), C# (211/211) ve Flutter testleri; `flutter analyze` ve `dotnet build` temiz (2026-10-28)
- [ ] Bulut: `0047` migration'ı — kullanıcı onayıyla
- Sonraki adım önerisi (onay bekliyor): ortak organizasyon (iki grubun birlikte düzenlemesi), sadık üyelere özel organizasyonlar


## Faz 15.10 — Mesaj Gizliliği (kullanıcı isteği, 2026-11-01; `docs/ARCHITECTURE.md` §3f)

2026-10-31'de eklenen mesaj kayıtları kullanıcı kararıyla tamamen kaldırıldı: platform ekibi hiçbir mesajı okuyamaz, görüşmeyi dinleyemez ve kimin kimi aradığını göremez.
- [x] Yönetim panelinden "Mesaj kayıtları" sayfası, kullanıcı sayfasındaki düğme ve şikayetteki "Mesajı incele" (önceki 5 mesaj) kaldırıldı; mesaj şikayeti içerik gösterilmeden "Mesajı kaldır" ile sonuçlanır
- [x] Migration 0069: silinen mesaj arşivi (tüm metinleriyle), trigger ve okuma fonksiyonları silindi; şikayet ve bildirimlerdeki birebir mesaj metinleri temizlendi; geçmiş okuma kayıtları silindi; 0062 boşaltıldı
- [x] Sesli görüşmeler: `calls` yalnızca iki tarafa açık (0071, sesli görüşme dalı), panelde kişinin görüşme listesi yok
- [x] Aydınlatma metninin yeni sürümü: mesajlar okunmaz, görüşmeler kaydedilmez
- [x] Aydınlatma metni inceleme sonrası düzeltildi (migration 0070): mutlak "okuyamaz" yerine "araç yok, incelenmez"; grup moderatörleri, Firebase bildirimleri, görüşme bilgisi, yedekler ve yasal zorunluluk eklendi; bulut ve yayın 2026-11-01
- [x] pgTAP (`57_message_privacy`), C# ve Flutter testleri; `flutter analyze` ve `dotnet build` temiz (2026-11-01)
- [x] Bulut: `0069` migration'ı, API ve yönetim paneli yayında (2026-11-01)
- [ ] Aydınlatma metni hukuki incelemeden geçmeli

## Faz 15.11 — Birebir Sesli Görüşme (kullanıcı isteği, 2026-11-01; `docs/ARCHITECTURE.md` §8c)

Eşleşen iki kişi özel sohbetten sesli görüşür; özellik platform ekibinin açtığı kişilere açıktır.
- [x] Veritabanı (0071): `call_permissions`, `calls` (yalnızca iki taraf okur), kurallar (`call_blocker`), bildirim türleri, talep RPC'si
- [x] C#: uygunluk, arama, yanıt, ret, bitirme, yeniden katılma; `CallMonitor` (30 sn cevapsız, 60 dk sınır); admin yetki uç noktaları; arama push'u (`gway_calls`)
- [x] Uygulama: sohbet başlığında Sesli ara, tam ekran arama (zil, süre, sessize al, hoparlör), gelen arama, Ayarlar → Sesli görüşme talebi, bildirimler
- [x] Yönetim paneli: Sesli görüşme sayfası (talepler, aç / reddet / kapat, 24 saat toplamı), kullanıcı sayfasında yetki anahtarı; görüşme listesi yok
- [x] pgTAP (`58_voice_calls`), C# (235/235), Flutter (messaging 22, notifications 14, admin 70); `flutter analyze` ve `dotnet build` temiz (2026-11-01)
- [ ] Telefonda iki hesapla uçtan uca deneme (LiveKit açık)
- [x] Bulut: `0071` migration'ı, API, web uygulaması ve panel yayında (2026-11-01, kullanıcı isteğiyle telefonda denemeden önce)
- [x] Mobil uygulama 1.0.0+6 Play kapalı teste (alpha) yüklendi (2026-11-01, hizmet hesabıyla)
- [x] Ekip arkadaşları da sesli arar, eşleşmemiş sohbette buton soluk görünüp nedenini söyler (kullanıcı kararı 2026-11-02, 0072); ekip arkadaşı tercihlerinde gizli hesap uyarısı. Bulut 0072, API, web, panel ve mobil 1.0.0+7 (alpha) yayında (2026-11-02)

## Faz 18 — Topluluk Büyümesi (kullanıcı isteği, onaylandı 2026-10-28)

İnsanları uygulamaya çekecek, gerçek hayatta bir araya getiren özellikler. Sırayla, her biri mobil, web ve yönetim paneliyle birlikte yapılır. Ücretli servis gerektiren kısım onaysız açılmaz.

### 18a — Karşılama (ilk kez gelene gönüllü eşlik; `docs/ARCHITECTURE.md` §3d)
- [x] Karşılayıcı olma (grubun deneyimli üyesi), grup sayfasında karşılayıcı sayısı
- [x] Organizasyona ilk kez gelenin karşılanma isteği, karşılayıcının üstlenmesi ve buluşma notu, vazgeçme, teşekkür
- [x] Bildirimler ve push metinleri; "Kapı açan", "Ev sahibi", "Topluluğun kalbi" rozetleri
- [x] Yönetim paneli: genel bakışta karşılama ölçüleri, kullanıcı sayfasında karşılama sayısı
- [x] Gizlilik düzeltmesi: grup katkı listesi yalnızca üyelere, profildeki hedef rozetleri üyelik gizliliğine uyar
- [x] pgTAP (915/915), C# (213/213) ve Flutter testleri; `flutter analyze` ve `dotnet build` temiz (2026-10-28)
- [x] Bulut: `0048` migration'ı

### 18b — Gruplar Ligi (aynı il ve kategorideki grupların aylık sezonu; `docs/ARCHITECTURE.md` §3d)
- [x] Kaynak kayıtlardan puan (katılım, organizasyon, karşılama, memnuniyet), sıralama sayfası, grup sayfasında lig kartı
- [x] Sezon kapanışı, sabit sonuçlar, ilk üçe `league_result` bildirimi
- [x] Yönetim paneli: ligler, tablo, ligden çıkarma ve geri alma (audit)
- [x] pgTAP (932/932), C# (214/214) ve Flutter testleri; `flutter analyze` ve `dotnet build` temiz (2026-10-28)
- [x] Bulut: `0049` migration'ı
Rakip incelemesinden eklenenler (kullanıcı isteği, 2026-10-29). Sıra: 18j → 18k → 18l → 18c → 18m → 18g/18h → 18n → 18o.

### 18j — Davet bağlantısı ve paylaşım sayfaları (`docs/ARCHITECTURE.md` §3b)
- [x] Süreli, kullanım sınırlı, iptal edilebilir davet bağlantısı; bağlantıyla istekli ya da davetli gruba doğrudan katılım
- [x] WhatsApp önizlemeli paylaşım sayfaları (grup, organizasyon, davet); giriş sonrası bağlantıya dönüş
- [x] Yönetim paneli: grup sayfasında bağlantılar ve iptal
- [x] pgTAP (968/968), C# (218/218) ve Flutter testleri; `flutter analyze` ve `dotnet build` temiz (2026-10-29)
- [x] Bulut: `0050` (hoş geldin denemesi) ve `0051` migration'ları (2026-10-29)
- [ ] Sunucu alınınca: Caddy `/s/*` yönlendirmesi ve `SHARE_URL` ile web derlemesi (`deploy/` hazır)
- [ ] Alan adı belli olunca Android App Links / iOS Universal Links

### 18k — Tekrarlayan organizasyon (her tarih açıldığı ayın limitine sayılır, 4 hafta ileri açılır; `docs/ARCHITECTURE.md` §3d)
- [x] Her hafta / iki haftada bir, bitiş tarihi; 4 hafta ileri otomatik açılma, limit dolunca bildirim
- [x] Seriyi durdurma, tek tarihi iptal; organizasyon sayfasında tekrar bilgisi
- [x] Yönetim paneli: organizasyon listesinde tekrar bilgisi ve seriyi durdurma
- [x] pgTAP (987/987), C# (220/220) ve Flutter testleri; `flutter analyze` ve `dotnet build` temiz (2026-10-29)
- [x] Bulut: `0052` migration'ı (2026-10-29)
### 18l — "Geliyor musun?" teyidi (1 gün önce; yanıtsız kalan çıkarılmaz, işaretlenir; `docs/ARCHITECTURE.md` §3d)
- [x] Son 24 saatte "Geliyor musun?" kartı; "Evet" teyit, "Gelemiyorum" yeri bekleme listesine bırakır
- [x] Organizatöre teyit edenler ve sayısı; hatırlatma metninde teyit çağrısı
- [x] Yönetim paneli: organizasyon listesinde teyit sayısı
- [x] pgTAP (998/998), C# (221/221) ve Flutter testleri; `flutter analyze` ve `dotnet build` temiz (2026-10-29)
- [x] Bulut: `0053` migration'ı (2026-10-29)
### 18m — Haritada "Bugün / Bu hafta" ve mesafe filtresi (haritanın ortasından; `docs/ARCHITECTURE.md` §3d)
- [x] "Her zaman / Bugün / 7 gün içinde" ve 5–50 km mesafe; daire çizimi, liste görünümü de aynı filtreyle
- [x] pgTAP (1014/1014) ve Flutter testleri; `flutter analyze` ve `dotnet build` temiz (2026-10-29)
- [x] Bulut: `0055` migration'ı (2026-10-29)
### Düzeltmeler (kullanıcı geri bildirimi, 2026-10-30)
- [x] Gruplar ekranında sekme yazıları dar telefonda kaymıyor (ikonsuz, tek satır)
- [x] Grup kurulunca paket adımı: web'de paketler ve "Ücretsiz ile devam et", mobilde yalnızca limitler (`docs/ARCHITECTURE.md` §7)
- [x] Grup sayfasında organizasyonlardan gelen ortalama puan ve "Nasıldı?" ile yerinde yıldız verme (`0056`; `docs/ARCHITECTURE.md` §3b)
- [x] Askı ve ban ayrımı: süreli askıda profil uyarıyla görünür (gerekçe yalnız kişiye), ban (süresiz) hesabı her yerden gizler; kişi giriş yapıp kilitli ekranda gerekçeyi görür, uygulama açıksa uyarı anında düşer; panelde "Askıya al" ve "Kalıcı banla" (`0057`; `docs/ARCHITECTURE.md` §3a)
- [x] pgTAP (1033/1033), C# (222/222) ve Flutter testleri; `flutter analyze` ve `dotnet build` temiz (2026-10-30)
- [x] Bulut: `0056` ve `0057` migration'ları (2026-10-30)
- [ ] Bulut: token hook'u açık olmalı (`supabase config push`), yoksa askıdaki hesabın token'ı kısıtlanmaz
### 18n — Strava bağlantısı (API izni ve marka kuralları; onayla)
### 18o — Organizasyon ücretini uygulamadan toplama (kural değişikliği, PayTR pazaryeri ve hukuki inceleme; onayla)

### 18c — Yılın Özeti (paylaşılabilir hikâye kartları; organizasyon sonrası "Ben de oradaydım" kartı dahil; `docs/ARCHITECTURE.md` §3d)
- [x] Yılın özeti ekranı ve kartı (kendi profilinden)
- [x] Organizasyon sayfasında "Ben de oradaydım" kartı (katılmış sayılana)
- [x] Kartı görsel olarak paylaşma; paylaşım ölçümü
- [x] Yönetim paneli: genel bakışta paylaşılan kart eğilimi
- [x] pgTAP (1011/1011), C# (221/221) ve Flutter testleri; `flutter analyze` ve `dotnet build` temiz (2026-10-29)
- [ ] Gerçek telefonda paylaşım denemesi (Instagram hikâyesi, WhatsApp)
- [x] Bulut: `0054` migration'ı (2026-10-29)
### 18d — Keşif Haritam (kullanıcı kararı, 2026-10-31; `docs/ARCHITECTURE.md` §3d)
- [x] Katılınan organizasyonların illeri (buluşma noktasından il sınırlarıyla, yoksa grubun ili; sürprizde gizli mekan); kişinin kendi işaretlemesi yok
- [x] Yalnızca kişinin kendisi görür; Türkiye haritası, "x / 81 il", iller listesi; hikâye kartı olarak paylaşma
- [x] İl sınırları: Natural Earth (kamu malı), veritabanında ve uygulamada aynı veri; harita servisi çağrılmaz
- [x] Yönetim paneli: kullanıcı sayfasında keşfettiği il sayısı, genel bakışta harita kartı paylaşımı
- [x] pgTAP (1135/1135; `52_exploration_map` 16 test), C# (230/230) ve Flutter testleri; `flutter analyze` ve `dotnet build` temiz (2026-10-31)
- [x] Bulut: `0064` migration'ı (2026-10-31)
- Not: "rotalar" için GPS izi tutulmuyor; buluşma noktaları haritada nokta olarak görünür. Rota (iz) Strava bağlantısıyla (18n) gelebilir
### 18e — El Sıkış (kullanıcı kararı, 2026-10-31; `docs/ARCHITECTURE.md` §3d)
- [x] Aynı organizasyona katılanlar arasında QR ya da 6 haneli kodla tanışma; kod 3 dakikada bir yenilenir; başlangıçtan 1 saat önce ile bitişten 6 saat sonrası arası
- [x] "Tanıştıklarım" yalnızca kişiye; profilde sayı, iki rozet (Tanışkan, Sosyal kelebek); karşı tarafa bildirim ve push; mesaj hakkı vermez
- [x] Kamera ile okuma (telefon ve tarayıcı), kamera yoksa kodu yazma; iOS kamera izni metni, Play izin beyanı notu
- [x] Yönetim paneli: kullanıcı sayfasında el sıkış sayısı, genel bakış grafiğinde el sıkışlar
- [x] pgTAP (1153/1153; `53_handshakes` 18 test), C# (231/231) ve Flutter testleri; `flutter analyze` ve `dotnet build` temiz (2026-10-31)
- [x] Bulut: `0065` migration'ı (2026-10-31)
- [ ] Gerçek telefonda iki hesapla QR okutma denemesi
### 18f — Eve Vardım (güvenli dönüş; uygulama içi, SMS ücretli ve onaylı)
### 18g — Bu Akşam Boşum (yakında başlayanlar ve anlık buluşmalar; ortak gruplardan küçük masa; `docs/ARCHITECTURE.md` §3d)
- [x] "Bu akşam boşum" ve not (ortak grup üyeleri görür, 04:00'te kapanır), boş olanlar listesi
- [x] Küçük masa: sunucu 3–5 kişi seçer, davet ve kabul, üç kişiyle masa sohbeti, ertesi gün 12:00'de kapanış; bildirim ve push metinleri
- [x] "Yakında başlıyor" (önümüzdeki 6 saat; gruplarım, sonra gruplarımın illeri)
- [x] Yönetim paneli: genel bakışta "Bu akşam" grafiği
- [x] pgTAP (1055/1055), C# (225/225) ve Flutter testleri; `flutter analyze` ve `dotnet build` temiz (2026-10-30)
- [x] Bulut: `0058` migration'ı (2026-10-30)
- [x] Düzeltme: durum kaydedilemiyordu (uygulamanın upsert'i yazma izni olmayan sütuna yazıyordu); yazma artık `set_tonight` / `close_tonight` ile, kartta boş olanların yüzleri ve masa için gereken kişi sayısı, Bugün yenilenince bölümler de yenilenir (`0059`; pgTAP 1060/1060)
- [x] Bulut: `0059` migration'ı (2026-10-30)
### 1000 kullanıcılı uçtan uca test ve kural değişiklikleri (kullanıcı kararı, 2026-10-30)
- [x] Yerelde 1000 sentetik kullanıcıyla bütün özellikler ve yönetim paneli API üzerinden denendi; çalışmayan özellik bulunmadı
- [x] Kişisel gönderiye gönderiyi gören herkes yorum yazar (sahibi kapatabilir); grubun akışına her üye paylaşır (susturulan hariç); ücretsiz paket 100 üye ve ayda 4 organizasyon (`0060`)
- [x] pgTAP (1070/1070), C# (225/225) ve Flutter testleri; `flutter analyze` ve `dotnet build` temiz
- [x] Bulut: `0060` migration'ı (2026-10-30)
### Ad değişikliği: GrupX → GWAY (kullanıcı isteği, 2026-10-31; dal `gelistirme/gway-isim`)
- [x] Yeni logo (yol G'yi çizer, üye yola adım atar; `docs/brand/`), `GwLogo` ve bütün platform ikonları
- [x] Arayüz metinleri, paylaşım sayfaları, takvim, ödeme açıklamaları, 2FA ve passkey adı GWAY; C# `Gway.*`, Flutter `Gw*` önekleri
- [x] Paket kimlikleri `com.gway.app` ve `com.gway.admin.admin_panel`, giriş dönüş adresleri `com.gway.app://` ve `com.gway.admin://`
- [x] Hukuki metinlerin GWAY adlı yeni sürümleri ve ayrılmış `gway` adı (`0061`, pgTAP)
- [x] Firebase: `com.gway.app` Android uygulaması (`1:981517510131:android:32fd644cc31f6f154a5e86`), yeni `google-services.json`; ev ağı APK'sı derlendi (2026-10-31)
- [x] Bulutta `0061` migration'ı ve `com.gway.app://auth-callback`, `com.gway.admin://auth-callback` yönlendirmeleri; mobilde Google girişi denendi (2026-10-31). Google OAuth istemcisinde değişiklik gerekmedi (giriş tarayıcıdan, Supabase üzerinden)
- [x] Firebase: `com.gway.socialApp` iOS uygulaması, `firebase_options.dart` güncel (2026-10-31)
### 18h — Sürpriz Organizasyon (kullanıcı kararı, 2026-10-31; `docs/ARCHITECTURE.md` §3d)
- [x] Formda "Sürpriz mekan": herkese açık ipucu, gizli gerçek mekan ve buluşma noktası, 1/3/6/12/24 saat önce açıklanma
- [x] Mekanı yalnızca katılanlar açıklanma zamanından itibaren görür; yöneticiler ve platform ekibi her zaman; önce il ve ipucu
- [x] Haritada il merkezi, paylaşım sayfası ve takvimde yalnızca ipucu; herkese açık bağlantı ve tekrar yok
- [x] Açıklanma bildirimi ve push'u; açıklandıktan sonra mekan değişirse güncelleme bildirimi
- [x] Yönetim paneli: organizasyon listesinde ipucu, gerçek mekan ve açıklanma durumu
- [x] pgTAP (1119/1119; `51_surprise_events` 20 test, `36_platform_referrals` başka testlerin bıraktığı kayıtlardan bağımsız), C# (229/229) ve Flutter testleri; `flutter analyze` ve `dotnet build` temiz (2026-10-31)
- [x] Bulut: `0063` migration'ı (2026-10-31)
### 18i — Yoldan Canlı (organizasyondan canlı sesli yayın)
### 18j — İyilik Saatleri (doğrulanmış gönüllülük)

## Faz 16 — Yapay Zekâ Değerlendirmesi

- Yalnızca maliyet, gizlilik ve uygulanabilirlik raporu; kod onaydan sonra

## Faz 17 — Yayına Hazırlık

### 17a — Google Play (kullanıcı isteği, onaylandı 2026-10-27; ayrıntılar `docs/ARCHITECTURE.md` §10)
- [x] Paket adı `com.gway.app`, Firebase Android uygulaması, yükleme anahtarı ve imza (Play App Signing için yükleme anahtarı), App Bundle, sürüm `1.0.0+1`; AAB derlendi ve yükleme anahtarıyla imzalı (2026-10-27)
- [x] Sürümde şifresiz trafik kapalı; ev ağı APK'sı yalnızca `lanHttp=true` ile
- [x] geolocator'ın konum ön plan servisi manifest'ten çıkarıldı (arka planda konum yok, Play ön plan servisi beyanı gerekmez)
- [x] Android'de satış ve web'e yönlendirme yok; yalnızca paket durumu
- [x] 18+ yaş sınırı: doğum tarihi adımı (`birth_dates`, migration `0043`, pgTAP)
- [x] Herkese açık sayfalar: `/gizlilik`, `/kosullar`, `/hesap-silme`
- [x] Sunucu kurulumu (`deploy/`, `docs/DEPLOY.md`): Docker Compose, Caddy (https), API, LiveKit, web ve panel; API imajı derlendi ve sağlık kontrolü geçti
- [x] `docs/PLAY_STORE.md`: veri güvenliği, içerik derecelendirmesi, izin beyanları, mağaza metinleri, kapalı test ve Google girişi adımları
- [x] Testler (pgTAP 832, Flutter 17 paket); `flutter analyze` temiz
- [ ] Kullanıcıda: Play geliştirici hesabı, alan adı ve sunucu, Twilio, hukuk incelemesi ve yeni aydınlatma metni, OAuth onay ekranını yayına alma, mağaza görselleri, kapalı test (12 kişi, 14 gün)
- [x] İnceleme hesabı muafiyeti (`user_security.review_exempt`, migration `0044`, yalnızca admin, gerekçeli ve kayıtlı; panelde kullanıcı sayfasında anahtar; pgTAP, C# ve Flutter testleri; kullanıcı kararı 2026-10-27)

- Karanlık tema
- Performans
- Güvenlik testi
- Analitik (admin dahil)
- Mağaza hazırlığı
