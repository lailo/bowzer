import Foundation

class ProfileDetectionService {
    weak var appState: AppState?

    func detectAllProfiles(for browsers: [Browser]) {
        guard let appState = appState else { return }

        var updatedBrowsers = browsers

        for (index, browser) in updatedBrowsers.enumerated() {
            guard let browserType = BrowserType(rawValue: browser.bundleIdentifier) else { continue }

            let profiles: [BrowserProfile]
            switch browserType.profileType {
            case .chromium:
                profiles = detectChromiumProfiles(for: browserType)
            case .firefox:
                profiles = detectFirefoxProfiles()
            case .none:
                profiles = []
            }

            updatedBrowsers[index].profiles = profiles
        }

        appState.browsers = updatedBrowsers
    }

    private func detectChromiumProfiles(for browserType: BrowserType) -> [BrowserProfile] {
        guard let folderName = browserType.applicationSupportFolder else { return [] }

        let appSupport = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support")
            .appendingPathComponent(folderName)

        let localStatePath = appSupport.appendingPathComponent("Local State")

        guard FileManager.default.fileExists(atPath: localStatePath.path),
              let data = try? Data(contentsOf: localStatePath),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let profileInfo = json["profile"] as? [String: Any],
              let infoCache = profileInfo["info_cache"] as? [String: Any] else {
            return []
        }

        var profiles: [BrowserProfile] = []

        for (directoryName, profileData) in infoCache {
            guard let profileDict = profileData as? [String: Any],
                  let name = profileDict["name"] as? String else {
                continue
            }

            let profile = BrowserProfile(
                id: "\(browserType.rawValue)_\(directoryName)",
                name: name,
                directoryName: directoryName
            )
            profiles.append(profile)
        }

        // Sort profiles: Default first, then alphabetically
        profiles.sort { p1, p2 in
            if p1.directoryName == "Default" { return true }
            if p2.directoryName == "Default" { return false }
            return p1.name.localizedCaseInsensitiveCompare(p2.name) == .orderedAscending
        }

        return profiles
    }

    private func detectFirefoxProfiles() -> [BrowserProfile] {
        let profilesIniPath = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/Firefox/profiles.ini")

        guard FileManager.default.fileExists(atPath: profilesIniPath.path),
              let contents = try? String(contentsOf: profilesIniPath, encoding: .utf8) else {
            return []
        }

        var profiles: [BrowserProfile] = []
        var currentProfile: (name: String?, path: String?, isRelative: Bool)?

        for line in contents.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.hasPrefix("[Profile") {
                // Save previous profile if exists
                if let name = currentProfile?.name, let path = currentProfile?.path {
                    let profile = BrowserProfile(
                        id: "firefox_\(path)",
                        name: name,
                        directoryName: path
                    )
                    profiles.append(profile)
                }
                currentProfile = (nil, nil, true)
            } else if trimmed.hasPrefix("Name=") {
                currentProfile?.name = String(trimmed.dropFirst(5))
            } else if trimmed.hasPrefix("Path=") {
                currentProfile?.path = String(trimmed.dropFirst(5))
            } else if trimmed.hasPrefix("IsRelative=") {
                currentProfile?.isRelative = trimmed.dropFirst(11) == "1"
            }
        }

        // Don't forget the last profile
        if let name = currentProfile?.name, let path = currentProfile?.path {
            let profile = BrowserProfile(
                id: "firefox_\(path)",
                name: name,
                directoryName: path
            )
            profiles.append(profile)
        }

        return profiles
    }
}
