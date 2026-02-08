import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    let appState = AppState()
    private var pickerWindowController: PickerWindowController?
    private var settingsWindow: NSWindow?
    private var aboutWindow: NSWindow?
    private var statusItem: NSStatusItem?
    private var pendingURL: URL?
    private var settingsObserver: NSObjectProtocol?

    // Test mode flags
    private var isUITesting: Bool {
        CommandLine.arguments.contains("--ui-testing")
    }

    private var shouldShowPickerForTesting: Bool {
        CommandLine.arguments.contains("--show-picker-for-testing")
    }

    private var shouldShowSettingsForTesting: Bool {
        CommandLine.arguments.contains("--show-settings-for-testing")
    }

    private var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    private var isRunningInPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PLAYGROUNDS"] == "1"
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Skip most initialization when running in Xcode previews
        if isRunningInPreview {
            return
        }

        // Skip most initialization when running unit tests
        if isRunningTests && !isUITesting {
            return
        }

        // Set as accessory app (menu bar only, doesn't quit on window close)
        NSApp.setActivationPolicy(.accessory)

        // Initialize app state
        appState.loadSettings()
        appState.refreshBrowsers()

        // Set up menu bar
        updateMenuBarVisibility()

        // Observe settings changes for menu bar visibility
        settingsObserver = NotificationCenter.default.addObserver(
            forName: .settingsDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateMenuBarVisibility()
        }

        // Show picker if launched with testing flag
        if shouldShowPickerForTesting {
            let testURL = URL(string: "https://example.com")!
            showPicker(for: testURL)
        }

        // Show settings if launched with testing flag
        if shouldShowSettingsForTesting {
            showSettings()
        }
    }

    private func updateMenuBarVisibility() {
        if appState.settings.showMenuBarIcon {
            if statusItem == nil {
                setupMenuBar()
            }
        } else {
            if let item = statusItem {
                NSStatusBar.system.removeStatusItem(item)
                statusItem = nil
            }
        }
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

    private func showPicker(for url: URL) {
        // Get cursor position
        let mouseLocation = NSEvent.mouseLocation

        // Close existing picker if any
        pickerWindowController?.close()

        // Create and show new picker
        pickerWindowController = PickerWindowController(appState: appState, url: url)
        pickerWindowController?.onOpenSettings = { [weak self] in
            self?.showSettings()
        }
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

    func application(_ application: NSApplication, open urls: [URL]) {
        guard let url = urls.first else { return }
        pendingURL = url
        showPicker(for: url)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
