# GWAY — Tasarım Sistemi

Hedef: ferah, sakin, profesyonel bir arayüz (AAA). Ekranın büyük kısmı beyazdır, içerik öne çıkar, kullanıcı yorulmaz.

**Kimlik (Faz 15.5):** GWAY bir akış uygulaması değil, toplulukların buluştuğu yerdir. Bu yüzden X ve Instagram kalıpları (taşan avatarlı kapak, kenardan kenara akış, bitişik kare ızgara, hikâye halkası şeridi, beş ikonlu alt çubuk) kullanılmaz. Ana sayfa "Bugün"dür: önce canlı yayınlar ve yaklaşan organizasyonlar, sonra akış. İçerik, mor–pembe–beyaz geçişli zemin (`GwBackdrop`) üzerinde beyaz kartlarda durur; kişi, grup ve kategoriler kendi yumuşak tonlarını taşır.

Tüm değerler `app/packages/design_system` içindeki tokenlardan gelir. **Uygulama kodunda doğrudan renk, boşluk, yarıçap veya yazı boyutu yazılmaz.**

---

## 1. Renkler — `GwColors`

| Token | Değer | Kullanım |
|---|---|---|
| `primary` | `#6E56CF` | Ana aksiyon (mor) |
| `primarySoft` | `#F3F0FF` | Mor soft zemin, seçili durum |
| `secondary` | `#2F6FE0` | İkincil aksiyon, bilgi, bağlantı (mavi) |
| `secondarySoft` | `#EAF2FF` | Mavi soft zemin |
| `textPrimary` | `#1F2033` | Ana metin (yumuşak siyah) |
| `textSecondary` | `#5C5F77` | İkincil metin |
| `background` | `#FFFFFF` | Zemin |
| `surface` | `#FAFAFD` | Kart, sayfa yüzeyi |
| `surfaceMuted` | `#F4F4F8` | İkincil yüzey, iskelet |
| `border` | `#ECECF2` | Kenar çizgisi, ayraç |
| `onPrimary` | `#FFFFFF` | Mor / mavi üzerindeki metin |
| `error` | `#C4314B` | Hata metni ve ikonu |
| `errorSoft` | `#FDECEF` | Hata zemini |
| `warning` | `#8A5A00` | Uyarı metni ve ikonu (sarı) |
| `warningSoft` | `#FFF4D6` | Uyarı zemini |
| `success` | `#1D7A45` | Başarı metni ve ikonu (yeşil) |
| `successSoft` | `#E6F6EC` | Başarı zemini |
| `like` | `#E0245E` | Yalnızca dolu beğeni kalbi (gönderi, yorum, çift dokunma animasyonu) |
| `media` | `#111118` | Hikaye görüntüleyici ve video zemini (medya tam ekranken) |
| `onMedia` | `#FFFFFF` | `media` zemini ya da fotoğraf üzerindeki metin ve ikon |
| `mediaScrim` | `#111118` %45 | Fotoğraf üzerindeki metnin okunması için üst/alt geçiş |

- **Kırmızı, sarı, yeşil** yalnızca durum ve tür anlatır (ör. destek mesajı türleri: Sorun kırmızı, Talep sarı, İstek yeşil). Ana arayüz rengi değildir; büyük alanlarda yalnızca soft tonları kullanılır, metin ve ikon koyu tondadır. `GwBadgeTone.warning` ve `GwBadgeTone.success` bu çiftleri kullanır.
- **Medya zemini** (`media`) yalnızca medya tam ekran gösterilirken (hikaye, tam ekran video) kullanılır; uygulamanın geri kalanı beyazdır. Fotoğraf üzerindeki metin her zaman `mediaScrim` geçişinin üzerinde durur.
- **Hikaye halkası:** görülmemiş hikaye `primary` renkli 2 px halka, görülmüş hikaye `border` halka. Gradyan kullanılmaz. Halka yalnızca hikâye ve öne çıkan çiplerindeki küçük avatarda görünür.
- **Konuşma halkası:** yayın odasında konuşan kişinin avatarında `primary` renkli 2 px halka. Gradyan kullanılmaz.
- **Mor→mavi gradyan** (`GwColors.liveGradient`) **yalnızca** canlı yayın rozeti ve "yayın başlat" butonunda kullanılır.
- Kontrast: Metin / zemin çiftleri WCAG AA'yı (normal metin ≥ 4.5:1) sağlar. Bu, `design_system` testleriyle doğrulanır.
- Mavi metin soft mavi zemin üzerinde kullanılmaz (≈4.2:1, AA altı). Soft zeminlerin üzerindeki metin `textPrimary` olur. İstisna: mor metin `primarySoft` üzerinde kullanılabilir (≈4.8:1).

