import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        TabView {
            SetupTab()
                .tabItem {
                    Label("tabs.setup", systemImage: "gear")
                }

            BrowsersTab(appState: appState)
                .tabItem {
                    Label("tabs.browsers", systemImage: "globe")
                }

            PreferencesTab(appState: appState)
                .tabItem {
                    Label("tabs.preferences", systemImage: "slider.horizontal.3")
                }
        }
        .frame(width: 450, height: 350)
    }
}

#Preview("Settings View") {
    @Previewable @State var appState: AppState = {
        let state = AppState()

        // Create sample browsers
        let safari = Browser(
            id: "safari",
            name: "Safari",
            bundleIdentifier: "com.apple.Safari",
            path: URL(fileURLWithPath: "/Applications/Safari.app"),
            icon: NSWorkspace.shared.icon(forFile: "/Applications/Safari.app"),
            profiles: []
        )

        let chrome = Browser(
            id: "chrome",
            name: "Chrome",
            bundleIdentifier: "com.google.Chrome",
            path: URL(fileURLWithPath: "/Applications/Google Chrome.app"),
            icon: NSWorkspace.shared.icon(forFile: "/Applications/Google Chrome.app"),
            profiles: [
                BrowserProfile(id: "1", name: "Personal", directoryName: "Profile 1"),
                BrowserProfile(id: "2", name: "Work", directoryName: "Profile 2")
            ]
        )

        state.browsers = [safari, chrome]
        state.settings.showProfileLabels = true
        state.applyBrowserOrder()
        return state
    }()

    SettingsView()
        .environment(appState)
        .frame(width: 450, height: 350)
}
