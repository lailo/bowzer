import AppKit

class URLLaunchService {

    func launch(url: URL, with item: BrowserDisplayItem) {
        let browserType = BrowserType(rawValue: item.browser.bundleIdentifier)

        if let profile = item.profile, let type = browserType, type.profileType != .none {
            launchWithProfile(url: url, browserType: type, browser: item.browser, profile: profile)
        } else {
            launchWithBundleId(url: url, bundleId: item.browser.bundleIdentifier)
        }
    }

    private func launchWithBundleId(url: URL, bundleId: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        process.arguments = ["-b", bundleId, url.absoluteString]

        do {
            try process.run()
        } catch {
            print("Failed to launch browser: \(error.localizedDescription)")
        }
    }

    private func launchWithProfile(url: URL, browserType: BrowserType, browser: Browser, profile: BrowserProfile) {
        // For profile-specific launches, we need to use the executable directly
        let executablePath: String

        switch browserType {
        case .chrome:
            executablePath = "\(browser.path.path)/Contents/MacOS/Google Chrome"
        case .brave:
            executablePath = "\(browser.path.path)/Contents/MacOS/Brave Browser"
        case .edge:
            executablePath = "\(browser.path.path)/Contents/MacOS/Microsoft Edge"
        case .firefox:
            executablePath = "\(browser.path.path)/Contents/MacOS/firefox"
        default:
            // Fallback to bundle ID launch
            launchWithBundleId(url: url, bundleId: browser.bundleIdentifier)
            return
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: executablePath)

        switch browserType.profileType {
        case .chromium:
            process.arguments = ["--profile-directory=\(profile.directoryName)", url.absoluteString]
        case .firefox:
            process.arguments = ["-P", profile.name, url.absoluteString]
        case .none:
            process.arguments = [url.absoluteString]
        }

        do {
            try process.run()
        } catch {
            print("Failed to launch with profile: \(error.localizedDescription)")
            // Fallback
            launchWithBundleId(url: url, bundleId: browser.bundleIdentifier)
        }
    }
}
