#!/bin/bash

# Configuration
APP_NAME="Browserly"
BUILD_DIR=".build/apple/Products/Release"
STAGING_DIR="dmg_staging"
DMG_NAME="Browserly.dmg"

echo "🔨 Building Universal Release Binary..."

# Build for Apple Silicon (arm64)
echo "   - Building arm64..."
swift build -c release --triple arm64-apple-macosx

# Build for Intel (x86_64)
echo "   - Building x86_64..."
swift build -c release --triple x86_64-apple-macosx

# Create staging area
rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"

# Note: For a real .app bundle, we usually use an Xcode project. 
# For SwiftPM executables, we create a basic structure.
echo "📦 Packaging into .app structure..."
APP_BUNDLE="$STAGING_DIR/$APP_NAME.app"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Merge binaries using lipo
ARM64_EXEC=".build/arm64-apple-macosx/release/$APP_NAME"
X86_64_EXEC=".build/x86_64-apple-macosx/release/$APP_NAME"
UNIVERSAL_EXEC="$APP_BUNDLE/Contents/MacOS/$APP_NAME"

echo "🧬 Creating Universal Binary via lipo..."
lipo -create -output "$UNIVERSAL_EXEC" "$ARM64_EXEC" "$X86_64_EXEC"

# Verify universal binary
file "$UNIVERSAL_EXEC"

chmod +x "$UNIVERSAL_EXEC"
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
