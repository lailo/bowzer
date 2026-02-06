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
        HStack(spacing: 8) {
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
                .onHover { hovering in
                    hoveredItem = hovering ? item.id : nil
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.2))
                .shadow(color: .black.opacity(0.5), radius: 12, x: 0, y: 4)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
        appState.urlLaunchService.launch(url: url, with: item)
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
        if event.keyCode == 53 { // Escape
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
