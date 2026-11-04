#!/usr/bin/env bash
# Builds the web app and the admin panel for production into deploy/www (docs/DEPLOY.md).
# Usage: deploy/build-web.sh <domain> <supabase-url> <supabase-publishable-key>
set -euo pipefail
domain="$1"; supabase_url="$2"; supabase_key="$3"
here="$(cd "$(dirname "$0")" && pwd)"
# Flutter's icon subsetter writes an empty fonts folder from a non-ASCII path (the ı in the Windows user name),
# and every icon then shows as a box. Build from an ASCII path such as `subst G:` (docs/DEPLOY.md).
if LC_ALL=C grep -q '[^ -~]' <<<"$here"; then
  echo "Build from an ASCII path (e.g. subst G: <repo>), not $here" >&2; exit 1
fi
defines=(--dart-define=SUPABASE_URL="$supabase_url" --dart-define=SUPABASE_PUBLISHABLE_KEY="$supabase_key"
         --dart-define=API_URL="https://api.$domain" --dart-define=SHARE_URL="https://app.$domain")

for app in social_app:app admin_panel:panel; do
  src="${app%%:*}"; out="${app##*:}"
  (cd "$here/../app/apps/$src" && flutter build web --release "${defines[@]}")
  if [ ! -s "$here/../app/apps/$src/build/web/assets/fonts/MaterialIcons-Regular.otf" ]; then
    echo "$src: icon font missing from the build; not publishing broken icons" >&2; exit 1
  fi
  # Voice calls are end-to-end encrypted; in the browser that runs in this worker (docs/ARCHITECTURE.md §8c).
  if [ "$src" = social_app ] && [ ! -s "$here/../app/apps/$src/build/web/e2ee.worker.dart.js" ]; then
    echo "$src: e2ee.worker.dart.js missing; voice calls would not connect" >&2; exit 1
  fi
  rm -rf "$here/www/$out" && mkdir -p "$here/www/$out"
  cp -r "$here/../app/apps/$src/build/web/." "$here/www/$out/"
done
# Play Console declarations link to videos served from app.<domain>/play/ (docs/PLAY_STORE.md).
if [ -d "$here/play-assets" ]; then
  mkdir -p "$here/www/app/play" && cp -r "$here/play-assets/." "$here/www/app/play/"
fi
echo "Built deploy/www/app and deploy/www/panel for $domain"
