import SwiftUI

struct SetupTab: View {
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("setup.defaultBrowserDescription", tableName: "Localizable")
                        .foregroundColor(.secondary)

                    Button(String(localized: "setup.openSystemSettings", table: "Localizable")) {
                        openDefaultBrowserSettings()
                    }
                }
            } header: {
                Text("setup.defaultBrowser", tableName: "Localizable")
            }

            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text("setup.howItWorksDescription1", tableName: "Localizable")
                        .foregroundColor(.secondary)
                    Text("setup.howItWorksDescription2", tableName: "Localizable")
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("setup.howItWorks", tableName: "Localizable")
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

#Preview("Setup Tab") {
    return SetupTab()
        .frame(width: 450, height: 350)
}
