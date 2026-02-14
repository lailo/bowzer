cask "bowzer" do
  version "1.2.0"
  sha256 "f0459033e7d618996f82609710214a67bf9b335d3e5a9ce254e34664008b32f2"

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
