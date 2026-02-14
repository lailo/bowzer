import Foundation
import ServiceManagement

class SettingsService {
    private let settingsKey = "BowzerSettings"
    private let userDefaults: UserDefaultsProviding

    /// Debounce interval for settings saves
    private let debounceInterval: Duration = .milliseconds(500)

    /// Pending save task for debouncing
    private var pendingSaveTask: Task<Void, Never>?

    /// Callback for debounced saves - set by AppState
    var onDebouncedSave: (() -> Void)?

    init(userDefaults: UserDefaultsProviding = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - Load Settings

    /// Loads settings from persistent storage
    func loadSettings() -> AppSettings {
        switch loadSettingsWithResult() {
        case .success(let settings):
            return settings
        case .failure(let error):
            Log.settings.warning("\(error.localizedDescription). Using defaults.")
            return AppSettings()
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

    // Testable version that returns optional
    func loadSettingsResult() -> AppSettings? {
        if case .success(let settings) = loadSettingsWithResult() {
            return settings
        }
        return nil
    }

    // MARK: - Save Settings

    /// Schedules a debounced save - calls onDebouncedSave after delay
    func scheduleDebouncedSave() {
        pendingSaveTask?.cancel()

        pendingSaveTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: self?.debounceInterval ?? .milliseconds(500))
            guard !Task.isCancelled else { return }
            self?.onDebouncedSave?()
        }
    }

    /// Saves settings immediately
    func saveSettings(_ settings: AppSettings) -> Result<Void, BowzerError> {
        do {
            let data = try JSONEncoder().encode(settings)
            userDefaults.set(data, forKey: settingsKey)
            Log.settings.debug("Settings saved successfully")
            return .success(())
        } catch {
            Log.settings.error("Failed to encode settings: \(error.localizedDescription)")
            return .failure(.settingsEncodingFailed)
        }
    }

    // MARK: - Launch at Login

    func setLaunchAtLogin(_ enabled: Bool) -> Result<Void, BowzerError> {
        guard #available(macOS 13.0, *) else {
            Log.settings.info("Launch at login requires macOS 13.0 or later")
            return .success(())
        }

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

    // MARK: - Cleanup

    /// Cleans up stale browser entries and returns updated settings
    func cleanupStaleBrowserEntries(
        in settings: AppSettings,
        installedBrowserIds: Set<String>
    ) -> (settings: AppSettings, didChange: Bool) {
        var cleanedSettings = settings
        let originalOrderCount = settings.browserOrder.count
        let originalHiddenCount = settings.hiddenBrowsers.count

        cleanedSettings.browserOrder = settings.browserOrder.filter { itemId in
            let bundleId = extractBundleId(from: itemId)
            return installedBrowserIds.contains(bundleId)
        }

        cleanedSettings.hiddenBrowsers = settings.hiddenBrowsers.filter { itemId in
            let bundleId = extractBundleId(from: itemId)
            return installedBrowserIds.contains(bundleId)
        }

        let removedOrderCount = originalOrderCount - cleanedSettings.browserOrder.count
        let removedHiddenCount = originalHiddenCount - cleanedSettings.hiddenBrowsers.count
        let didChange = removedOrderCount > 0 || removedHiddenCount > 0

        if didChange {
            Log.settings.info("Cleaned up \(removedOrderCount) stale order entries and \(removedHiddenCount) stale hidden entries")
        }

        return (cleanedSettings, didChange)
    }

    /// Extracts the browser bundle ID from a display item ID
    private func extractBundleId(from itemId: String) -> String {
        if let lastUnderscoreIndex = itemId.lastIndex(of: "_") {
            return String(itemId[..<lastUnderscoreIndex])
        }
        return itemId
    }
}
