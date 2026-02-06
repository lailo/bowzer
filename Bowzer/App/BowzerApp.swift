import SwiftUI

@main
struct BowzerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Empty scene - we manage windows manually via AppDelegate
        SwiftUI.Settings {
            EmptyView()
        }
    }
}
