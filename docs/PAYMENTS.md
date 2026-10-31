# Ödeme sağlayıcılarını bağlama (PayTR ve iyzico)

Kod hazırdır: sipariş, ödeme sayfası, imzalı bildirimler, süre yerleşimi, iade işareti ve admin görünümü çalışır ve testlidir (`docs/ARCHITECTURE.md` §7). Üyelik açıldığında yapılacak tek şey **anahtarları girmek** ve **bildirim adresini sağlayıcının paneline yazmaktır**. Anahtar yoksa ilgili pazarda satış kendiliğinden kapalıdır (ekranda "Ödeme şu anda alınamıyor").

| Sağlayıcı | Kimden ödeme alır | Para birimi | Gerekenler |
|---|---|---|---|
| PayTR | Türkiye'deki IP'ler | TL | Mağaza no, mağaza parola (key), mağaza gizli anahtar (salt), bildirim URL'si |
| iyzico | Yurt dışındaki IP'ler | USD | API anahtarı, güvenlik anahtarı, ortam adresi (sandbox ya da canlı), webhook adresi |

Durumu her an **admin paneli → Abonelikler → Ödeme sağlayıcıları** kartında görürsün. Kartta şunlar yer alır:
- anahtarların girilip girilmediği,
- test mi canlı mı olduğu,
- panele yapıştırılacak adresler (kopyala butonuyla),
- eksikler,
- **Bağlantıyı dene** butonu.

Kart anahtarların kendisini hiçbir zaman göstermez.

---

## 1. Başvuru öncesi hazırlık

İki sağlayıcı da başvuruda web sitesini inceler. Hazır olanlar:
- **Herkese açık sayfalar:** `/#/kosullar` (kullanım koşulları), `/#/gizlilik` (gizlilik ve KVKK), `/#/hesap-silme`.
- **Mesafeli satış sözleşmesi:** Satın alma ekranında gösterilir ve onaylatılır. Sürümünü admin panelinden yayımlarsın (Hukuki metinler).
- **Ürün ve fiyatlar:** Paketler sayfası açık. Ürünler dijital ve ön ödemeli; otomatik yenileme yok.

Senden beklenenler:
- Şirket ya da şahıs şirketi bilgileri, vergi levhası, IBAN.
- Canlı alan adı (ör. `gway.app`) ve https'li sunucu (`docs/DEPLOY.md`). Bildirimler yalnızca dışarıdan erişilebilen adrese gelir.
- İletişim bilgileri ve iade/iptal koşulları metni. Hukuki inceleme bekleniyor; ön ödemeli dijital hizmette cayma hakkı istisnası avukatla netleştirilmeli.

## 2. PayTR (Türkiye, TL)

1. **Mağaza başvurusu:** paytr.com üzerinden "iFrame API" entegrasyonu ile başvur. Onaydan önce mağaza test modunda çalışır.
2. **Anahtarlar:** Mağaza panelinde *Destek & Kurulum → Entegrasyon Bilgileri* altında üç bilgi vardır: mağaza no (`merchant_id`), mağaza parola (`merchant_key`), mağaza gizli anahtar (`merchant_salt`).
3. **Bildirim URL'si:** Mağaza panelinde *Destek & Kurulum → Ayarlar → Bildirim URL* alanına admin kartındaki adresi yaz: `https://api.<alan-adı>/billing/paytr/notify`. Protokol olarak https seç. PayTR ödeme sonucunu yalnızca buraya gönderir. API bildirimi imzasıyla doğrular ve `OK` yanıtı verir. Kullanıcının tarayıcısının dönüşü ödemeyi kesinleştirmez.
4. **Test:**
   - `Billing:Paytr:TestMode=true` (varsayılan) iken kartlardan para çekilmez.
   - PayTR dokümanındaki test kartlarıyla dene. Yaygın olanı: `4355 0843 5508 4358`, son kullanma `12/30`, CVV `000`. Güncelini PayTR dokümanından kontrol et.
5. **Canlıya geçiş:** PayTR mağazayı onaylayınca `Billing:Paytr:TestMode=false` yap ve API'yi yeniden başlat. Admin kartında rozet "Canlı" olur.

