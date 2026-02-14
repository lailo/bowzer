import SwiftUI

struct PreferencesTab: View {
    @Bindable var appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

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
    @Previewable @State var appState: AppState = {
        let state = AppState()
        state.settings.showProfileLabels = true
        state.settings.launchAtLogin = false
        return state
    }()

    PreferencesTab(appState: appState)
        .frame(width: 450, height: 350)
}
