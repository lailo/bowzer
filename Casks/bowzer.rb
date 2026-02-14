cask "bowzer" do
  version "1.0.0"
  sha256 "68c75b922ff9dfe710630b2a171e02a85af1e85b9a7ed0264f7eb2e8d2dd972b"

  url "https://github.com/lailo/bowzer/releases/download/v#{version}/Bowzer-#{version}.zip"
  name "Bowzer"
  desc "Lightweight macOS browser picker that lets you choose which browser to open links in"
  homepage "https://github.com/lailo/bowzer"

  depends_on macos: ">= :sonoma"

  app "Bowzer.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/Bowzer.app"],
                   sudo: false
  end

  zap trash: [
    "~/Library/Application Support/Bowzer",
    "~/Library/Caches/Bowzer",
    "~/Library/Preferences/com.lailo.Bowzer.plist",
    "~/Library/Saved Application State/com.lailo.Bowzer.savedState",
  ]
end
