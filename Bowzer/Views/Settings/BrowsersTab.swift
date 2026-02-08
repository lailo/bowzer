import SwiftUI

/// Displays a usage count badge for browser items
struct UsageCountBadge: View {
    let count: Int

    var body: some View {
        if count > 0 {
            Text("\(count)")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(Color.secondary.opacity(0.15))
                )
                .help("Used \(count) time\(count == 1 ? "" : "s")")
        }
    }
}

struct BrowsersTab: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(appState.orderedDisplayItems) { item in
                    HStack {
                        Toggle("", isOn: Binding(
                            get: { appState.isItemVisible(item.id) },
                            set: { isVisible in
                                appState.setItemVisible(item.id, visible: isVisible)
                            }
                        ))
                        .toggleStyle(.checkbox)
                        .labelsHidden()
                        .accessibilityIdentifier("browserToggle_\(item.id)")

                        Image(nsImage: item.browser.icon)
                            .resizable()
                            .frame(width: 24, height: 24)

                        Text(item.browser.name)

                        if let profile = item.profile, item.browser.profiles.count > 1 {
                            Text("— \(profile.name)")
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        // Usage count badge
                        UsageCountBadge(count: appState.getUsageCount(for: item.id))

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
                    appState.refreshBrowsers()
                }
                .accessibilityIdentifier("refreshBrowsersButton")
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

    // Add sample usage counts to demonstrate the feature
    appState.settings.usageCount = [
        "com.apple.Safari_default": 42,
        "com.google.Chrome_Personal": 15,
        "com.google.Chrome_Work": 3
    ]

    return BrowsersTab()
        .environmentObject(appState)
        .frame(width: 450, height: 350)
}
