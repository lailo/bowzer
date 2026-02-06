import Foundation

struct AppSettings: Codable {
    var browserOrder: [String] = []  // Array of BrowserDisplayItem IDs for ordering
    var hiddenBrowsers: [String] = []  // Array of BrowserDisplayItem IDs to hide
    var launchAtLogin: Bool = false
    var showProfileLabels: Bool = true
}