### Grafikler — `GwColors.chartSeries` (Faz 15.7, yalnızca yönetim paneli)
- Seri renkleri **sabit sırayla** verilir, asla döngüye girmez: mor `#6E56CF`, turuncu `#EB6834`, mavi `#2F6FE0`, yeşil `#138A5F`. Mor ve mavi renk körlüğünde karışır, bu yüzden yan yana gelmez. Sıra beyaz zeminde renk körlüğü, normal görme ve 3:1 kontrast için betikle doğrulandı (bitişik çiftler).
- Bir grafikte en fazla 4 seri; fazlası ayrı grafiğe bölünür. İki seri ve üstünde açıklama (legend) her zaman bulunur, seri adı ayrıca doğrudan çizginin ucuna yazılır; kimlik yalnızca renge bırakılmaz.
- Önceki dönem, güncel serinin altında açık gri (`chartCompare`) kesik çizgidir. Izgara çizgileri kenar rengindedir, eksenler sakindir.
- Tek eksen: farklı ölçekteki iki ölçü (ör. gelir ve sipariş sayısı) aynı grafikte iki eksene konmaz, ayrı grafik olur.
- Çizgi 2 px, sütun uçları 4 yuvarlak, sütunlar arası 2 px boşluk. Üzerine gelince / dokununca değer kutusu çıkar. Yazılar seri renginde değil, metin renklerindedir.

### Zemin — `GwBackdrop`

Her sayfanın arkasında beyazdan açık mora ve açık pembeye geçen, sabit ve yumuşak bir zemin vardır (kullanıcı isteği, 2026-10-22). Sol üstten açık mor, sağ üstte pembe bir ışıltı, ortası beyaza yakın, sol altta yine açık mor.

| Token | Değer | Kullanım |
|---|---|---|
| `backdropLilac` | `#EEE8FF` | Zeminin mor ucu |
| `backdropPink` | `#FFE6F3` | Zeminin pembe ucu |

- Zemin tema üzerinden her sayfa geçişine eklenir (`GwTheme` → `pageTransitionsTheme`); `Scaffold` ve `AppBar` saydamdır. Sayfa kodu zemin rengi vermez.
- Pembe **yalnızca zeminde** kullanılır; buton, metin ya da ikon rengi değildir.
- Zemin renkleri açıktır; `textPrimary` ve `textSecondary` üzerlerinde AA'yı sağlar (`design_system` kontrast testi).
- Tam ekran medya (hikâye, video) ve yayın odası kendi koyu zeminini kullanır.

### Tonlar — `GwTone`

Paletten türeyen yumuşak kimlik tonları. Bir kişi, grup ya da kategori her yerde aynı tonu taşır (`GwTone.of(id ya da ad)`): avatarın görselsiz hali, kapak yer tutucusu, tarih karosu, etiketler.

| Ton | Zemin (`soft`) | Vurgu (`strong`) |
|---|---|---|
| `lilac` | `primarySoft` | `primary` |
| `sky` | `secondarySoft` | `secondary` |
| `mist` | `surfaceMuted` | `textPrimary` (yalnızca bilerek seçilir) |

`strong` yalnızca ikon ve büyük yazıda (baş harfler, gün numarası) kullanılır; zemin üzerindeki küçük metin `textPrimary` olur.

### Oyunlar — `GwChessColors`, `GwMedal` (Faz 20)

