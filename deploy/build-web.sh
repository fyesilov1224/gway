#!/usr/bin/env bash
# Builds the web app and the admin panel for production into deploy/www (docs/DEPLOY.md).
# Usage: deploy/build-web.sh <domain> <supabase-url> <supabase-publishable-key>
set -euo pipefail
domain="$1"; supabase_url="$2"; supabase_key="$3"
here="$(cd "$(dirname "$0")" && pwd)"
defines=(--dart-define=SUPABASE_URL="$supabase_url" --dart-define=SUPABASE_PUBLISHABLE_KEY="$supabase_key"
         --dart-define=API_URL="https://api.$domain" --dart-define=SHARE_URL="https://app.$domain")

for app in social_app:app admin_panel:panel; do
  src="${app%%:*}"; out="${app##*:}"
  (cd "$here/../app/apps/$src" && flutter build web --release "${defines[@]}")
  rm -rf "$here/www/$out" && mkdir -p "$here/www/$out"
  cp -r "$here/../app/apps/$src/build/web/." "$here/www/$out/"
done
echo "Built deploy/www/app and deploy/www/panel for $domain"
