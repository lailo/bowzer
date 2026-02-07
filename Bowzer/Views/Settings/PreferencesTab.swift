import SwiftUI

struct PreferencesTab: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Form {
            Section {
                Toggle("Show profile labels", isOn: Binding(
                    get: { appState.settings.showProfileLabels },
                    set: { newValue in
                        appState.settings.showProfileLabels = newValue
                        appState.settingsService.saveSettings()
                    }
                ))
                .accessibilityIdentifier("showProfileLabelsToggle")

                VStack(alignment: .leading, spacing: 4) {
                    Toggle("Show menu bar icon", isOn: Binding(
                        get: { appState.settings.showMenuBarIcon },
                        set: { newValue in
                            appState.settings.showMenuBarIcon = newValue
                            appState.settingsService.saveSettings()
                        }
                    ))
                    .accessibilityIdentifier("showMenuBarIconToggle")

                    Text("Press , in the picker or reopen the app to access Settings")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("Display")
            }

            Section {
                Toggle("Launch at login", isOn: Binding(
                    get: { appState.settingsService.isLaunchAtLoginEnabled() },
                    set: { newValue in
                        appState.settingsService.setLaunchAtLogin(newValue)
                    }
                ))
                .accessibilityIdentifier("launchAtLoginToggle")
            } header: {
                Text("Startup")
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

#Preview("Preferences Tab") {
    let appState = AppState()
    appState.settings.showProfileLabels = true
    appState.settings.launchAtLogin = false
    
    return PreferencesTab()
        .environmentObject(appState)
        .frame(width: 450, height: 350)
}
