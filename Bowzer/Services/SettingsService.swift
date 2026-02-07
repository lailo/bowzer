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
        guard let data = userDefaults.data(forKey: settingsKey),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return
        }

        appState?.settings = settings
    }

    // Testable version that returns settings
    func loadSettingsResult() -> AppSettings? {
        guard let data = userDefaults.data(forKey: settingsKey),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return nil
        }
        return settings
    }

    func saveSettings() {
        guard let settings = appState?.settings,
              let data = try? JSONEncoder().encode(settings) else {
            return
        }

        userDefaults.set(data, forKey: settingsKey)
        NotificationCenter.default.post(name: .settingsDidChange, object: nil)
    }

    // Testable version that takes settings as parameter
    func saveSettings(_ settings: AppSettings) {
        guard let data = try? JSONEncoder().encode(settings) else {
            return
        }
        userDefaults.set(data, forKey: settingsKey)
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        appState?.settings.launchAtLogin = enabled

        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to \(enabled ? "enable" : "disable") launch at login: \(error)")
            }
        }

        saveSettings()
    }

    func isLaunchAtLoginEnabled() -> Bool {
        if #available(macOS 13.0, *) {
            return SMAppService.mainApp.status == .enabled
        }
        return false
    }
}
