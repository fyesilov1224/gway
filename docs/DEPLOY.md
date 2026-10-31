# Sunucu kurulumu (yayın)

API, LiveKit, web uygulaması ve yönetim paneli tek bir sunucuda Docker Compose ile çalışır. Caddy her alt alan adı için otomatik `https` sertifikası alır. Supabase barındırılan projedir. Kurallar: `docs/ARCHITECTURE.md` §10.

```
app.<alan adı>      → web uygulaması (www/app) + /#/gizlilik, /#/kosullar, /#/hesap-silme
panel.<alan adı>    → yönetim paneli (www/panel)
api.<alan adı>      → C# API
livekit.<alan adı>  → LiveKit sinyal (WebSocket); ses 7881/tcp ve 7882/udp
```

**Durum (2026-10-31):** Yayında. Alan adı `gwayapp.com` (Cloudflare, DNS kayıtları proxy'siz), sunucu Hetzner CX23 Helsinki `gway-1` (CX tipi Almanya'da tükenmişti), dosyalar sunucuda `/opt/gway/deploy`. Supabase Frankfurt'taki `GWAY` projesine taşındı (`ivrfovtlwwffmtlcmqmy`); eski Sidney projesi yedek olarak duruyor. Twilio, Stadia ve ödeme anahtarları boş (ilgili özellikler 503 ile kapalı).

## 1. Satın alınacaklar
- **Alan adı**, ör. `gway.app` (yıllık).
- **Sunucu**: Ubuntu 24.04, en az 2 vCPU ve 4 GB RAM. Örnek: Hetzner CX22, Almanya, aylık yaklaşık 5–7 €.
- **Supabase**: Mevcut proje Sidney'de. Türkiye'deki kullanıcılar için yayından önce Frankfurt'ta (eu-central-1) yeni bir proje açılması önerilir; migration'lar `supabase db push` ile kurulur.

## 2. DNS
Alan adının DNS panelinde dört **A** kaydı, hepsi sunucunun IP adresine: `app`, `panel`, `api`, `livekit`.

## 3. Sunucuyu hazırlama
```bash
# Sunucuda (root ya da sudo):
apt update && apt upgrade -y
curl -fsSL https://get.docker.com | sh
ufw allow 22/tcp && ufw allow 80/tcp && ufw allow 443/tcp && ufw allow 443/udp
ufw allow 7881/tcp && ufw allow 7882/udp && ufw enable
```

## 4. Dosyaları yükleme
Repoyu sunucuya kopyala (`git clone` ya da `scp`). Gerekenler `backend/` ve `deploy/` klasörleri.

```bash
cd deploy
cp .env.example .env    # sonra .env'i doldur
mkdir -p secrets        # firebase-adminsdk.json (push) ve isteğe bağlı ülke veritabanı buraya
```

`.env` içinde:
- `DOMAIN`: alan adı, alt alan adı olmadan.
- `ACME_EMAIL`: sertifika bildirimleri için e-posta.
- Supabase URL'si, service role anahtarı, veritabanı bağlantısı (Session pooler, `SSL Mode=Require`).
- LiveKit için iki uzun rastgele değer: `openssl rand -hex 16` ve `openssl rand -hex 32`.
- Twilio Verify anahtarları, Stadia harita anahtarı, ödeme anahtarları (boş kalanlar ilgili özelliği 503 ile kapatır). Ödeme sağlayıcılarını bağlama: `docs/PAYMENTS.md`.

## 5. Web uygulaması ve paneli derleme (geliştirme bilgisayarında)
```bash
deploy/build-web.sh <alan adı> <SUPABASE_URL> <SUPABASE_PUBLISHABLE_KEY>
# deploy/www/app ve deploy/www/panel klasörlerini sunucudaki deploy/www altına kopyala
```

## 6. Başlatma
```bash
cd deploy
docker compose up -d --build
docker compose logs -f api    # "Application started" görünmeli
curl https://api.<alan adı>/health   # Healthy
```

## 7. Supabase ayarları (panel: Authentication → URL Configuration)
- **Site URL**: `https://app.<alan adı>`
- **Redirect URLs**: `https://app.<alan adı>`, `https://panel.<alan adı>`, `com.gway.app://auth-callback` (Android uygulaması)
- Token hook açık olmalı (`supabase config push`, `docs/ARCHITECTURE.md` §3h).

## 8. Android uygulamasını sunucuya bağlama
```bash
cd app/apps/social_app
flutter build appbundle --release --no-tree-shake-icons \
  --dart-define=SUPABASE_URL=<SUPABASE_URL> \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<SUPABASE_PUBLISHABLE_KEY> \
  --dart-define=API_URL=https://api.<alan adı>
# Çıktı: build/app/outputs/bundle/release/app-release.aab → Play Console
```
Windows'ta kullanıcı adındaki `ı` yüzünden derleme `subst G: <repo>` ile `G:\app\apps\social_app` içinden yapılır.

## Güncelleme
```bash
git pull                      # ya da yeni dosyaları kopyala
cd deploy && docker compose up -d --build api
```
Veritabanı değişiklikleri `supabase db push --linked` ile gönderilir. Önce migration, sonra API güncellenir.

## Yedek ve izleme
- Veritabanı yedeği Supabase'te (günlük; Pro planda zamanda geri dönüş).
- `docker compose logs --since 1h api` ile son bir saatin günlüğü.
- `/health` ucunu bir izleme servisi (ör. UptimeRobot, ücretsiz) 5 dakikada bir çağırabilir.
