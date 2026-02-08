import AppKit

class BrowserDetectionService {
    weak var appState: AppState?

    private let workspace: WorkspaceProviding
    private let fileManager: FileManagerProviding

    private let supportedBrowsers: [BrowserType] = [
        .safari, .chrome, .firefox, .edge, .brave, .arc
    ]

    /// Lookup map for O(1) sort order access
    private lazy var browserSortOrder: [String: Int] = {
        Dictionary(uniqueKeysWithValues: supportedBrowsers.enumerated().map { ($1.rawValue, $0) })
    }()

    init(workspace: WorkspaceProviding = NSWorkspace.shared,
         fileManager: FileManagerProviding = FileManager.default) {
        self.workspace = workspace
        self.fileManager = fileManager
    }

    func detectBrowsers() {
        appState?.browsers = detectBrowsersResult()
    }

    func detectBrowsersResult() -> [Browser] {
        var detectedBrowsers: [Browser] = []

        guard let httpURL = URL(string: "https://example.com") else { return [] }

        let browserURLs = workspace.urlsForApplications(toOpen: httpURL)

        for browserURL in browserURLs {
            guard let bundle = Bundle(url: browserURL),
                  let bundleId = bundle.bundleIdentifier,
                  let browserType = BrowserType(rawValue: bundleId) else {
                continue
            }

            guard supportedBrowsers.contains(browserType) else { continue }

            let name = fileManager.displayName(atPath: browserURL.path)
            let icon = workspace.icon(forFile: browserURL.path)
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

        // Sort using O(1) lookup instead of O(n) firstIndex calls
        detectedBrowsers.sort { browser1, browser2 in
            let index1 = browserSortOrder[browser1.bundleIdentifier] ?? Int.max
            let index2 = browserSortOrder[browser2.bundleIdentifier] ?? Int.max
            return index1 < index2
        }

        return detectedBrowsers
    }
}
