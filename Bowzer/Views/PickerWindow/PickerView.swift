import SwiftUI
import AppKit

struct PickerView: View {
    @ObservedObject var appState: AppState
    let url: URL
    let onDismiss: () -> Void

    @State private var hoveredItem: String?

    private var displayItems: [BrowserDisplayItem] {
        appState.orderedDisplayItems
            .filter { !appState.settings.hiddenBrowsers.contains($0.id) }
    }

    private var hasAnyLabels: Bool {
        appState.settings.showProfileLabels && displayItems.contains { $0.showProfileLabel }
    }

    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            HStack(spacing: PickerLayout.itemSpacing) {
                ForEach(Array(displayItems.enumerated()), id: \.element.id) { index, item in
                    BrowserItemView(
                        item: item,
                        index: index + 1,
                        isHovered: hoveredItem == item.id,
                        showLabel: appState.settings.showProfileLabels && item.showProfileLabel,
                        hasAnyLabels: hasAnyLabels,
                        onSelect: {
                            launchURL(with: item)
                        }
                    )
                    .accessibilityIdentifier("browserItem_\(item.id)")
                    .onHover { hovering in
                        hoveredItem = hovering ? item.id : nil
                    }
                }
            }
            .padding(.horizontal, PickerLayout.horizontalPadding)
            .padding(.vertical, PickerLayout.verticalPadding)
            .background(
                RoundedRectangle(cornerRadius: PickerLayout.cornerRadius)
                    .fill(Color(white: 0.2))
                    .shadow(color: .black.opacity(0.5), radius: 12, x: 0, y: 4)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .background(KeyboardEventHandler(
            onEscape: onDismiss,
            onDigit: { digit in
                if digit >= 1 && digit <= displayItems.count {
                    launchURL(with: displayItems[digit - 1])
                }
            }
        ))
    }

    private func launchURL(with item: BrowserDisplayItem) {
        appState.launchURL(url, with: item)
        onDismiss()
    }
}

// NSViewRepresentable to handle keyboard events in macOS 13
struct KeyboardEventHandler: NSViewRepresentable {
    let onEscape: () -> Void
    let onDigit: (Int) -> Void

    func makeNSView(context: Context) -> KeyboardHandlingView {
        let view = KeyboardHandlingView()
        view.onEscape = onEscape
        view.onDigit = onDigit
        return view
    }

    func updateNSView(_ nsView: KeyboardHandlingView, context: Context) {
        nsView.onEscape = onEscape
        nsView.onDigit = onDigit
    }
}

class KeyboardHandlingView: NSView {
    var onEscape: (() -> Void)?
    var onDigit: ((Int) -> Void)?

    override var acceptsFirstResponder: Bool { true }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        window?.makeFirstResponder(self)
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == KeyCode.escape {
            onEscape?()
            return
        }

        if let characters = event.characters,
           let digit = Int(characters),
           digit >= 1 && digit <= 9 {
            onDigit?(digit)
            return
        }

        super.keyDown(with: event)
    }
}

#Preview {
    // Create mock browsers with icons
    let safariIcon = NSWorkspace.shared.icon(forFile: "/Applications/Safari.app")
    let chromeIcon = NSWorkspace.shared.icon(forFile: "/Applications/Google Chrome.app")
    
    let safari = Browser(
        id: "safari",
        name: "Safari",
        bundleIdentifier: "com.apple.Safari",
        path: URL(fileURLWithPath: "/Applications/Safari.app"),
        icon: safariIcon,
        profiles: []
    )
    
    let chrome = Browser(
        id: "chrome",
        name: "Chrome",
        bundleIdentifier: "com.google.Chrome",
        path: URL(fileURLWithPath: "/Applications/Google Chrome.app"),
        icon: chromeIcon,
        profiles: [
            BrowserProfile(id: "profile1", name: "Personal", directoryName: "Default"),
            BrowserProfile(id: "profile2", name: "Work", directoryName: "Profile 1")
        ]
    )
    
    let firefox = Browser(
        id: "firefox",
        name: "Firefox",
        bundleIdentifier: "org.mozilla.firefox",
        path: URL(fileURLWithPath: "/Applications/Firefox.app"),
        icon: NSWorkspace.shared.icon(forFile: "/Applications/Firefox.app"),
        profiles: []
    )
    
    // Create AppState with mock data
    let appState = AppState()
    appState.browsers = [safari, chrome, firefox]
    appState.applyBrowserOrder()
    
    return PickerView(
        appState: appState,
        url: URL(string: "https://www.apple.com")!,
        onDismiss: {}
    )
    .frame(width: 280, height: 100)
}
