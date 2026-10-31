#!/usr/bin/env bash
# Generates platform folders (android, ios, web) for both apps.
# Run once after cloning, from the app/ directory: bash tool/setup_platforms.sh
set -euo pipefail

cd "$(dirname "$0")/.."

create() {
  local dir="$1" org="$2" name="$3"
  (cd "$dir" && flutter create --no-pub --platforms=android,ios,web --org "$org" --project-name "$name" .)
  # flutter create adds a sample test; the apps keep their own tests only.
  rm -f "$dir/test/widget_test.dart"
}

create apps/social_app com.gway social_app
create apps/admin_panel com.gway.admin admin_panel

flutter pub get
