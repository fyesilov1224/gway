# GrupX — Yol Haritası

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
- [x] C# iskeleti: `GrupX.Api` (Supabase JWT, ProblemDetails, rate limit, `/health`), `GrupX.SharedKernel` (`Result`, `Error`), testler
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
- [x] Grup sayfasında paket kartı (sahip), limit dolunca uyarı (onay yetkisi olanlar), bitişe 7 gün kala hatırlatma
- [x] Limit koruması: üye limiti API'de (`IGroupPlanLimits`) ve `group_members` trigger'ında; organizasyon ve yayın dakikası limitleri Faz 5 ve 7'de bağlanacak
- [x] Admin: Abonelikler (bu ayın geliri, son 12 ayın aylık geliri, bekleyen ödemeler, ödeme ve abonelik listeleri), Paketler (limit, fiyat, satış durumu düzenleme), grup detayında paket ve zaman çizelgesi, iade işaretli abonelik iptali
- [x] Doğrulama (2026-10-19): `flutter analyze` temiz, Flutter 119/119, `dotnet build` 0 hata 0 uyarı, C# 105/105, pgTAP 207/207, uçtan uca senaryo 41/41 (gerçek veritabanı ve API, yerel sahte PayTR/iyzico, DB-IP Lite ile IP → ülke), iki uygulamanın web derlemesi ve ekran kontrolü
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
- [x] Uygulama içi bildirimler. Push bildirimleri (FCM / APNs) Firebase proje bilgileri gelince eklenir.
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

## Faz 7 — Canlı Sesli Yayın

Kullanıcı isteğiyle Faz 4–6 bitmeden yapıldı (2026-10-20). Kararlar: yayını grup sahibi ve Yöneticiler başlatır, yalnızca grup üyeleri katılır; emoji tepkileri, yazılı yorumlar ve planlı yayın (hatırlatmalı) vardır. Ayrıntılar: `ARCHITECTURE.md` §8.

- [x] LiveKit; C#'ta token üretimi (yalnızca mikrofon, öznitelikleri yalnızca sunucu değiştirir) ve oda yönetimi (Twirp API, SDK'sız)
- [x] Konuşmacı / dinleyici, el kaldırma, sahneye alma ve indirme (sahnede en fazla 10 kişi)
- [x] Sunucu tarafı moderasyon: mikrofon kapatma / açma, odadan atma, yorum silme, yayını bitirme; rütbe kuralı C#'ta ve trigger'larda (`live.start`, `live.moderate`)
- [x] Atılan kullanıcıya o yayın için token verilmemesi. Gruptan ban ve susturma Faz 6'da bu kontrole bağlanır.
- [x] Yayın dakikası paket limiti (Türkiye saatiyle takvim ayı, C# + trigger); dakika dolunca yayın kendiliğinden biter
- [x] Gözetim: odası kapanan, sunucusu 2 dakikadan uzun ayrılan ve dakikası dolan yayınları bitirir; zamanı geçen planlı yayını iptal eder
- [x] Emoji tepkileri (LiveKit veri mesajı), yazılı yorumlar (Realtime), planlı yayın ve `live_started` hatırlatma bildirimi
- [x] Arayüz: grup sayfasında canlı kartı, yaklaşanlar ve "Yayın başlat"; ana sayfada canlı yayınlar şeridi; yayın odası (sahne, dinleyiciler, konuşma halkası, yönetici menüsü, tepkiler, yorumlar)
- [x] Admin: şu an canlı yayınlar (katılımcı sayısıyla), geçmiş, acil kapatma (audit log)
- [x] Doğrulama (2026-10-20): `flutter analyze` temiz, tüm Flutter testleri geçiyor (live 10, admin 34), `dotnet build` 0 hata 0 uyarı, C# 129/129, pgTAP 392/392; gerçek LiveKit ile iki kullanıcılı uçtan uca deneme (bağlanma, mikrofon yayını, el kaldırma, sahneye alma, Realtime yorum)

## Faz 8 — Mesajlaşma

- Birebir ve grup içi mesajlaşma
- Engelleme
- Admin: şikayet edilen mesajların incelenmesi

## Faz 9 — Yayına Hazırlık

- Karanlık tema
- Performans
- Güvenlik testi
- Analitik (admin dahil)
- Mağaza hazırlığı
