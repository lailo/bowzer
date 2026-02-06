import SwiftUI

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

#Preview("Setup Tab") {
    SetupTab()
        .frame(width: 450, height: 350)
}
