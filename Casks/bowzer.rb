cask "bowzer" do
  version "1.0.0"
  sha256 "561b8c9ad9ffc1a43508ddea026dee55db74c7b2e9d285f15d656fb87decd9e2"

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
