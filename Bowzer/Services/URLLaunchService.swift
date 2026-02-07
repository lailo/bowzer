import AppKit

class URLLaunchService {

    private let processLauncher: ProcessLaunching

    init(processLauncher: ProcessLaunching = DefaultProcessLauncher()) {
        self.processLauncher = processLauncher
    }

    func launch(url: URL, with item: BrowserDisplayItem) {
        let browserType = BrowserType(rawValue: item.browser.bundleIdentifier)

        if let profile = item.profile, let type = browserType, type.profileType != .none {
            launchWithProfile(url: url, browserType: type, browser: item.browser, profile: profile)
        } else {
            launchWithBundleId(url: url, bundleId: item.browser.bundleIdentifier)
        }
    }

    private func launchWithBundleId(url: URL, bundleId: String) {
        do {
            try processLauncher.launch(
                executableURL: URL(fileURLWithPath: "/usr/bin/open"),
                arguments: ["-b", bundleId, url.absoluteString]
            )
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

        let arguments: [String]
        switch browserType.profileType {
        case .chromium:
            arguments = ["--profile-directory=\(profile.directoryName)", url.absoluteString]
        case .firefox:
            arguments = ["-P", profile.name, url.absoluteString]
        case .none:
            arguments = [url.absoluteString]
        }

        do {
            try processLauncher.launch(
                executableURL: URL(fileURLWithPath: executablePath),
                arguments: arguments
            )
        } catch {
            print("Failed to launch with profile: \(error.localizedDescription)")
            // Fallback
            launchWithBundleId(url: url, bundleId: browser.bundleIdentifier)
        }
    }

    // Testable methods that return launch parameters
    func getLaunchParameters(for url: URL, with item: BrowserDisplayItem) -> (executableURL: URL, arguments: [String])? {
        let browserType = BrowserType(rawValue: item.browser.bundleIdentifier)

        if let profile = item.profile, let type = browserType, type.profileType != .none {
            return getProfileLaunchParameters(url: url, browserType: type, browser: item.browser, profile: profile)
        } else {
            return (
                URL(fileURLWithPath: "/usr/bin/open"),
                ["-b", item.browser.bundleIdentifier, url.absoluteString]
            )
        }
    }

    private func getProfileLaunchParameters(url: URL, browserType: BrowserType, browser: Browser, profile: BrowserProfile) -> (executableURL: URL, arguments: [String])? {
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
            return nil
        }

        let arguments: [String]
        switch browserType.profileType {
        case .chromium:
            arguments = ["--profile-directory=\(profile.directoryName)", url.absoluteString]
        case .firefox:
            arguments = ["-P", profile.name, url.absoluteString]
        case .none:
            arguments = [url.absoluteString]
        }

        return (URL(fileURLWithPath: executablePath), arguments)
    }
}
