import Foundation

/// Central application state that coordinates services and holds observable data
@Observable
class AppState {
    // MARK: - Observable State

    var browsers: [Browser] = []
    var settings: AppSettings = AppSettings()
    var orderedDisplayItems: [BrowserDisplayItem] = []

    // MARK: - Services

    private let browserDetectionService: BrowserDetectionService
    private let profileDetectionService: ProfileDetectionService
    private let settingsService: SettingsService
    private let urlLaunchService: URLLaunchService

    // MARK: - Initialization

    init(
        browserDetectionService: BrowserDetectionService = BrowserDetectionService(),
        profileDetectionService: ProfileDetectionService = ProfileDetectionService(),
        settingsService: SettingsService = SettingsService(),
        urlLaunchService: URLLaunchService = URLLaunchService()
    ) {
        self.browserDetectionService = browserDetectionService
        self.profileDetectionService = profileDetectionService
        self.settingsService = settingsService
        self.urlLaunchService = urlLaunchService

        // Set up debounce callback
        self.settingsService.onDebouncedSave = { [weak self] in
            self?.saveSettingsImmediately()
        }
    }

    // MARK: - Browser Management

    /// Refreshes the browser list by re-detecting installed browsers and their profiles
    func refreshBrowsers() {
        // Detect browsers
        browsers = browserDetectionService.detectBrowsers()

        // Detect profiles for each browser
        browsers = profileDetectionService.detectAllProfiles(for: browsers)

        // Clean up settings entries for uninstalled browsers
        let installedBrowserIds = Set(browsers.map { $0.bundleIdentifier })
        let (cleanedSettings, didChange) = settingsService.cleanupStaleBrowserEntries(
            in: settings,
            installedBrowserIds: installedBrowserIds
        )
        if didChange {
            settings = cleanedSettings
            saveSettingsImmediately()
        }

        applyBrowserOrder()
    }

    // MARK: - Display Item Ordering

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

    func saveDisplayItemOrder() {
        settings.browserOrder = orderedDisplayItems.map { $0.id }
        saveSettings()
    }

    func moveDisplayItems(from source: IndexSet, to destination: Int) {
        orderedDisplayItems.move(fromOffsets: source, toOffset: destination)
        saveDisplayItemOrder()
    }

    // MARK: - Settings Management

    /// Loads settings from persistent storage
    func loadSettings() {
        settings = settingsService.loadSettings()
    }

    /// Saves current settings with debouncing
    func saveSettings() {
        settingsService.scheduleDebouncedSave()
    }

    /// Saves settings immediately without debouncing
    func saveSettingsImmediately() {
        if case .failure(let error) = settingsService.saveSettings(settings) {
            Log.settings.error("\(error.localizedDescription)")
        }
    }

    // MARK: - Visibility

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

    // MARK: - URL Launching

    /// Launches a URL with the specified browser/profile and tracks usage
    func launchURL(_ url: URL, with item: BrowserDisplayItem) {
        urlLaunchService.launch(url: url, with: item)
        trackUsage(for: item)
    }

    /// Records a browser/profile selection for usage tracking
    private func trackUsage(for item: BrowserDisplayItem) {
        settings.incrementUsageCount(for: item.id)
        saveSettings()
    }

    /// Returns the usage count for a specific browser/profile item
    func getUsageCount(for itemId: String) -> Int {
        settings.getUsageCount(for: itemId)
    }

    // MARK: - Launch at Login

    /// Sets whether the app should launch at login
    func setLaunchAtLogin(_ enabled: Bool) {
        settings.launchAtLogin = enabled
        if case .failure(let error) = settingsService.setLaunchAtLogin(enabled) {
            Log.settings.error("\(error.localizedDescription)")
        }
        saveSettingsImmediately()
    }

    /// Returns whether the app is set to launch at login
    func isLaunchAtLoginEnabled() -> Bool {
        settingsService.isLaunchAtLoginEnabled()
    }
}
