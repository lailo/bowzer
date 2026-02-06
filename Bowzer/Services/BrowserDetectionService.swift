import AppKit

class BrowserDetectionService {
    weak var appState: AppState?

    private let supportedBrowsers: [BrowserType] = [
        .safari, .chrome, .firefox, .edge, .brave, .arc
    ]

    func detectBrowsers() {
        var detectedBrowsers: [Browser] = []

        // Get all apps that can open HTTP URLs
        guard let httpURL = URL(string: "https://example.com") else { return }

        let browserURLs = NSWorkspace.shared.urlsForApplications(toOpen: httpURL)

        for browserURL in browserURLs {
            guard let bundle = Bundle(url: browserURL),
                  let bundleId = bundle.bundleIdentifier,
                  let browserType = BrowserType(rawValue: bundleId) else {
                continue
            }

            // Only include browsers we support
            guard supportedBrowsers.contains(browserType) else { continue }

            let name = FileManager.default.displayName(atPath: browserURL.path)
            let icon = NSWorkspace.shared.icon(forFile: browserURL.path)
            icon.size = NSSize(width: 48, height: 48)

            let browser = Browser(
                id: bundleId,
                name: name,
                bundleIdentifier: bundleId,
                path: browserURL,
                icon: icon,
                profiles: []
            )

            detectedBrowsers.append(browser)
        }

        // Sort by our preferred order
        detectedBrowsers.sort { browser1, browser2 in
            let index1 = supportedBrowsers.firstIndex(where: { $0.rawValue == browser1.bundleIdentifier }) ?? Int.max
            let index2 = supportedBrowsers.firstIndex(where: { $0.rawValue == browser2.bundleIdentifier }) ?? Int.max
            return index1 < index2
        }

        appState?.browsers = detectedBrowsers
    }
}
