# Google Play yayın rehberi

Uygulamanın Play kurallarına uyumu için yapılanlar `docs/ARCHITECTURE.md` §10'dadır. Bu dosya Play Console'da doldurulacakları ve yayın adımlarını sırayla verir. `<alan adı>` sunucu kurulumundaki alan adıdır (`docs/DEPLOY.md`).

## 0. Yayından önce bitmesi gerekenler
- [ ] Sunucu ve alan adı hazır; `https://api.<alan adı>/health` "Healthy" dönüyor (`docs/DEPLOY.md`).
- [ ] Twilio Verify anahtarları sunucuda; güvenlik doğrulaması açılabiliyor.
- [ ] **Aydınlatma metni ve kullanım koşulları** hukuk incelemesinden geçti ve şunları içeriyor: konum (yalnızca ülke saklanır, 90 gün), telefon numarası (SMS doğrulama, Twilio), doğum tarihi (18+), passkey (açık anahtar), VPN ve SIM ülkesi sinyalleri, otomatik karar ve itiraz yolu (KVKK m.11). Yeni sürümler admin panelindeki *Hukuki metinler* sayfasından yayınlanır.
- [ ] Google OAuth onay ekranı **yayında** (aşağıda 6. adım).
- [ ] Mağaza görselleri hazır (5. adım).

## 1. Geliştirici hesabı
- play.google.com/console, tek seferlik 25 USD. Kimlik doğrulaması istenir.
- **Kişisel hesap** ise üretime çıkmadan önce **en az 12 test kullanıcısıyla 14 gün kesintisiz kapalı test** zorunludur (7. adım).
- Şirket adına açılan **kuruluş hesabı** (D-U-N-S numarası gerekir) bu şarttan muaftır.

## 2. Uygulamayı oluşturma
- Ad: **GrupX**. Varsayılan dil: Türkçe. Tür: Uygulama. Ücretsiz.
- Paket adı ilk yüklemede `com.grupx.app` olarak sabitlenir.
- **Play App Signing** varsayılan olarak açıktır; kabul et. Bizdeki anahtar yalnızca yükleme anahtarıdır:
  - Dosyalar: `%USERPROFILE%\.grupx\upload-keystore.jks` ve `key.properties`.
  - **Yedekle:** iki dosyayı şifre yöneticisine ya da şifreli bir buluta koy.
  - Kaybolursa Play Console → *Uygulama bütünlüğü* sayfasından yükleme anahtarı sıfırlatılır.

## 3. Sürüm yükleme
```bash
# pubspec.yaml: version 1.0.0+1 → her yüklemede + sonrası artar (1.0.1+2 ...)
cd G:\app\apps\social_app
flutter build appbundle --release --no-tree-shake-icons \
  --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_PUBLISHABLE_KEY=... \
  --dart-define=API_URL=https://api.<alan adı>
```
Yüklenecek dosya: `build\app\outputs\bundle\release\app-release.aab`. Önce **Kapalı test** kanalına yüklenir.

