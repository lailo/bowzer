# Bowzer

A lightweight macOS browser picker that lets you choose which browser to open links in.

[![CI](https://github.com/lailo/bowzer/actions/workflows/ci.yml/badge.svg)](https://github.com/lailo/bowzer/actions/workflows/ci.yml)
[![Release](https://github.com/lailo/bowzer/actions/workflows/release.yml/badge.svg)](https://github.com/lailo/bowzer/actions/workflows/release.yml)
[![Latest Release](https://img.shields.io/github/v/release/lailo/bowzer)](https://github.com/lailo/bowzer/releases/latest)

<p align="center">
  <img src="demo.gif" alt="Bowzer demo" width="600">
</p>

## Download

**[Download Latest Release](https://github.com/lailo/bowzer/releases/latest)**

Or download a specific version from the [Releases](https://github.com/lailo/bowzer/releases) page.

## Features

- Set Bowzer as your default browser to intercept all links
- Choose which browser (and profile) to open each link in
- Supports browser profiles for Chrome, Firefox, Edge, Arc, and more
- Keyboard shortcuts (1-9) for quick selection
- Menu bar icon for easy access to settings
- Remembers your most-used browsers

## Requirements

- macOS 14.0 (Sonoma) or later

## Installation

### Using Homebrew (Recommended)

```bash
brew tap lailo/bowzer https://github.com/lailo/bowzer.git
brew install --cask bowzer
```

To update or uninstall:

```bash
brew upgrade --cask bowzer   # Update to latest version
brew uninstall --cask bowzer # Uninstall
```

### Manual Installation

1. Download the latest release from the link above
2. Unzip and drag `Bowzer.app` to your Applications folder
3. Open Bowzer and follow the setup instructions to set it as your default browser

## Usage

When you click a link in any application, Bowzer will appear with a list of your installed browsers. Click on one to open the link, or use keyboard shortcuts 1-9 for quick selection.

### Settings

Access settings from the menu bar icon or by pressing `Cmd + ,` when the picker is visible:

- **Browsers**: Show/hide browsers and reorder them
- **Preferences**: Configure keyboard shortcuts and display options
- **Setup**: Set Bowzer as your default browser

## Building from Source

```bash
# Clone the repository
git clone https://github.com/lailo/bowzer.git
cd bowzer

# Build with Xcode
xcodebuild build -project Bowzer.xcodeproj -scheme Bowzer -configuration Release

# Or open in Xcode
open Bowzer.xcodeproj
```

## Creating a Release

To create a new release, push a version tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

This will trigger the release workflow which builds the app and creates a GitHub release with the downloadable artifact.

## License

Licensed under [MIT + Commons Clause](LICENSE).
