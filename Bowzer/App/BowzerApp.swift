import SwiftUI

@main
struct BowzerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Empty Settings scene - we manage windows manually via AppDelegate
        Settings {
            EmptyView()
        }
    }
}