- **Satranç tahtası** (kullanıcı isteği 2026-11-05: "profesyonel ve çeşitli"): kişi `Tahta ve taşlar` ayarından seçer, seçim cihazda saklanır. Tahta temaları `GwBoardTheme`: **Ahşap** (varsayılan, `#F0D9B5`/`#B58863`), Yeşil, Mavi, Gri, GWAY moru. Taş setleri: **Klasik** (varsayılan, Cburnett), Kelt, Uzay, Fantastik, Modern (Chessnut), Sıcak (Rhos). Vurgular her temada aynı (`GwChessColors`): son hamle yumuşak sarı, seçili taş yeşil, şah tehdidi kırmızı ışıma, yasal hedefler koyu nokta (taş alma halka), ön hamle mavi; tahtanın çevresinde ince çerçeve. Koordinatlar kenar karelerin içinde, karşı kare renginde. Tahta renkleri marka paletinin bilinçli istisnasıdır: oyuncuların alıştığı renkler.
- **Oyun ekranı:** oyuncu çubuklarında alınan taşlar ve malzeme farkı (+3), hamle listesinde dokunarak ve ⏮ ◀ ▶ ⏭ ile geçmiş konuma bakma ("Canlıya dön"). Satranç ana sayfası: süren oyun şeridi, "Çevrimiçi oyna" paneli (türlere göre süre seçimi, "Rakip bul"), dört giriş kartı (arkadaş, turnuvalar, takım maçları, sıralama), yatay turnuva kartları; geniş ekranda sağ sütunda profil, sıralama ve son oyunlar.
- **Oyunlar ekranı:** + düğmesindeki "Oyunlar" kartı açar; her oyunun büyük bir kartı vardır (satrançta seçili tahta ve taşlarla gerçek bir tahta resmi).
- **Madalyalar** yalnızca sıralamaların ilk üçünde: altın `#C9971C`, gümüş `#8C96A6`, bronz `#B06A35`; her birinin açık zemini vardır (`GwMedal.soft`). Sarı ve yeşilin yalnızca durumlar için kullanılması kuralının tek istisnasıdır. Podyumda birinci ortada ve en yüksek basamakta durur.
- Saat: sırası gelen tarafın saati mor zeminde beyaz yazı; 20 saniyenin altında kırmızı. Rakamlar sabit genişlikte (`tabularFigures`).

## 2. Tipografi — `GwTypography`

Yazı tipi **Plus Jakarta Sans**'tır (OFL). 400, 500, 600 ve 700 ağırlıkları pakete gömülüdür, çalışma anında indirilmez.

| Stil | Boyut / satır | Ağırlık |
|---|---|---|
| `displayLarge` | 32 / 40 | 700, harf aralığı −0,6 |
| `headlineMedium` | 24 / 32 | 700, harf aralığı −0,4 |
| `titleLarge` | 20 / 28 | 700, harf aralığı −0,2 (bölüm başlıkları) |
| `titleMedium` | 16 / 24 | 600 |
| `bodyLarge` | 16 / 24 | 400 |
| `bodyMedium` | 14 / 20 | 400 |
| `labelLarge` | 14 / 20 | 600 |
| `labelMedium` | 12 / 16 | 500 |

## 3. Boşluk — `GwSpacing`

Boşluklar 4'ün katlarıdır: `xxs 4`, `xs 8`, `sm 12`, `md 16`, `lg 24`, `xl 32`, `xxl 48`. Sayfa yatay iç boşluğu `md` (16) olur.

## 4. Yarıçap — `GwRadius`

`sm 8` (çip, küçük öğe), `md 12` (buton, girdi), `lg 16` (kart, grup avatarı), `xl 24` (alt sayfa, büyük kart).

## 5. Yükselti

Gölge kullanılmaz. Sayfa zemini `GwBackdrop`'tur (§1), içerik beyaz kartlardadır (`GwCard`: `xl` ya da `lg` yarıçap, `border` renginde 1 px çizgi). Ayrım kenar çizgisiyle (`GwBorders.hairline`) ve kartlar arası boşlukla yapılır; bölümler arasında tam genişlik ayraç kullanılmaz. Hikaye halkası ve seçili medya çerçevesi `GwBorders.ringWidth` (2 px) kalınlığındadır.

## 6. Bileşenler

