#!/bin/bash

# Configuration
APP_NAME="Browserly"
BUILD_DIR=".build/apple/Products/Release"
STAGING_DIR="dmg_staging"
DMG_NAME="Browserly.dmg"

echo "🔨 Building Release Binary..."
swift build -c release --arch arm64 --arch x86_64

# Create staging area
rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"

# Note: For a real .app bundle, we usually use an Xcode project. 
# For SwiftPM executables, we create a basic structure.
echo "📦 Packaging into .app structure..."
APP_BUNDLE="$STAGING_DIR/$APP_NAME.app"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp ".build/apple/Products/Release/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/"
cp "Sources/Browserly/Info.plist" "$APP_BUNDLE/Contents/Info.plist"

# Create DMG
echo "💿 Creating DMG..."
rm -f "$DMG_NAME"
hdiutil create -volname "$APP_NAME" -srcfolder "$STAGING_DIR" -ov -format UDZO "$DMG_NAME"

echo "✅ DMG Created: $DMG_NAME"