Menü adları PayTR panelinde zamanla değişebilir; alan adları (`merchant_id`, `merchant_key`, `merchant_salt`, "Bildirim URL") aynı kalır.

## 3. iyzico (yurt dışı, USD)

1. **Sandbox hesabı:** `sandbox-merchant.iyzipay.com` adresinden ücretsiz açılır; başvuru gerekmez. Bağlantıyı hemen denemek için en kolay yol budur.
2. **Anahtarlar:** iyzico panelinde *Ayarlar → Firma Ayarları* altında API anahtarı ve güvenlik anahtarı bulunur. Sandbox ve canlı anahtarlar **farklıdır**; ortam adresiyle eşleşmelidir:
   - sandbox: `Billing:Iyzico:BaseUrl=https://sandbox-api.iyzipay.com` (varsayılan)
   - canlı: `Billing:Iyzico:BaseUrl=https://api.iyzipay.com`
3. **Webhook:** iyzico panelinde *Ayarlar → Firma Ayarları → Bildirimler* (webhook) alanına admin kartındaki adresi yaz: `https://api.<alan-adı>/billing/iyzico/webhook`. Dönüş (callback) adresi her siparişte otomatik gönderilir; panelde ayarlanmaz. API ödeme sonucunu her zaman iyzico'ya ayrıca sorarak kesinleştirir. Webhook imzası `X-IYZ-SIGNATURE-V3` ile doğrulanır.
4. **Test kartı (sandbox):** `5528 7900 0000 0008`, son kullanma `12/30`, CVC `123`. Diğer test kartları iyzico dokümanındadır.
5. **USD:** Canlı hesapta yabancı para birimiyle tahsilat için iyzico'dan ayrıca onay istenmesi gerekebilir. Başvuruda belirt.
6. **Canlıya geçiş:** Canlı anahtarları ve canlı `BaseUrl`'yi gir, webhook'u canlı panelde de tanımla.

## 4. Anahtarları girmek

### Yerelde (geliştirme)
Anahtarlar `dotnet user-secrets` ile bilgisayarında saklanır. Repoya girmez ve ortam değişkeni gerekmez:

```powershell
powershell -ExecutionPolicy Bypass -File backend\scripts\payment-keys.ps1 paytr    # PayTR anahtarlarını sorar
powershell -ExecutionPolicy Bypass -File backend\scripts\payment-keys.ps1 iyzico   # iyzico anahtarlarını sorar
powershell -ExecutionPolicy Bypass -File backend\scripts\payment-keys.ps1 show     # kayıtlıları gösterir (gizli kısımlar maskeli)
powershell -ExecutionPolicy Bypass -File backend\scripts\payment-keys.ps1 clear    # hepsini siler
```

Ardından API'yi yeniden başlat. Açılışta günlükte `Payments: paytr configured (test mode: True)` gibi bir satır ve varsa eksikler görünür.

**Bildirimleri yerelde almak:** Sağlayıcı `localhost`'a ulaşamaz. Geçici bir https tüneli aç (ör. `cloudflared tunnel --url http://localhost:5089`). Sonra şunu çalıştırıp tünel adresini gir:

```powershell
powershell -ExecutionPolicy Bypass -File backend\scripts\payment-keys.ps1 tunnel
```

Betik, panele yazılacak iki adresi de yazdırır. Tünel adresi her açılışta değişir; PayTR'daki bildirim URL'sini de güncellemen gerekir. Tünel yoksa ödeme sayfası açılır ama sonuç bildirimi gelmez ve sipariş "bekliyor" kalır. iyzico'da tarayıcı dönüşü sonucu iyzico'dan sorduğu için tünel olmadan da kesinleşebilir.

**Pazar seçimi yerelde:** İstek `127.0.0.1`'den geldiği için pazar `Geo__FallbackCountry` ile belirlenir. Varsayılan `TR` PayTR'ı seçer. iyzico'yu denemek için API'yi `Geo__FallbackCountry=DE` ile başlat.

### Sunucuda (yayın)
`deploy/.env` dosyasına aynı adlar ortam değişkeni olarak yazılır (`deploy/.env.example`):

