import Foundation
import AppKit
@testable import Bowzer

/// Mock AppState for view tests that doesn't require real services
class MockAppState: ObservableObject {
    @Published var browsers: [Browser] = []
    @Published var settings: AppSettings = AppSettings()
    @Published var orderedDisplayItems: [BrowserDisplayItem] = []

    init() {}

    func applyBrowserOrder() {
        let allItems = browsers.flatMap { $0.displayItems }

        guard !settings.browserOrder.isEmpty else {
            orderedDisplayItems = allItems
            return
        }

        var orderedItems: [BrowserDisplayItem] = []
        var remainingItems = allItems

        for itemId in settings.browserOrder {
            if let index = remainingItems.firstIndex(where: { $0.id == itemId }) {
                orderedItems.append(remainingItems.remove(at: index))
            }
        }

        orderedItems.append(contentsOf: remainingItems)
        orderedDisplayItems = orderedItems
    }
}

// MARK: - Factory Methods for Test Data

enum TestDataFactory {

    /// Creates a placeholder icon for testing (avoids file system access)
    static func makePlaceholderIcon() -> NSImage {
        let image = NSImage(size: NSSize(width: 48, height: 48))
        image.lockFocus()
        NSColor.blue.setFill()
        NSBezierPath(ovalIn: NSRect(x: 4, y: 4, width: 40, height: 40)).fill()
        image.unlockFocus()
        return image
    }

    /// Creates a sample browser without profiles
    static func makeBrowser(
        id: String = "safari",
        name: String = "Safari",
        bundleIdentifier: String = "com.apple.Safari",
        profiles: [BrowserProfile] = []
    ) -> Browser {
        Browser(
            id: id,
            name: name,
            bundleIdentifier: bundleIdentifier,
            path: URL(fileURLWithPath: "/Applications/\(name).app"),
            icon: makePlaceholderIcon(),
            profiles: profiles
        )
    }

    /// Creates a sample browser with profiles
    static func makeBrowserWithProfiles(
        id: String = "chrome",
        name: String = "Chrome",
        bundleIdentifier: String = "com.google.Chrome",
        profileNames: [String] = ["Personal", "Work"]
    ) -> Browser {
        let profiles = profileNames.enumerated().map { index, profileName in
            BrowserProfile(
                id: "\(id)_profile_\(index)",
                name: profileName,
                directoryName: "Profile \(index)"
            )
        }

        return Browser(
            id: id,
            name: name,
            bundleIdentifier: bundleIdentifier,
            path: URL(fileURLWithPath: "/Applications/\(name).app"),
            icon: makePlaceholderIcon(),
            profiles: profiles
        )
    }

    /// Creates a BrowserDisplayItem from a browser
    static func makeDisplayItem(
        browser: Browser,
        profile: BrowserProfile? = nil
    ) -> BrowserDisplayItem {
        BrowserDisplayItem(browser: browser, profile: profile)
    }

    /// Creates a set of sample browsers for testing
    static func makeSampleBrowsers() -> [Browser] {
        [
            makeBrowser(id: "safari", name: "Safari", bundleIdentifier: "com.apple.Safari"),
            makeBrowserWithProfiles(
                id: "chrome",
                name: "Chrome",
                bundleIdentifier: "com.google.Chrome",
                profileNames: ["Personal", "Work"]
            ),
            makeBrowser(id: "firefox", name: "Firefox", bundleIdentifier: "org.mozilla.firefox")
        ]
    }

    /// Creates an AppState populated with sample data
    static func makeAppStateWithSampleData() -> AppState {
        let appState = AppState()
        appState.browsers = makeSampleBrowsers()
        appState.applyBrowserOrder()
        return appState
    }

    /// Creates a sample URL for testing
    static func makeSampleURL() -> URL {
        URL(string: "https://example.com")!
    }
}
