#!/bin/bash

set -e

cd "$(dirname "$0")/.."

# Build the app
./scripts/build-app.sh

# Stop running instance
echo "Stopping Bowzer..."
pkill -x Bowzer 2>/dev/null || true
sleep 0.5

# Install
echo "Installing to /Applications..."
rm -rf /Applications/Bowzer.app
cp -r build/Bowzer.app /Applications/

# Restart
echo "Starting Bowzer..."
open /Applications/Bowzer.app

echo ""
echo "Bowzer installed and running"
