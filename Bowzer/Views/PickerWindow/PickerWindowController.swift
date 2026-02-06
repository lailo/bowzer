import AppKit
import SwiftUI

class PickerWindowController: NSObject, NSWindowDelegate {
    private var window: NSPanel?
    private let appState: AppState
    private let url: URL
    private var clickMonitor: Any?
    private var keyMonitor: Any?

    init(appState: AppState, url: URL) {
        self.appState = appState
        self.url = url
        super.init()
    }

    func showAtLocation(_ location: NSPoint) {
        let contentView = PickerView(
            appState: appState,
            url: url,
            onDismiss: { [weak self] in
                self?.close()
            }
        )

        let hostingView = NSHostingView(rootView: contentView)
        hostingView.wantsLayer = true
        hostingView.layer?.backgroundColor = .clear
        hostingView.setFrameSize(hostingView.fittingSize)

        let panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: hostingView.fittingSize),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.contentView = hostingView
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.level = .popUpMenu
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isMovableByWindowBackground = false
        panel.delegate = self

        // Position so first browser icon is under cursor
        // Layout: 12px horizontal padding + 6px item padding + 24px (half of 48px icon) = 42px to icon center
        let panelSize = hostingView.fittingSize
        let firstIconCenterX: CGFloat = 42
        let originX = location.x - firstIconCenterX
        let originY = location.y - panelSize.height / 2

        // Ensure panel stays on screen
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let adjustedX = max(screenFrame.minX, min(originX, screenFrame.maxX - panelSize.width))
            let adjustedY = max(screenFrame.minY, min(originY, screenFrame.maxY - panelSize.height))
            panel.setFrameOrigin(NSPoint(x: adjustedX, y: adjustedY))
        } else {
            panel.setFrameOrigin(NSPoint(x: originX, y: originY))
        }

        self.window = panel

        // Set up click-outside monitor
        clickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            guard let self = self, let window = self.window else { return }

            let windowFrame = window.frame
            let screenLocation = NSEvent.mouseLocation

            if !windowFrame.contains(screenLocation) {
                self.close()
            }
        }

        // Set up keyboard monitor for ESC and number keys
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return event }

            // Escape key
            if event.keyCode == 53 {
                self.close()
                return nil
            }

            // Number keys 1-9
            if let characters = event.characters,
               let digit = Int(characters),
               digit >= 1 && digit <= 9 {
                self.selectBrowser(at: digit - 1)
                return nil
            }

            return event
        }

        panel.makeKeyAndOrderFront(nil)
    }

    private func selectBrowser(at index: Int) {
        let displayItems = appState.orderedDisplayItems
            .filter { !appState.settings.hiddenBrowsers.contains($0.id) }

        guard index < displayItems.count else { return }

        let item = displayItems[index]
        appState.urlLaunchService.launch(url: url, with: item)
        close()
    }

    func close() {
        if let monitor = clickMonitor {
            NSEvent.removeMonitor(monitor)
            clickMonitor = nil
        }
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
            keyMonitor = nil
        }
        window?.close()
        window = nil
    }

    func windowDidResignKey(_ notification: Notification) {
        close()
    }
}
