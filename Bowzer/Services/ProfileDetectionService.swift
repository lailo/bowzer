import Foundation

class ProfileDetectionService {
    weak var appState: AppState?

    private let fileManager: FileManagerProviding

    init(fileManager: FileManagerProviding = FileManager.default) {
        self.fileManager = fileManager
    }

    func detectAllProfiles(for browsers: [Browser]) {
        guard let appState = appState else { return }

        var updatedBrowsers = browsers

        for (index, browser) in updatedBrowsers.enumerated() {
            guard let browserType = BrowserType(rawValue: browser.bundleIdentifier) else { continue }
            updatedBrowsers[index].profiles = detectProfiles(for: browserType)
        }

        appState.browsers = updatedBrowsers
    }

    func detectProfiles(for browserType: BrowserType) -> [BrowserProfile] {
        switch browserType.profileType {
        case .chromium:
            return detectChromiumProfiles(for: browserType)
        case .firefox:
            return detectFirefoxProfiles()
        case .none:
            return []
        }
    }

    func detectChromiumProfiles(for browserType: BrowserType) -> [BrowserProfile] {
        Log.profile.debug("Detecting profiles for \(browserType.rawValue)")

        guard let folderName = browserType.applicationSupportFolder else {
            Log.profile.debug("No folder name for \(browserType.rawValue)")
            return []
        }

        let appSupport = fileManager.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support")
            .appendingPathComponent(folderName)

        let localStatePath = appSupport.appendingPathComponent("Local State")
        Log.profile.debug("Reading Local State from \(localStatePath.path)")

        guard fileManager.fileExists(atPath: localStatePath.path) else {
            Log.profile.debug("Local State file not found at \(localStatePath.path)")
            return []
        }

        guard let data = fileManager.contents(atPath: localStatePath.path) else {
            Log.profile.warning("Failed to read data from \(localStatePath.path)")
            return []
        }
        Log.profile.debug("Read \(data.count) bytes from Local State")

        return parseChromiumLocalState(data: data, browserType: browserType)
    }

    func parseChromiumLocalState(data: Data, browserType: BrowserType) -> [BrowserProfile] {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            Log.profile.warning("Failed to parse Local State JSON for \(browserType.rawValue)")
            return []
        }

        guard let profileInfo = json["profile"] as? [String: Any] else {
            Log.profile.debug("No 'profile' key in Local State JSON")
            return []
        }

        guard let infoCache = profileInfo["info_cache"] as? [String: Any] else {
            Log.profile.debug("No 'info_cache' in profile data")
            return []
        }

        Log.profile.debug("Found \(infoCache.count) profiles in info_cache")

        var profiles: [BrowserProfile] = []

        for (directoryName, profileData) in infoCache {
            guard let profileDict = profileData as? [String: Any],
                  let name = profileDict["name"] as? String else {
                Log.profile.debug("Skipping profile \(directoryName) - invalid data")
                continue
            }

            Log.profile.debug("Found profile: \(name) (\(directoryName))")
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

        Log.profile.info("Detected \(profiles.count) profiles for \(browserType.rawValue)")
        return profiles
    }

    func detectFirefoxProfiles() -> [BrowserProfile] {
        let profilesIniPath = fileManager.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/Firefox/profiles.ini")

        guard fileManager.fileExists(atPath: profilesIniPath.path),
              let data = fileManager.contents(atPath: profilesIniPath.path),
              let contents = String(data: data, encoding: .utf8) else {
            Log.profile.debug("Firefox profiles.ini not found or unreadable")
            return []
        }

        return parseFirefoxProfilesIni(contents: contents)
    }

    func parseFirefoxProfilesIni(contents: String) -> [BrowserProfile] {
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

        Log.profile.info("Detected \(profiles.count) Firefox profiles")
        return profiles
    }
}
