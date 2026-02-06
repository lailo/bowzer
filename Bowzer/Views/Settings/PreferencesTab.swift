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