## 4. Uygulama içeriği (Play Console → Politika → Uygulama içeriği)
| Bölüm | Cevap |
|---|---|
| Gizlilik politikası | `https://app.<alan adı>/#/gizlilik` |
| Uygulama erişimi | "Tüm işlevler kısıtlı değil" değil: **giriş gerekir**. İnceleme ekibi için bir test hesabı (e-posta ve şifre) ver. Aşağıdaki "İnceleme hesabı" notunu oku. |
| Reklamlar | Uygulamada reklam **yok** |
| İçerik derecelendirmesi | IARC anketi: kategori *Sosyal*. Kullanıcılar birbiriyle iletişim kurar: **Evet**. Kullanıcı içeriği paylaşılır: **Evet**. Konum başkalarıyla paylaşılır: **Hayır** (yalnızca organizasyonların yeri). Dijital ürün satın alma: **Hayır** (Android'de satış yok). Kumar, şiddet, cinsellik: **Hayır**. |
| Hedef kitle | **Yalnızca 18 ve üstü**. Uygulama çocuklara hitap etmiyor. |
| Haber uygulaması | Hayır |
| Devlet / finans / sağlık uygulaması | Hayır |
| Hesap silme | Uygulama içinden: **Evet** (Ayarlar → Hesabı sil). Web bağlantısı: `https://app.<alan adı>/#/hesap-silme` |

**İnceleme hesabı:** Güvenlik doğrulaması açıkken inceleme ekibi (genellikle ABD'den) Türkiye konumu ve Türk numarası olmadan giremez. İnceleme sürecinde iki yol var:
- Doğrulamayı panelden geçici olarak kapatmak.
- İnceleme hesabı için kalıcı bir muafiyet eklemek (henüz yok; istenirse eklenir).

### Veri güvenliği formu
Toplanan veriler (hepsi aktarım sırasında şifreli: **Evet**; kullanıcı silme isteyebilir: **Evet**; satılmaz; reklam için kullanılmaz):

| Veri türü | Toplanır | Amaç | Zorunlu mu |
|---|---|---|---|
| Konum: yaklaşık ve kesin | Evet (kesin koordinat saklanmaz, yalnızca ülke) | Dolandırıcılık önleme, güvenlik | Zorunlu (doğrulama açıkken) |
| Ad | Evet | Hesap yönetimi, uygulama işlevi | Zorunlu |
| E-posta adresi | Evet | Hesap yönetimi | Zorunlu |
| Kullanıcı kimlikleri | Evet | Hesap yönetimi | Zorunlu |
| Telefon numarası | Evet | Hesap yönetimi, güvenlik (doğrulama) | Zorunlu (doğrulama açıkken) |
| Diğer kişisel bilgiler (doğum tarihi, biyografi) | Evet | Uygulama işlevi (18+), kişiselleştirme | Doğum tarihi zorunlu |
| Fotoğraflar | Evet (kullanıcının yükledikleri) | Uygulama işlevi | İsteğe bağlı |
| Sesli kayıtlar | **Hayır**: canlı yayın sesi aktarılır, kaydedilmez | — | — |
| Uygulama içi mesajlar | Evet | Uygulama işlevi | İsteğe bağlı |
| Diğer kullanıcı içeriği (gönderi, yorum) | Evet | Uygulama işlevi | İsteğe bağlı |
| Uygulama etkileşimleri | Evet (beğeni, takip, katılım) | Uygulama işlevi | — |
| Cihaz kimliği (bildirim jetonu) | Evet | Bildirimler | İsteğe bağlı |
| Ödeme bilgileri | **Hayır**: Android'de satış yok; web'de ödeme sağlayıcıda (PayTR, iyzico) | — | — |

Hizmet sağlayıcılar (Supabase, Twilio, Firebase, LiveKit, kendi sunucumuz) veri **paylaşımı** sayılmaz, işleyici sayılır.

### İzin beyanları
- **Konum** yalnızca uygulama açıkken kullanılır. Arka planda konum ve ön plan servisi yoktur. Uygulama, izin istemeden önce amacı bir ekranda söyler. *Konum izni beyanı* sorulursa: "Hesap güvenliği ve sahte hesapların önlenmesi için giriş ve açılışta ülke doğrulaması."
- **Mikrofon** yalnızca canlı yayında sahneye alınınca kullanılır.
- `QUERY_ALL_PACKAGES` **yok**. Yalnızca VPN servisleri sorgulanır (`<queries>`); ayrıca beyan gerekmez.

## 5. Mağaza kaydı (Play Console → Büyüme → Mağaza varlığı)
- **Uygulama adı** (30 karakter): `GrupX: Gruplar ve Etkinlikler`
- **Kısa açıklama** (80): `Yürüyüş, koşu, bisiklet, müzik ve daha fazlası: grubunu bul, etkinliğe katıl.`
- **Uzun açıklama** (4000):
  > GrupX, ilgi alanına göre kurulmuş toplulukları tek çatı altında toplar. Doğa yürüyüşü, koşu, bisiklet, müzik, sanat, spor… Grubunu bul, organizasyonlara katıl, yeni insanlarla tanış.
  >
  > • Gruplar: katıl, paylaş, duyuruları kaçırma
  > • Organizasyonlar: tarih, yer, kontenjan; takvimine ekle
  > • Canlı sesli yayın: grubunla anlık sohbet et
  > • Anketler, görevler ve ortak hedefler
  > • Mesajlaşma ve ekip arkadaşı bulma
  > • Haritada yakınındaki grupları keşfet
  > • Güvenli topluluk: telefon doğrulaması, iki adımlı giriş, şikayet ve disiplin kurulu
  >
  > GrupX 18 yaş ve üstü içindir.
- **Kategori**: Sosyal. **Etiketler**: topluluk, etkinlik, spor.
- **İletişim e-postası** zorunludur. İsteğe bağlı olarak web sitesi `https://app.<alan adı>`.
- **Görseller**:
  - Uygulama simgesi 512×512 PNG (32-bit, şeffaflıksız).
  - Öne çıkan grafik 1024×500.
  - En az 2 telefon ekran görüntüsü (1080×1920 ya da benzeri, 9:16). Önerilenler: Bugün sayfası, grup sayfası, organizasyon, canlı yayın, harita.
  - Mevcut simge geçici; yayından önce tasarımcıdan son hali alınmalı.

## 6. Google girişi (Google Cloud Console → APIs & Services → OAuth consent screen)
- Uygulama Android'de Google ile tarayıcı üzerinden (Supabase) giriş yapar, ayrı bir Android OAuth istemcisi ve SHA-1 gerekmez.
- Onay ekranında:
  - Uygulama adı, destek e-postası, logo.
  - Yetkili alan adı: `<alan adı>`.
  - Gizlilik politikası: `https://app.<alan adı>/#/gizlilik`.
  - Koşullar: `https://app.<alan adı>/#/kosullar`.
- **Publish app** ile durumu "In production" yap. Şu an "Testing" durumunda; yalnızca test kullanıcıları girebiliyor. Yalnızca e-posta ve profil izinleri istendiği için Google incelemesi gerekmez.
- Supabase → Authentication → URL Configuration'da `com.grupx.social://auth-callback` yönlendirmesi kayıtlı olmalı (`docs/DEPLOY.md` 7. adım).

## 7. Kapalı test → üretim
1. *Test → Kapalı test* bölümünde bir kanal aç ve AAB'yi yükle.
2. Test kullanıcılarının Google hesap e-postalarını listeye ekle (kişisel hesapta en az 12 kişi).
3. Katılım bağlantısını paylaş. Herkes uygulamayı Play'den yükleyip **14 gün** kurulu tutmalı.
4. 14 gün sonra *Üretime erişim başvurusu*. Google birkaç soru sorar: test nasıl geçti, ne düzeltildi.
5. Onaydan sonra üretim sürümü yüklenir. İlk inceleme birkaç gün sürebilir.

## Sonraki sürümler
- `pubspec.yaml`'da sürümü artır (`1.0.1+2`), AAB'yi derle, *Üretim → Yeni sürüm* ile yükle.
- Veritabanı değişikliği varsa önce `supabase db push`, sonra sunucu güncellemesi, en son uygulama yüklemesi.
