# GWAY Logo

**Fikir:** Bir yol kıvrılıp **G** harfini oluşturur; bir üye (baş ve gövde) bu yola adım atar. Bu hem "GWAY"in G'si, hem topluluğuna giden yoldur. Ad 2026-10-31'de GrupX'ten GWAY'e değişti (kullanıcı isteği).

| Dosya | Kullanım |
|---|---|
| `gway-mark.svg` | Sembol, açık zemin (mor + mavi) |
| `gway-app-icon.svg` | Sosyal uygulama ikonu: mor zemin, beyaz + açık mavi |
| `gway-admin-icon.svg` | Admin paneli ikonu: koyu zemin, yumuşak mor + mavi |

Uygulama içinde logo `GwLogo` bileşeniyle çizilir (`design_system`, ek paket gerektirmez). `wordmark: true` "GWAY" yazısını ekler: "G" ana metin renginde, "WAY" mor.

## Geometri (120 × 120 ızgara)

- Yol (birinci renk): merkez (60, 60), yarıçap 40 olan yay; 0°'den (sağ) saat yönünde 290°'ye, kalınlık 16, yuvarlak uçlar
- Gövde (ikinci renk): (62, 60) → (100, 60), kalınlık 16, yuvarlak uçlar
- Baş (ikinci renk): daire, merkez (92, 35), yarıçap 11

## Renkler

| Ton | Yol | Üye | Zemin |
|---|---|---|---|
| `color` | `#6E56CF` | `#2F6FE0` | açık |
| `onPrimary` | `#FFFFFF` | `#C9DAFF` | `#6E56CF` |
| `onDark` | `#B5A6F5` | `#8FB4FF` | `#1F2033` |

Logo **gradyan kullanmaz**. Mor→mavi gradyan yalnızca canlı yayın rozeti ve "yayın başlat" butonuna ayrılmıştır (`docs/DESIGN.md`).

## Kurallar

- Çevresinde en az sembol yüksekliğinin ¼'ü kadar boşluk bırakılır.
- Sembol 16 px'ten küçük kullanılmaz.
- Döndürülmez, esnetilmez, renkleri tona göre değiştirilmez, gölge veya kontur eklenmez.

## İkonları yeniden üretmek

Platform ikonları (web, Android, iOS) bu geometriden üretilmiştir: sembol ikonda 0,66 ölçekle ortalanır (maskable web ikonlarında 0,54); Android ve web ikonlarının köşe yarıçapı kenarın %22'sidir. Geometri değişirse iki uygulamanın şu dosyaları birlikte yenilenir: `web/icons/*`, `web/favicon.png`, `android/app/src/main/res/mipmap-*/ic_launcher.png`, `ios/Runner/Assets.xcassets/AppIcon.appiconset/*`. iOS ikonları ve maskable web ikonları opak olmalıdır (alfa kanalı yok).
