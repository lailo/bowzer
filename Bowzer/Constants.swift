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

    /// Distance from picker left edge to center of first icon
    /// Calculated as: horizontalPadding + itemPadding + (iconSize / 2)
    static var firstIconCenterOffset: CGFloat {
        horizontalPadding + itemPadding + (iconSize / 2)
    }
}
