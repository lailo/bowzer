import Foundation
import Combine

class AppState: ObservableObject {
    @Published var browsers: [Browser] = []
    @Published var settings: AppSettings = AppSettings()
    @Published var orderedDisplayItems: [BrowserDisplayItem] = []

    let browserDetectionService = BrowserDetectionService()
    let profileDetectionService = ProfileDetectionService()
    let urlLaunchService = URLLaunchService()
    let settingsService = SettingsService()

    init() {
        // Set up bindings
        browserDetectionService.appState = self
        profileDetectionService.appState = self
        settingsService.appState = self
    }

    func applyBrowserOrder() {
        // Get all display items from browsers
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

        // Append any items not in the saved order
        orderedItems.append(contentsOf: remainingItems)
        orderedDisplayItems = orderedItems
    }

    func saveDisplayItemOrder() {
        settings.browserOrder = orderedDisplayItems.map { $0.id }
        settingsService.saveSettings()
    }

    func moveDisplayItems(from source: IndexSet, to destination: Int) {
        orderedDisplayItems.move(fromOffsets: source, toOffset: destination)
        saveDisplayItemOrder()
    }

    // MARK: - Convenience Methods

    /// Refreshes the browser list by re-detecting installed browsers and their profiles
    func refreshBrowsers() {
        browserDetectionService.detectBrowsers()
        profileDetectionService.detectAllProfiles(for: browsers)

        // Clean up settings entries for uninstalled browsers
        let installedBrowserIds = Set(browsers.map { $0.bundleIdentifier })
        settingsService.cleanupStaleBrowserEntries(installedBrowserIds: installedBrowserIds)

        applyBrowserOrder()
    }

    /// Saves current settings to persistent storage
    func saveSettings() {
        settingsService.saveSettings()
    }

    /// Sets the visibility of a browser/profile item
    func setItemVisible(_ itemId: String, visible: Bool) {
        if visible {
            settings.hiddenBrowsers.removeAll { $0 == itemId }
        } else {
            settings.hiddenBrowsers.append(itemId)
        }
        saveSettings()
    }

    /// Checks if a browser/profile item is visible
    func isItemVisible(_ itemId: String) -> Bool {
        !settings.hiddenBrowsers.contains(itemId)
    }

    /// Launches a URL with the specified browser/profile
    func launchURL(_ url: URL, with item: BrowserDisplayItem) {
        urlLaunchService.launch(url: url, with: item)
    }

    /// Sets whether the app should launch at login
    func setLaunchAtLogin(_ enabled: Bool) {
        settingsService.setLaunchAtLogin(enabled)
    }

    /// Returns whether the app is set to launch at login
    func isLaunchAtLoginEnabled() -> Bool {
        settingsService.isLaunchAtLoginEnabled()
    }
}