| Bileşen | Kural |
|---|---|
| `GwButton` | `primary` (dolu mor, beyaz metin), `secondary` (beyaz zemin, `border` çizgisi, mavi metin), `text` (zeminsiz, mor metin). Yüksekliği 48, en az 44×44 dokunma alanı. Yüklenme durumu vardır. |
| `GwAvatar` | Kullanıcı: **daire**. Grup: **yuvarlatılmış kare** (`GwRadius.lg` orantılı). Görsel yoksa baş harf, adın tonunda (`GwTone`) gösterilir. |
| `GwSkeleton` | Yüklenirken içerik yerine gösterilir. Spinner yerine iskelet tercih edilir. |
| `GwEmptyState` | Her boş listede **ikon + tek cümle açıklama + bir aksiyon** bulunur. |
| `GwErrorState` | Yükleme hatasında ikon + güvenli mesaj + "Tekrar dene". |
| `GwFormMessage` | Formun altında satır içi hata veya bilgi mesajı. |
| `GwPanel` | Beyaz, ince çerçeveli içerik kartı; isteğe bağlı başlık / alt başlık / sağ aksiyon. Her zaman tam genişlik kaplar. |
| `GwCard` | Sayfaların yapı taşı: beyaz, ince çizgili, yuvarlatılmış kart; isteğe bağlı dokunma. |
| `GwSectionHeader` | Bölüm başlığı (`titleLarge`), isteğe bağlı alt başlık ve sağda "Tümü ›" türü bağlantı. |
| `GwDateTile` | Organizasyonların takvim yaprağı: kısa ay (EKİ) üstte, gün büyük; grubun tonunda. |
| `GwTag` | Yumuşak tonlu, ikonlu hap etiket: kategori, ilgi alanı. |
| `GwChipRail` | Ekrana sığmayan çip şeridi (kategori, filtre; 2026-11-01). Parmakla, fareyle sürükleyerek ya da dokunmatik yüzeyle yana kayar. Sığmayan çip olan kenar şeffaflaşarak solar ve orada ok düğmesi (32 daire, 48 dokunma alanı, "Öncekiler" / "Sonrakiler") belirir; ok ekranın %80'i kadar kaydırır. Her şey sığarsa ok ve solma yoktur. Grup keşfi ve harita filtreleri kullanır. |
| `GwBadge` | Durum ve rol etiketi (`neutral`, `primary`, `info`, `danger`), durumlar için noktalı. Sığmayan metin üç noktayla kısalır. |
| `GwLiveBadge` | Mor→mavi gradyanlı "CANLI" rozeti (canlı yayın kartı, yayın odası, ana sayfa şeridi, admin listesi). |
| `GwLiveButton` | Gradyanlı "Yayın başlat" düğmesi; dakika bitmişse gri ve pasif. |
| `GwReadingColumn` | Profil ve grup sayfalarının orta sütunu (720; ana sayfada `feedMaxWidth`). Yan çizgi yoktur. |
| `GwHeroCard` | Profil ve grubun kimlik kartı: kapak (telefonda 2:1, geniş ekranda 2,5:1; yoksa tonun zemini ve soluk kategori ikonu) kartın içindedir; avatar kapağın altında, adın solunda durur, kapağa taşmaz. Altında sayfanın kendi içeriği (biyografi, meta, istatistik, aksiyonlar). Yüklenirken `GwHeroCardSkeleton`. |
| `categoryIcon` | Ortak kategorilerin ikonları (profil ilgi alanları ve grup kategorileri aynı ikonu kullanır). |
| `GwLogo` | Marka sembolü, isteğe bağlı "GWAY" yazısıyla. Tonlar: `color`, `onPrimary`, `onDark`. Ayrıntılar: `docs/brand/README.md`. |
| `GwSplash` | Uygulama açılırken logo ve yükleme göstergesi. Web'de Flutter yüklenene kadar `index.html` içindeki aynı tasarımlı ön yükleyici görünür. |

## 7. Sayfa düzenleri

| Token (`GwLayout`) | Değer | Kullanım |
|---|---|---|
| `formMaxWidth` | 440 | Giriş, kayıt gibi formlar |
| `contentMaxWidth` | 720 | Profil, okuma içerikleri, düzenleme sayfaları |
| `dashboardMaxWidth` | 1200 | Admin panelinin içerik alanı |
| `sidebarWidth` | 256 | Admin yan menüsü |
| `wideBreakpoint` | 960 | Bu genişlikten itibaren yan menü ve çok sütunlu içerik |
| `feedMaxWidth` | 560 | Bugün, gönderi, yorum ve paylaşım sayfaları (gönderi kartı ortalı) |

