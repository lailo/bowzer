import SwiftUI

struct BrowsersTab: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(appState.orderedDisplayItems) { item in
                    HStack {
                        Toggle("", isOn: Binding(
                            get: { !appState.settings.hiddenBrowsers.contains(item.id) },
                            set: { isVisible in
                                if isVisible {
                                    appState.settings.hiddenBrowsers.removeAll { $0 == item.id }
                                } else {
                                    appState.settings.hiddenBrowsers.append(item.id)
                                }
                                appState.settingsService.saveSettings()
                            }
                        ))
                        .toggleStyle(.checkbox)
                        .labelsHidden()

                        Image(nsImage: item.browser.icon)
                            .resizable()
                            .frame(width: 24, height: 24)

                        Text(item.browser.name)

                        if let profile = item.profile, item.browser.profiles.count > 1 {
                            Text("— \(profile.name)")
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                .onMove { source, destination in
                    appState.moveDisplayItems(from: source, to: destination)
                }
            }

            Divider()

            HStack {
                Text("Drag to reorder, toggle to show/hide")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Button("Refresh") {
                    appState.browserDetectionService.detectBrowsers()
                    appState.profileDetectionService.detectAllProfiles(for: appState.browsers)
                    appState.applyBrowserOrder()
                }
            }
            .padding(12)
        }
    }
}

#Preview("Browsers Tab") {
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
    appState.applyBrowserOrder()
    
    return BrowsersTab()
        .environmentObject(appState)
        .frame(width: 450, height: 350)
}