```
Billing__Paytr__MerchantId=...
Billing__Paytr__MerchantKey=...
Billing__Paytr__MerchantSalt=...
Billing__Paytr__TestMode=true          # canlıda false
Billing__Iyzico__ApiKey=...
Billing__Iyzico__SecretKey=...
Billing__Iyzico__BaseUrl=https://sandbox-api.iyzipay.com   # canlıda https://api.iyzipay.com
```

`Billing__AppUrl` ve `Billing__PublicApiUrl` compose dosyasında `DOMAIN`'den otomatik üretilir (`https://app.<alan-adı>`, `https://api.<alan-adı>`). Ardından `docker compose up -d api` çalıştır.

## 5. Bağlantıyı doğrulamak

1. Admin paneli → Abonelikler → **Ödeme sağlayıcıları** kartında sağlayıcıdan **Bağlantıyı dene**.
   - PayTR için 1 TL'lik, kimsenin ödemeyeceği bir test siparişine ödeme anahtarı istenir. Bu, gerçek satın almayla aynı imza yoludur; para çekilmez.
   - iyzico için imzalı bir taksit sorgusu yapılır; ödeme açılmaz.
   - Başarılıysa "Bağlantı başarılı" görünür. Başarısızsa sağlayıcının verdiği gerekçe yazar.
2. Kartta uyarı kalmadığından emin ol. Bildirim adresi https olmalı, yerel olmamalı.
3. Uçtan uca deneme:
   1. Web'de bir grup sahibiyle Grup → Paketler → Paket al ile test kartından ödeme yap.
   2. Ödeme sayfasından dönünce paket ekranı siparişi bekler, bildirim gelince paket açılır.
   3. Admin panelinde Abonelikler → Ödemeler'de sipariş "Ödendi" görünür.

## 6. Canlıya geçiş kontrol listesi

- [ ] Alan adı ve https'li sunucu çalışıyor (`docs/DEPLOY.md`)
- [ ] Hukuki metinler (koşullar, gizlilik, mesafeli satış, iade) avukat onaylı ve yayımlandı
- [ ] PayTR mağazası onaylandı, `TestMode=false`, Bildirim URL canlı adreste
- [ ] iyzico canlı anahtarları ve `BaseUrl=https://api.iyzipay.com`, webhook canlı panelde, USD tahsilat onaylı
- [ ] Admin kartında iki sağlayıcı da "Canlı" ve "Bağlantıyı dene" başarılı
- [ ] Küçük tutarlı gerçek bir ödeme yapıldı, sipariş "Ödendi" oldu, ardından admin panelinden iade işaretlendi ve sağlayıcı panelinden iade edildi
- [ ] Paket fiyatları admin panelinde (Paketler) son hâlinde

## 7. Sorun giderme

| Belirti | Neden ve çözüm |
|---|---|
| Ekranda "Ödeme şu anda alınamıyor", butonlar pasif | O pazarın anahtarları girilmemiş. Admin kartı "Anahtar yok" der. |
| "Bağlantıyı dene" PayTR: `paytr_token geçersiz` benzeri | Mağaza parola ya da gizli anahtar yanlış ya da yer değiştirmiş. |
| "Bağlantıyı dene" iyzico: `1001` ya da kimlik hatası | Anahtarlar başka ortamın (sandbox/canlı) ya da `BaseUrl` yanlış ortamda. |
| Ödeme yapıldı ama sipariş "Bekliyor" kaldı | Bildirim ulaşmadı. Bildirim URL'si panelde yanlış ya da API dışarıdan erişilemiyor. Admin kartındaki uyarılara bak. |
| API günlüğünde `PayTR notification ... has a wrong hash` | Bildirim geldi ama imza tutmadı: `MerchantKey`/`MerchantSalt` yanlış. |
| API günlüğünde `iyzico webhook ... has a wrong signature` | `SecretKey` webhook'u gönderen ortamla eşleşmiyor. |
| Ödemeden sonra uygulamaya dönülmüyor | `Billing:AppUrl` boş ya da yanlış. |

Satın alma yalnızca web'den yapılır; Android ve iOS uygulaması yalnızca paket durumunu gösterir (Apple ve Google kuralları, `docs/PLAY_STORE.md`).
