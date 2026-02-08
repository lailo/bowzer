import SwiftUI

struct PreferencesTab: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Form {
            Section {
                Toggle(String(localized: "preferences.showProfileLabels"), isOn: Binding(
                    get: { appState.settings.showProfileLabels },
                    set: { newValue in
                        appState.settings.showProfileLabels = newValue
                        appState.saveSettings()
                    }
                ))
                .accessibilityIdentifier("showProfileLabelsToggle")

                VStack(alignment: .leading, spacing: 4) {
                    Toggle(String(localized: "preferences.showMenuBarIcon"), isOn: Binding(
                        get: { appState.settings.showMenuBarIcon },
                        set: { newValue in
                            appState.settings.showMenuBarIcon = newValue
                            appState.saveSettings()
                        }
                    ))
                    .accessibilityIdentifier("showMenuBarIconToggle")

                    Text("preferences.menuBarHint")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("preferences.display")
            }

            Section {
                Toggle(String(localized: "preferences.launchAtLogin"), isOn: Binding(
                    get: { appState.isLaunchAtLoginEnabled() },
                    set: { newValue in
                        appState.setLaunchAtLogin(newValue)
                    }
                ))
                .accessibilityIdentifier("launchAtLoginToggle")
            } header: {
                Text("preferences.startup")
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