- **Bugün (ana sayfa):** Üst çubukta tarih ve selamlama ("İyi akşamlar, Demo"), sağda Ara, Bildirimler, Mesajlar. Sırasıyla: "Şimdi canlı" (canlı yayın kartları, yalnızca yayın varsa), "Yakında başlıyor" (önümüzdeki 6 saat, yalnızca varsa), "Hikâyeler" (küçük çipler, ilki "Hikâye ekle"), "Akış" (gönderi kartları). "Bu akşam" ve "Yaklaşanlar" ana sayfayı kalabalıklaştırmasın diye ortadaki mor "+" butonundan ayrı sayfalarda açılır (kullanıcı isteği, 2026-11-01).
- **"+" (Oluştur) sayfası:** Alttan açılan sayfa. Üstte "Bugün için" başlığıyla yan yana iki büyük kısayol: "Bu akşam" (lilac; canlı durum: kaç kişi boş, masa ya da davet; boşsa ikonda yeşil nokta) ve "Yaklaşanlar" (sky; plan ve katılım sayısı). Altında "Paylaş": Gönderi, Hikâye, Grup.
- **Yaklaşanlar sayfası (`/upcoming`):** Gruplarının 60 gün içindeki organizasyonları gün gün ("Bugün", "Yarın", gün adı ve tarih); her gün bir beyaz kartta, satırlarda saat karosu, başlık, grup, yer, durum etiketi (Katılıyorsun, Yedek listede, Onay bekliyor, Dolu) ve katılımcı sayısı. Üstte "Tümü" ve "Katıldıklarım" çipleri, sağ üstte Takvim. Boşsa "Grup bul".
- **Bu akşam sayfası (`/tonight`):** Gelen masa davetleri en üstte; "Durumun" kartı (ikon karosu, "Boşsun" rozeti, not, üst üste binen yüzler ve sayı, "Durumu kapat"); "Küçük masa" ya da "Masan" kartı (Kuruluyor / Sohbet açık rozeti); "Bu akşam boş olanlar" listesi tek kartta; en altta üç adımlık "Nasıl işler?". Not penceresinde hazır öneri çipleri (Kahve, Kısa yürüyüş, Yemek, Sinema).
- **Gönderi kartı:** `lg` yarıçaplı beyaz kart. Başlıkta avatar, ad ve "@kullanıcı · 3 dk" satırı; medya kartın içinde `md` yarıçapla; altında sayılı beğeni, yorum ve paylaş, sağda kaydet; sonra açıklama ve "Anı" etiketi.
- **Profil:** Kimlik kartı (`GwHeroCard`): avatar mobilde 64, geniş ekranda 96. İçinde rozetler, biyografi, katılım tarihi, ilgi alanı etiketleri (`GwTag`, kendi tonunda), üç istatistik kutusu (Gönderi / Takipçi / Takip; `surface` zeminli) ve aksiyonlar (kendi profilinde tam genişlik "Profili düzenle"; başkasında Mesaj, Takip et, ⋯). Profil fotoğrafı ve kapak yalnızca "Profili düzenle" ekranından değişir (profil sayfasında kalıcı düzenleme düğmesi yok). Kendi profilinin üst çubuğunda Kaydedilenler ve Ekip arkadaşı bul kısayolları. Öne çıkanlar çip rafı olarak gönderilerin üstündedir.
- **Grup sayfası:** Kimlik kartında logo (yuvarlatılmış kare), ad, @adres, tanıtım, kategori etiketi ve meta, altında aksiyonlar: Katıl / Katılma isteği gönder / İstek gönderildi / Daveti kabul et + Reddet / Üyesin (dokununca ayrılma onayı) / Grubu düzenle. Üyelik bilgisi yüklenmeden aksiyon gösterilmez. Askıdaki grupta hata tonunda bir uyarı bandı görünür. Grup araçları (sohbet, moderasyon, yayın, paket, destek) kimlik kartının altında ayrı bir kartta; Kurallar, Bağlantılar ve Yönetim ekibi kendi kartlarında; organizasyonlar, hedefler, anketler ve gönderiler zemin üzerinde bölüm başlıklarıyla.
- **Gruplar ekranı:** Üstte bekleyen davetler paneli, altında "Keşfet / Gruplarım" seçimi. Keşfet: arama, yatay kaydırılan kategori çipleri, grup kartları (logo, ad, kategori · üye sayısı, serbest değilse katılım tipi).
- **Sosyal uygulama gezinmesi:** Telefonda yüzen dok (`xl` yarıçaplı beyaz kart): Bugün, Gruplar, ortada mor "+" (Oluştur: Bu akşam, Yaklaşanlar, Gönderi, Hikâye, Grup), Takvim, Ben; seçili hedef `primarySoft` hap ve mor etiketle. Dok yalnızca üst düzey sayfalarda görünür. Geniş ekranda (`wideBreakpoint`) 256 genişliğinde etiketli yan menü: logo, hedefler, Bildirimler, Mesajlar, "Oluştur" butonu ve "Gruplarım" (en çok 8 grup). Yan menü tam ekran medya ve yayın odası dışında her sayfada kalır; üst düzey sayfalar ortalı sütunda açılır.
- **Giriş ve kayıt:** Form beyaz kartta. Uygulamanın giriş ve kayıt ekranında geniş ekranda solda yarı saydam beyaz tanıtım paneli ("Topluluğun seni bekliyor." ve üç madde); admin girişinde yalnızca logo ve kart.
- **Sekmeler:** Seçili sekme, kenarlardan içeri çekilmiş `primarySoft` hap ile belirtilir (alt çizgi yok).
- **Paket kartı (grup sayfası):** Tanıtımın altında, `surface` zeminli ince çizgili kart: paket ikonu, "Başlangıç paketi · 9 Kasım 2026 tarihine kadar", üye kullanımı ve "Paket" bağlantısı. Limit dolunca hata tonunda, bitişe 7 gün kala `primarySoft` tonunda tek satırlık uyarı. Yalnızca sahip görür; onay yetkisi olanlar yalnızca "limit doldu" uyarısını görür.
- **Paket ekranı:** Üstte "Mevcut paket" paneli (paket rozeti, dönem sonu, üye kullanım çubuğu, limitler, sıradaki dönemler). Web'de sahip için altında "Paketler" başlığı, Aylık / Yıllık · 2 ay bedava seçimi, sağlayıcı ve para birimi notu ve paket kartları: geniş ekranda eşit yükseklikte dört sütun, telefonda alt alta. Mevcut paket mor kenarlıkla ve rozetle işaretlenir. Kartın altında satın alma türüne göre ne zaman başlayacağı ve aktarılan süre yazar. Ana aksiyon (Seç / Yükselt) dolu, yenileme ve alt pakete geçiş çerçeveli butondur. Ödemeden dönüşte üstte durum bandı görünür (onaylanıyor / alındı / tamamlanamadı).
- **Ödeme ekranı:** Geniş ekranda solda "Fatura bilgileri" formu, sağda "Sipariş özeti"; telefonda özet üstte. Özette paket, limitler, başlangıç, tahmini bitiş, aktarılan süre ve toplam; altında sağlayıcı güvencesi notu. Sözleşme onay kutusundaki başlık bağlantıdır, metni alttan açılan sayfada gösterir. Buton "Ödemeye geç · 699 ₺", kilit ikonlu.
- **Destek (sosyal uygulama):** Ayarlar'da "Destek ve geri bildirim" satırı, okunmamış yanıt varsa mor rozetle sayısı. Liste satırında türün ikonu kendi soft renginde yuvarlatılmış karede, konu, "Tür · grup · tarih", sağda durum rozeti (nötr) ve gerekirse "Yeni yanıt". Yeni mesaj: üç seçilebilir tür kartı (seçilince kendi soft zemini ve renkli kenarlığı), ardından tek panelde grup seçimi (yalnızca yönetilen grup varsa), konu, açıklama, ekran görüntüleri (küçük önizleme + kaldır). Yazışma: kullanıcının mesajları sağda `primarySoft`, ekibin mesajları solda beyaz ve ince çizgili, "GWAY Ekibi" etiketiyle; altta yanıt kutusu. Grup yöneticileri grup sayfasında "Bu grupla ilgili platform ekibine yaz" bağlantısını görür.
- **Admin paneli:** Solda marka ve menü, altta oturum açan ekip üyesi ve çıkış. İçerik `surface` zemin üzerinde `GwPanel` kartlarından oluşur. Sayfa başlığı `headlineMedium` ve alt başlık; detay sayfalarında breadcrumb. Liste sayfaları: özet sayaç kartları (tıklayınca filtreler), arama + durum filtresi, geniş ekranda sütunlu tablo, dar ekranda kompakt satır. Menüde "Gelir" başlığı altında Abonelikler ve Paketler (yönetici ve destek) bulunur. Abonelikler: para tutarlı sayaç kartları ve aylık gelir tablosu (yalnızca yönetici), Ödemeler / Abonelikler seçimi ile listeler; bir saatten eski ödenmemiş sipariş "Yarım kaldı" rozetiyle görünür. Paketler: her paket bir panel, limitler ve fiyatlar etiket–değer çiftleri, "Düzenle" diyaloğu. Destek: türe göre renkli sayaç kartları (Açık sorunlar kırmızı, Açık talepler sarı, Açık istekler yeşil; tıklayınca o türe süzer) ve "Yanıt bekleyen"; listede tür ikonu, konu, gönderen, grup, mesaj sayısı, durum ve "Yanıt bekliyor" rozeti. Detayda solda yazışma ve yanıt kutusu, sağda tür, durum seçimi, gönderen ve grup bağlantıları.

