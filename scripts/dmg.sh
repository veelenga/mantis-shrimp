#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

APP_NAME=MantisShrimp
VERSION=${VERSION:-0.1.0}
APP=build/$APP_NAME.app
STAGING=build/dmg
DMG_NAME=$APP_NAME-$VERSION.dmg

rm -rf "$STAGING" "build/$DMG_NAME" "build/$DMG_NAME.sha256"
mkdir -p "$STAGING"
cp -R "$APP" "$STAGING/"
ln -s /Applications "$STAGING/Applications"
hdiutil create -volname "$APP_NAME" -srcfolder "$STAGING" -ov -format UDZO "build/$DMG_NAME" >/dev/null
(cd build && shasum -a 256 "$DMG_NAME" > "$DMG_NAME.sha256")
echo "build/$DMG_NAME"
