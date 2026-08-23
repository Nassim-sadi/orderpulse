#!/usr/bin/env bash
set -euo pipefail

PROJECT="deliverymanager-ffaf1"
APP_ID="1:694030655377:android:c1a0a66abb025a7e420430"
GROUPS="${APP_DIST_GROUPS:-drivers}"

BUILD_TYPE="${1:-release}"
NOTES="${2:-OrderPulse driver update}"

cd "$(dirname "$0")/.."

if [ "$BUILD_TYPE" = "debug" ]; then
  APK="build/app/outputs/flutter-apk/app-debug.apk"
  flutter build apk --debug
else
  APK="build/app/outputs/flutter-apk/app-release.apk"
  flutter build apk
fi

echo "Distributing $APK ($BUILD_TYPE) to groups: $GROUPS"

firebase appdistribution:distribute "$APK" \
  --app "$APP_ID" \
  --groups "$GROUPS" \
  --release-notes "$NOTES" \
  --project "$PROJECT"