### Medya ölçüleri — `GwMedia`

Tüm medya sayıları bu sınıftadır; feed kodunda oran, piksel veya kalite değeri yazılmaz.

| Token | Değer | Kullanım |
|---|---|---|
| `square` | 1 | 1:1 kırpma |
| `portrait` | 4/5 | 4:5 kırpma; akışta en dar oran |
| `landscape` | 1.91 | 1.91:1 kırpma; akışta en geniş oran |
| `story` | 9/16 | Hikaye kadrajı ve arşiv karosu |
| `gridTile` | 4/5 | Profil, grup, keşfet, etiket ve kaydedilenler ızgarası (dikey karo, ortadan kırpılır) |
| `gridColumns` | 3 | Izgara sütunu |
| `gridGap` | 8 | Izgara boşluğu; karolar ayrı, sayfa kenar boşluğu içinde |
| `gridRadius` | 12 | Izgara karosunun köşe yarıçapı |
| `uploadMaxSide` | 1440 | Gönderi fotoğrafının yüklenen en uzun kenarı |
| `storyMaxSide` | 1920 | Hikaye fotoğrafının yüklenen en uzun kenarı (1080×1920) |
| `thumbMaxSide` | 480 | Küçük kopyanın en uzun kenarı |
| `jpegQuality` | 85 | Cihazda üretilen JPEG kalitesi |
| `pickMaxSide` | 2880 | Seçiciden alınan görselin üst sınırı (işlem süresi için) |
| `storyFitTolerance` | 0.1 | Hikaye 9:16'ya bu kadar yakınsa ekranı doldurur |
| `backdropBlur` | 24 | Ekranı doldurmayan hikayenin arkasındaki bulanık kopya |
| `maxZoom` | 5 | Kırpmada en fazla yakınlaştırma |

