# GrupX Logo

**Fikir:** Dört üye ortada buluşur; başları ve gövdeleri birlikte bir **X** oluşturur. Bu hem "GrupX"in X'i, hem bir araya gelen topluluktur.

| Dosya | Kullanım |
|---|---|
| `grupx-mark.svg` | Sembol, açık zemin (mor + mavi) |
| `grupx-app-icon.svg` | Sosyal uygulama ikonu: mor zemin, beyaz + açık mavi |
| `grupx-admin-icon.svg` | Admin paneli ikonu: koyu zemin, yumuşak mor + mavi |

Uygulama içinde logo `GxLogo` bileşeniyle çizilir (`design_system`, ek paket gerektirmez). `wordmark: true` "GrupX" yazısını ekler: "Grup" ana metin renginde, "X" mor.

## Geometri (120 × 120 ızgara)

Tek bir üye sol üst çeyrekte çizilir, sonra merkez (60, 60) etrafında 90° adımlarla döndürülür:

- Baş: daire, merkez (22, 22), yarıçap 12
- Gövde: (39, 39) → (50, 50), kalınlık 16, yuvarlak uçlar
- Renk sırası: 0° birinci renk, 90° ikinci, 180° birinci, 270° ikinci

## Renkler

| Ton | Birinci üye | İkinci üye | Zemin |
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

Platform ikonları (web, Android, iOS) bu geometriden üretilmiştir. Geometri değişirse iki uygulamanın şu dosyaları birlikte yenilenir: `web/icons/*`, `web/favicon.png`, `android/app/src/main/res/mipmap-*/ic_launcher.png`, `ios/Runner/Assets.xcassets/AppIcon.appiconset/*`. iOS ikonları opak olmalıdır (alfa kanalı yok).
