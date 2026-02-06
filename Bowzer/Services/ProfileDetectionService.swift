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
        print("[Profile] Detecting for \(browserType.rawValue)")

        guard let folderName = browserType.applicationSupportFolder else {
            print("[Profile] No folder name for \(browserType.rawValue)")
            return []
        }

        let appSupport = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support")
            .appendingPathComponent(folderName)

        let localStatePath = appSupport.appendingPathComponent("Local State")
        print("[Profile] Path: \(localStatePath.path)")

        guard FileManager.default.fileExists(atPath: localStatePath.path) else {
            print("[Profile] File not found at \(localStatePath.path)")
            return []
        }

        guard let data = try? Data(contentsOf: localStatePath) else {
            print("[Profile] Failed to read data from \(localStatePath.path)")
            return []
        }
        print("[Profile] Read \(data.count) bytes")

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            print("[Profile] Failed to parse JSON")
            return []
        }

        guard let profileInfo = json["profile"] as? [String: Any] else {
            print("[Profile] No 'profile' key in JSON")
            return []
        }

        guard let infoCache = profileInfo["info_cache"] as? [String: Any] else {
            print("[Profile] No 'info_cache' in profile")
            return []
        }

        print("[Profile] Found \(infoCache.count) profiles in info_cache")

        var profiles: [BrowserProfile] = []

        for (directoryName, profileData) in infoCache {
            guard let profileDict = profileData as? [String: Any],
                  let name = profileDict["name"] as? String else {
                print("[Profile] Skipping \(directoryName) - invalid data")
                continue
            }

            print("[Profile] Adding profile: \(name) (\(directoryName))")
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

        print("[Profile] Returning \(profiles.count) profiles for \(browserType.rawValue)")
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
