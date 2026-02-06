import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    let appState = AppState()
    private var pickerWindowController: PickerWindowController?
    private var settingsWindow: NSWindow?
    private var aboutWindow: NSWindow?
    private var statusItem: NSStatusItem?
    private var pendingURL: URL?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Register for URL events
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleURLEvent(_:replyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )

        // Initialize services
        appState.browserDetectionService.detectBrowsers()
        appState.profileDetectionService.detectAllProfiles(for: appState.browsers)
        appState.settingsService.loadSettings()
        appState.applyBrowserOrder()

        // Set up menu bar
        setupMenuBar()
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "globe", accessibilityDescription: "Bowzer")
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "About Bowzer", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(showSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Bowzer", action: #selector(quitApp), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

    @objc func handleURLEvent(_ event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor) {
        guard let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
              let url = URL(string: urlString) else {
            return
        }

        pendingURL = url
        showPicker(for: url)
    }

    private func showPicker(for url: URL) {
        // Get cursor position
        let mouseLocation = NSEvent.mouseLocation

        // Close existing picker if any
        pickerWindowController?.close()

        // Create and show new picker
        pickerWindowController = PickerWindowController(appState: appState, url: url)
        pickerWindowController?.showAtLocation(mouseLocation)
    }

    @objc func showSettings() {
        if let window = settingsWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let settingsView = SettingsView()
            .environmentObject(appState)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 450, height: 350),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Bowzer Settings"
        window.contentView = NSHostingView(rootView: settingsView)
        window.center()
        window.isReleasedWhenClosed = false

        self.settingsWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func showAbout() {
        if let window = aboutWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let aboutView = AboutView()

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 200),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "About Bowzer"
        window.contentView = NSHostingView(rootView: aboutView)
        window.center()
        window.isReleasedWhenClosed = false

        self.aboutWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showSettings()
        return true
    }
}
