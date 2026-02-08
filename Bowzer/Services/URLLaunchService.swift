import AppKit

class URLLaunchService {

    private let processLauncher: ProcessLaunching

    init(processLauncher: ProcessLaunching = DefaultProcessLauncher()) {
        self.processLauncher = processLauncher
    }

    func launch(url: URL, with item: BrowserDisplayItem) {
        guard let params = getLaunchParameters(for: url, with: item) else {
            Log.launch.error("Failed to get launch parameters for \(item.browser.name)")
            return
        }

        Log.launch.info("Launching \(url.absoluteString) with \(item.displayName)")

        do {
            try processLauncher.launch(executableURL: params.executableURL, arguments: params.arguments)
            Log.launch.debug("Successfully launched browser")
        } catch {
            Log.launch.error("Failed to launch browser: \(error.localizedDescription)")

            // If profile launch failed, try fallback to bundle ID launch
            if item.profile != nil {
                Log.launch.info("Attempting fallback launch without profile")
                let fallbackParams = getBundleIdLaunchParameters(for: url, bundleId: item.browser.bundleIdentifier)
                do {
                    try processLauncher.launch(executableURL: fallbackParams.executableURL, arguments: fallbackParams.arguments)
                    Log.launch.debug("Fallback launch succeeded")
                } catch {
                    Log.launch.error("Fallback launch failed: \(error.localizedDescription)")
                }
            }
        }
    }

    func getLaunchParameters(for url: URL, with item: BrowserDisplayItem) -> (executableURL: URL, arguments: [String])? {
        let browserType = BrowserType(rawValue: item.browser.bundleIdentifier)

        if let profile = item.profile, let type = browserType, type.profileType != .none {
            return getProfileLaunchParameters(url: url, browserType: type, browser: item.browser, profile: profile)
        } else {
            return getBundleIdLaunchParameters(for: url, bundleId: item.browser.bundleIdentifier)
        }
    }

    private func getBundleIdLaunchParameters(for url: URL, bundleId: String) -> (executableURL: URL, arguments: [String]) {
        return (
            URL(fileURLWithPath: "/usr/bin/open"),
            ["-b", bundleId, url.absoluteString]
        )
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
