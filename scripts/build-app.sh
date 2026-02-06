#!/bin/bash

set -e

cd "$(dirname "$0")/.."

APP_NAME="Bowzer"
BUILD_DIR="build"

# Clean previous build
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Build with xcodebuild
echo "Building for release..."
xcodebuild -scheme "$APP_NAME" -configuration Release -derivedDataPath "$BUILD_DIR/DerivedData" build 2>&1 | grep -E "(error:|warning:|BUILD)" | grep -v "metadata extraction" || true

# Check if build succeeded
APP_PATH="$BUILD_DIR/DerivedData/Build/Products/Release/$APP_NAME.app"
if [ ! -d "$APP_PATH" ]; then
    echo "Build failed - app not found at $APP_PATH"
    exit 1
fi

# Copy to build directory root for easier access
cp -r "$APP_PATH" "$BUILD_DIR/$APP_NAME.app"

echo ""
echo "Built $BUILD_DIR/$APP_NAME.app"
echo ""
echo "To install:"
echo "  cp -r $BUILD_DIR/$APP_NAME.app /Applications/"
echo ""
echo "Then set Bowzer as default browser in System Settings > Desktop & Dock > Default web browser"
