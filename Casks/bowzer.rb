cask "bowzer" do
  version "1.1.0"
  sha256 "313e17bc92094af6c6f7a0391e6588985dfebbae58797d1a0fd0b5210c54bf29"

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
