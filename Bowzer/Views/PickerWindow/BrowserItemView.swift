import SwiftUI

struct BrowserItemView: View {
    let item: BrowserDisplayItem
    let index: Int
    let isHovered: Bool
    let showLabel: Bool
    let hasAnyLabels: Bool  // Whether any item in the picker has labels
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Image(nsImage: item.browser.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: PickerLayout.iconSize, height: PickerLayout.iconSize)
                        .scaleEffect(isHovered ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.15), value: isHovered)

                    // Keyboard shortcut badge
                    if index <= 9 {
                        Text("\(index)")
                            .font(.system(size: PickerLayout.badgeFontSize, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: PickerLayout.badgeSize, height: PickerLayout.badgeSize)
                            .background(
                                Circle()
                                    .fill(Color.gray.opacity(0.7))
                            )
                            .offset(x: PickerLayout.badgeOffset, y: -PickerLayout.badgeOffset)
                    }
                }

                // Label or spacer for alignment
                if hasAnyLabels {
                    Text(showLabel ? (item.profile?.truncatedName ?? "") : " ")
                        .font(.system(size: PickerLayout.labelFontSize))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .frame(maxWidth: PickerLayout.labelMaxWidth)
                        .opacity(showLabel ? 1 : 0)
                }
            }
            .padding(PickerLayout.itemPadding)
            .background(
                RoundedRectangle(cornerRadius: PickerLayout.itemCornerRadius)
                    .fill(isHovered ? Color.gray.opacity(0.2) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabelText)
        .accessibilityHint(accessibilityHintText)
        .accessibilityAddTraits(.isButton)
        .onHover { hovering in
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }

    // MARK: - Accessibility

    private var accessibilityLabelText: String {
        if let profile = item.profile {
            return "\(item.browser.name), \(profile.name) profile"
        }
        return item.browser.name
    }

    private var accessibilityHintText: String {
        if index <= 9 {
            return "Press \(index) to open in this browser"
        }
        return "Activate to open in this browser"
    }
}

#Preview("Browser Item with Profile") {
    let sampleBrowser = Browser(
        id: "safari",
        name: "Safari",
        bundleIdentifier: "com.apple.Safari",
        path: URL(fileURLWithPath: "/Applications/Safari.app"),
        icon: NSWorkspace.shared.icon(forFile: "/Applications/Safari.app"),
        profiles: [
            BrowserProfile(id: "1", name: "Personal", directoryName: "Profile 1"),
            BrowserProfile(id: "2", name: "Work", directoryName: "Profile 2")
        ]
    )
    
    let item = BrowserDisplayItem(
        browser: sampleBrowser,
        profile: sampleBrowser.profiles.first
    )
    
    BrowserItemView(
        item: item,
        index: 1,
        isHovered: false,
        showLabel: true,
        hasAnyLabels: true,
        onSelect: { print("Selected") }
    )
    .padding()
}

#Preview("Browser Item Hovered") {
    let sampleBrowser = Browser(
        id: "chrome",
        name: "Chrome",
        bundleIdentifier: "com.google.Chrome",
        path: URL(fileURLWithPath: "/Applications/Google Chrome.app"),
        icon: NSWorkspace.shared.icon(forFile: "/Applications/Google Chrome.app"),
        profiles: []
    )
    
    let item = BrowserDisplayItem(
        browser: sampleBrowser,
        profile: nil
    )
    
    BrowserItemView(
        item: item,
        index: 2,
        isHovered: true,
        showLabel: false,
        hasAnyLabels: false,
        onSelect: { print("Selected") }
    )
    .padding()
}
