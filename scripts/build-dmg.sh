#!/bin/bash

# Configuration
APP_NAME="Browserly"
BUILD_DIR=".build/apple/Products/Release"
STAGING_DIR="dmg_staging"
DMG_NAME="Browserly.dmg"

echo "🔨 Building Release Binary..."
swift build -c release

# Create staging area
rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"

# Note: For a real .app bundle, we usually use an Xcode project. 
# For SwiftPM executables, we create a basic structure.
echo "📦 Packaging into .app structure..."
APP_BUNDLE="$STAGING_DIR/$APP_NAME.app"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Copy the release executable directly
EXEC_PATH=".build/release/$APP_NAME"
if [ ! -f "$EXEC_PATH" ]; then
    # Fallback for some Swift versions
    EXEC_PATH=".build/arm64-apple-macosx/release/$APP_NAME"
fi

cp "$EXEC_PATH" "$APP_BUNDLE/Contents/MacOS/"
chmod +x "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
cp "Sources/Browserly/Info.plist" "$APP_BUNDLE/Contents/Info.plist"
cp "Sources/Browserly/Resources/AppIcon.icns" "$APP_BUNDLE/Contents/Resources/"

# Apply ad-hoc code signature
echo "🔐 Signing bundle..."
codesign --force --deep -s - "$APP_BUNDLE"

# Add Applications symlink for easy installation
echo "🔗 Adding Applications symlink..."
ln -s /Applications "$STAGING_DIR/Applications"

# Create DMG
echo "💿 Creating DMG..."
rm -f "$DMG_NAME"
hdiutil create -volname "$APP_NAME" -srcfolder "$STAGING_DIR" -ov -format UDZO "$DMG_NAME"

echo "✅ DMG Created: $DMG_NAME"
