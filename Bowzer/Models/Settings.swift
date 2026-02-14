import Foundation

struct AppSettings: Codable {
    var browserOrder: [String] = []  // Array of BrowserDisplayItem IDs for ordering
    var hiddenBrowsers: [String] = []  // Array of BrowserDisplayItem IDs to hide
    var launchAtLogin: Bool = false
    var showProfileLabels: Bool = true
    var showMenuBarIcon: Bool = true
    var usageCount: [String: Int] = [:]  // Maps BrowserDisplayItem IDs to usage counts

    // Custom decoder to handle missing keys from older saved settings
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        browserOrder = try container.decodeIfPresent([String].self, forKey: .browserOrder) ?? []
        hiddenBrowsers = try container.decodeIfPresent([String].self, forKey: .hiddenBrowsers) ?? []
        launchAtLogin = try container.decodeIfPresent(Bool.self, forKey: .launchAtLogin) ?? false
        showProfileLabels = try container.decodeIfPresent(Bool.self, forKey: .showProfileLabels) ?? true
        showMenuBarIcon = try container.decodeIfPresent(Bool.self, forKey: .showMenuBarIcon) ?? true
        usageCount = try container.decodeIfPresent([String: Int].self, forKey: .usageCount) ?? [:]
    }

    init(
        browserOrder: [String] = [],
        hiddenBrowsers: [String] = [],
        launchAtLogin: Bool = false,
        showProfileLabels: Bool = true,
        showMenuBarIcon: Bool = true,
        usageCount: [String: Int] = [:]
    ) {
        self.browserOrder = browserOrder
        self.hiddenBrowsers = hiddenBrowsers
        self.launchAtLogin = launchAtLogin
        self.showProfileLabels = showProfileLabels
        self.showMenuBarIcon = showMenuBarIcon
        self.usageCount = usageCount
    }

    /// Returns the usage count for a specific browser/profile item
    func getUsageCount(for itemId: String) -> Int {
        usageCount[itemId] ?? 0
    }

    /// Increments the usage count for a specific browser/profile item
    mutating func incrementUsageCount(for itemId: String) {
        usageCount[itemId, default: 0] += 1
    }
}
