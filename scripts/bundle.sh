#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

APP_NAME=MantisShrimp
BUNDLE_ID=dev.veelenga.mantisshrimp
VERSION=${VERSION:-0.1.0}
OUT=build/$APP_NAME.app

swift build -c release ${SWIFT_BUILD_FLAGS:-}
BIN_DIR="$(swift build -c release ${SWIFT_BUILD_FLAGS:-} --show-bin-path)"

ICONSET=build/AppIcon.iconset
rm -rf "$OUT" "$ICONSET"
mkdir -p "$OUT/Contents/MacOS" "$OUT/Contents/Resources"
cp "$BIN_DIR/$APP_NAME" "$OUT/Contents/MacOS/$APP_NAME"
"$BIN_DIR/ShrimpIconTool" "$ICONSET"
iconutil -c icns "$ICONSET" -o "$OUT/Contents/Resources/AppIcon.icns"

cat > "$OUT/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key><string>en</string>
  <key>CFBundleExecutable</key><string>$APP_NAME</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>CFBundleIdentifier</key><string>$BUNDLE_ID</string>
  <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
  <key>CFBundleName</key><string>$APP_NAME</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>$VERSION</string>
  <key>CFBundleVersion</key><string>$VERSION</string>
  <key>LSMinimumSystemVersion</key><string>14.0</string>
  <key>LSUIElement</key><true/>
  <key>NSCameraUsageDescription</key><string>MantisShrimp watches your posture through the camera so it can warn you when you slouch or raise a shoulder. Frames are analyzed on this Mac and never stored or sent anywhere.</string>
  <key>NSHumanReadableCopyright</key><string>Vitalii Elenhaupt</string>
</dict>
</plist>
PLIST

codesign --force --sign - "$OUT"
echo "$OUT"