- **Kırpma:** Oluşturma ekranında seçilen medya kadraj içinde gösterilir. Oran seçimi: Orijinal (4:5–1.91:1 aralığına sıkıştırılır), 1:1, 4:5, 1.91:1. Parmakla yakınlaştırılır, sürükleyerek kadrajlanır. Karuseldeki tüm öğeler aynı oranı kullanır. Hikaye kadrajı her zaman 9:16'dır.
- **Gösterim:** Akış kartının oranı ilk medyanın oranıdır; karuseldeki her öğe bu kutuyu doldurur (ortadan kırpılır). Görseller kutunun ekrandaki genişliği × piksel yoğunluğu kadar çözülür (`cacheWidth`). Önce küçük kopya, üstüne büyük kopya yumuşak geçişle gelir; yüklenirken iskelet aynı oranda kalır, sayfa kaymaz.
- **Hikaye görüntüleyici:** Medya 9:16'ya `storyFitTolerance` kadar yakınsa ekranı doldurur; değilse sığdırılır ve arkasında aynı görselin bulanık hali görünür (siyah bant yok).
- **Video:** Cihazda dönüştürülmez; kadraj kutusunu doldurur. Kapak görseli üretilmez (video oynatıcının ilk karesi gösterilir; ızgarada video ikonu).

## 8. Erişilebilirlik

- WCAG AA kontrast.
- En az 44×44 dokunma alanı.
- Yazı ölçeği %130'a çıktığında düzen bozulmaz, taşma olmaz. Bu, kritik ekranlar için widget testleriyle doğrulanır.
- İkon butonlarda `tooltip` / `semanticLabel` zorunludur.

## 9. Karanlık tema

Faz 9'da eklenir. O zamana kadar yalnızca açık tema vardır.
