import Foundation
import ServiceManagement

class SettingsService {
    weak var appState: AppState?

    private let settingsKey = "BowzerSettings"
    private let userDefaults: UserDefaultsProviding

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

    func saveSettings() {
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

        saveSettings()
    }

    func setLaunchAtLoginWithResult(_ enabled: Bool) -> Result<Void, BowzerError> {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
                return .success(())
            } catch {
                return .failure(.launchAtLoginFailed(enabled: enabled, reason: error.localizedDescription))
            }
        }
        return .success(())
    }

    func isLaunchAtLoginEnabled() -> Bool {
        if #available(macOS 13.0, *) {
            return SMAppService.mainApp.status == .enabled
        }
        return false
    }
}
