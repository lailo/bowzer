import Foundation

enum KeyCode {
    static let escape: UInt16 = 53
}

enum PickerLayout {
    /// Horizontal padding around the picker content
    static let horizontalPadding: CGFloat = 12
    /// Vertical padding around the picker content
    static let verticalPadding: CGFloat = 10
    /// Spacing between browser items
    static let itemSpacing: CGFloat = 8
    /// Corner radius for the picker background
    static let cornerRadius: CGFloat = 12
    /// Browser icon size
    static let iconSize: CGFloat = 48
    /// Padding within each browser item
    static let itemPadding: CGFloat = 6
    /// Corner radius for item hover background
    static let itemCornerRadius: CGFloat = 8

    // Keyboard badge layout
    /// Size of keyboard shortcut badge
    static let badgeSize: CGFloat = 16
    /// Font size for badge text
    static let badgeFontSize: CGFloat = 10
    /// Badge offset from icon corner
    static let badgeOffset: CGFloat = 4

    // Profile label layout
    /// Font size for profile labels
    static let labelFontSize: CGFloat = 10
    /// Maximum width for profile labels (matches icon size)
    static let labelMaxWidth: CGFloat = iconSize

    /// Distance from picker left edge to center of first icon
    /// Calculated as: horizontalPadding + itemPadding + (iconSize / 2)
    static var firstIconCenterOffset: CGFloat {
        horizontalPadding + itemPadding + (iconSize / 2)
    }
}

enum AppInfo {
    /// App version from bundle, falls back to "Unknown"
    static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    /// Build number from bundle, falls back to "Unknown"
    static var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }

    /// Full version string including build number
    static var fullVersion: String {
        "\(version) (\(build))"
    }
}
