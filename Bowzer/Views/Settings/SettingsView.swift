import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView {
            SetupTab()
                .tabItem {
                    Label("Setup", systemImage: "gear")
                }

            BrowsersTab()
                .environmentObject(appState)
                .tabItem {
                    Label("Browsers", systemImage: "globe")
                }

            PreferencesTab()
                .environmentObject(appState)
                .tabItem {
                    Label("Preferences", systemImage: "slider.horizontal.3")
                }
        }
        .frame(width: 450, height: 350)
    }
}

#Preview("Settings View") {
    let appState = AppState()
    
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
    
    appState.browsers = [safari, chrome]
    appState.settings.showProfileLabels = true
    appState.applyBrowserOrder()
    
    return SettingsView()
        .environmentObject(appState)
        .frame(width: 450, height: 350)
}
