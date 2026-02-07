import Foundation

extension Notification.Name {
    static let settingsDidChange = Notification.Name("settingsDidChange")
}

struct AppSettings: Codable {
    var browserOrder: [String] = []  // Array of BrowserDisplayItem IDs for ordering
    var hiddenBrowsers: [String] = []  // Array of BrowserDisplayItem IDs to hide
    var launchAtLogin: Bool = false
    var showProfileLabels: Bool = true
    var showMenuBarIcon: Bool = true

    // Custom decoder to handle missing keys from older saved settings
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        browserOrder = try container.decodeIfPresent([String].self, forKey: .browserOrder) ?? []
        hiddenBrowsers = try container.decodeIfPresent([String].self, forKey: .hiddenBrowsers) ?? []
        launchAtLogin = try container.decodeIfPresent(Bool.self, forKey: .launchAtLogin) ?? false
        showProfileLabels = try container.decodeIfPresent(Bool.self, forKey: .showProfileLabels) ?? true
        showMenuBarIcon = try container.decodeIfPresent(Bool.self, forKey: .showMenuBarIcon) ?? true
    }

    init(
        browserOrder: [String] = [],
        hiddenBrowsers: [String] = [],
        launchAtLogin: Bool = false,
        showProfileLabels: Bool = true,
        showMenuBarIcon: Bool = true
    ) {
        self.browserOrder = browserOrder
        self.hiddenBrowsers = hiddenBrowsers
        self.launchAtLogin = launchAtLogin
        self.showProfileLabels = showProfileLabels
        self.showMenuBarIcon = showMenuBarIcon
    }
}
