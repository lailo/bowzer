import Foundation
import ServiceManagement

class SettingsService {
    weak var appState: AppState?

    private let settingsKey = "BowzerSettings"
    private let userDefaults: UserDefaultsProviding

    /// Debounce interval for settings saves (in seconds)
    private let debounceInterval: TimeInterval = 0.5

    /// Pending save work item for debouncing
    private var pendingSaveWorkItem: DispatchWorkItem?

    init(userDefaults: UserDefaultsProviding = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }

    func loadSettings() {
        switch loadSettingsWithResult() {
        case .success(let settings):
            appState?.settings = settings
        case .failure(let error):
            Log.settings.warning("\(error.localizedDescription). Using defaults.")
        }
    }

    func loadSettingsWithResult() -> Result<AppSettings, BowzerError> {
        guard let data = userDefaults.data(forKey: settingsKey) else {
            return .success(AppSettings()) // No saved settings, use defaults
        }

        do {
            let settings = try JSONDecoder().decode(AppSettings.self, from: data)
            return .success(settings)
        } catch {
            Log.settings.error("Failed to decode settings: \(error.localizedDescription)")
            return .failure(.settingsDecodingFailed)
        }
    }

    // Testable version that returns settings
    func loadSettingsResult() -> AppSettings? {
        if case .success(let settings) = loadSettingsWithResult() {
            return settings
        }
        return nil
    }

    /// Saves settings with debouncing to prevent multiple rapid writes
    func saveSettings() {
        // Cancel any pending save
        pendingSaveWorkItem?.cancel()

        // Create new work item
        let workItem = DispatchWorkItem { [weak self] in
            self?.saveSettingsImmediately()
        }
        pendingSaveWorkItem = workItem

        // Schedule after debounce interval
        DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval, execute: workItem)
    }

    /// Saves settings immediately without debouncing
    func saveSettingsImmediately() {
        if case .failure(let error) = saveSettingsWithResult() {
            Log.settings.error("\(error.localizedDescription)")
        }
    }

    func saveSettingsWithResult() -> Result<Void, BowzerError> {
        guard let settings = appState?.settings else {
            return .failure(.settingsEncodingFailed)
        }

        do {
            let data = try JSONEncoder().encode(settings)
            userDefaults.set(data, forKey: settingsKey)
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
            Log.settings.debug("Settings saved successfully")
            return .success(())
        } catch {
            Log.settings.error("Failed to encode settings: \(error.localizedDescription)")
            return .failure(.settingsEncodingFailed)
        }
    }

    // Testable version that takes settings as parameter
    func saveSettings(_ settings: AppSettings) {
        do {
            let data = try JSONEncoder().encode(settings)
            userDefaults.set(data, forKey: settingsKey)
        } catch {
            Log.settings.error("Failed to encode settings: \(error.localizedDescription)")
        }
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        appState?.settings.launchAtLogin = enabled

        if case .failure(let error) = setLaunchAtLoginWithResult(enabled) {
            Log.settings.error("\(error.localizedDescription)")
        }

        saveSettingsImmediately() // Don't debounce login item changes
    }

    func setLaunchAtLoginWithResult(_ enabled: Bool) -> Result<Void, BowzerError> {
        // Check if we can use SMAppService
        guard #available(macOS 13.0, *) else {
            Log.settings.info("Launch at login requires macOS 13.0 or later")
            return .success(())
        }

        // Check current status first
        let currentStatus = SMAppService.mainApp.status
        Log.settings.debug("Current launch at login status: \(String(describing: currentStatus))")

        do {
            if enabled {
                try SMAppService.mainApp.register()
                Log.settings.info("Successfully registered for launch at login")
            } else {
                try SMAppService.mainApp.unregister()
                Log.settings.info("Successfully unregistered from launch at login")
            }
            return .success(())
        } catch {
            Log.settings.error("SMAppService operation failed: \(error.localizedDescription)")
            return .failure(.launchAtLoginFailed(enabled: enabled, reason: error.localizedDescription))
        }
    }

    func isLaunchAtLoginEnabled() -> Bool {
        if #available(macOS 13.0, *) {
            return SMAppService.mainApp.status == .enabled
        }
        return false
    }

    /// Cleans up stale browser entries that reference uninstalled browsers
    func cleanupStaleBrowserEntries(installedBrowserIds: Set<String>) {
        guard let appState = appState else { return }

        let originalOrderCount = appState.settings.browserOrder.count
        let originalHiddenCount = appState.settings.hiddenBrowsers.count

        // Remove browser order entries for uninstalled browsers
        appState.settings.browserOrder = appState.settings.browserOrder.filter { itemId in
            // Extract the browser bundle ID from the item ID (format: "bundleId_profileOrDefault")
            let bundleId = extractBundleId(from: itemId)
            return installedBrowserIds.contains(bundleId)
        }

        // Remove hidden browser entries for uninstalled browsers
        appState.settings.hiddenBrowsers = appState.settings.hiddenBrowsers.filter { itemId in
            let bundleId = extractBundleId(from: itemId)
            return installedBrowserIds.contains(bundleId)
        }

        let removedOrderCount = originalOrderCount - appState.settings.browserOrder.count
        let removedHiddenCount = originalHiddenCount - appState.settings.hiddenBrowsers.count

        if removedOrderCount > 0 || removedHiddenCount > 0 {
            Log.settings.info("Cleaned up \(removedOrderCount) stale order entries and \(removedHiddenCount) stale hidden entries")
            saveSettingsImmediately()
        }
    }

    /// Extracts the browser bundle ID from a display item ID
    private func extractBundleId(from itemId: String) -> String {
        // Item IDs have format: "com.bundle.id_profileName" or "com.bundle.id_default"
        // We need to extract "com.bundle.id"
        if let lastUnderscoreIndex = itemId.lastIndex(of: "_") {
            return String(itemId[..<lastUnderscoreIndex])
        }
        return itemId
    }
}
