#!/bin/bash

cd "$(dirname "$0")/.."

# Build the Swift package
echo "Building for production..."
swift build -c release

# Create app bundle structure
APP_NAME="Bowzer"
BUILD_DIR="build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy executable
cp ".build/release/$APP_NAME" "$MACOS_DIR/$APP_NAME"

# Copy Info.plist
cp "Bowzer/Resources/Info.plist" "$CONTENTS_DIR/Info.plist"

# Create PkgInfo
echo -n "APPL????" > "$CONTENTS_DIR/PkgInfo"

echo "Built $APP_BUNDLE"
echo ""
echo "To install:"
echo "  cp -r $APP_BUNDLE /Applications/"
echo ""
echo "Then set Bowzer as default browser in System Settings > Desktop & Dock > Default web browser"
