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

// MARK: - Setup Tab

struct SetupTab: View {
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Set Bowzer as your default browser to intercept links from other applications.")
                        .foregroundColor(.secondary)

                    Button("Open System Settings") {
                        openDefaultBrowserSettings()
                    }
                }
            } header: {
                Text("Default Browser")
            }

            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text("When you click a link, Bowzer shows a picker at your cursor.")
                        .foregroundColor(.secondary)
                    Text("Press 1-9 to quickly select a browser, or Escape to cancel.")
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("How it works")
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    private func openDefaultBrowserSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.Desktop-Settings.extension") {
            NSWorkspace.shared.open(url)
        }
    }
}

// MARK: - Browsers Tab

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

                        if let profile = item.profile, item.showProfileLabel {
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

// MARK: - Preferences Tab

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
