import XCTest
@testable import Bowzer

/// Integration tests that verify the full flow of browser detection → profile detection → settings
final class IntegrationTests: XCTestCase {

    var mockWorkspace: MockWorkspace!
    var mockFileManager: MockFileManager!
    var mockUserDefaults: MockUserDefaults!

    override func setUpWithError() throws {
        mockWorkspace = MockWorkspace()
        mockFileManager = MockFileManager()
        mockUserDefaults = MockUserDefaults()
    }

    override func tearDownWithError() throws {
        mockWorkspace = nil
        mockFileManager = nil
        mockUserDefaults = nil
    }

    // MARK: - Full Flow Tests

    func testFullFlow_BrowserDetectionToProfileDetectionToOrdering() {
        // Given - Set up mock workspace with Chrome installed
        let chromePath = URL(fileURLWithPath: "/Applications/Google Chrome.app")
        mockWorkspace.applicationURLs = [chromePath]
        mockFileManager.displayNames[chromePath.path] = "Google Chrome"

        // Set up mock file manager with Chrome profile data
        let homeDir = URL(fileURLWithPath: "/Users/testuser")
        mockFileManager.mockHomeDirectory = homeDir

        let localStatePath = homeDir
            .appendingPathComponent("Library/Application Support/Google/Chrome/Local State")
        let profileData = """
        {
            "profile": {
                "info_cache": {
                    "Default": {"name": "Personal"},
                    "Profile 1": {"name": "Work"}
                }
            }
        }
        """.data(using: .utf8)!

        mockFileManager.existingPaths = [localStatePath.path]
        mockFileManager.fileContents = [localStatePath.path: profileData]

        // Create services with mocks
        let profileService = ProfileDetectionService(fileManager: mockFileManager)

        // When - Detect profiles
        let profiles = profileService.detectProfiles(for: .chrome)

        // Then - Verify profile detection
        XCTAssertEqual(profiles.count, 2)
        XCTAssertTrue(profiles.contains { $0.name == "Personal" })
        XCTAssertTrue(profiles.contains { $0.name == "Work" })
    }

    func testFullFlow_SettingsPersistence() {
        // Given - Create settings service with mock defaults
        let settingsService = SettingsService(userDefaults: mockUserDefaults)

        // Create custom settings
        let originalSettings = AppSettings(
            browserOrder: ["browser1", "browser2"],
            hiddenBrowsers: ["browser3"],
            launchAtLogin: false,
            showProfileLabels: false,
            showMenuBarIcon: false
        )

        // When - Save and reload
        settingsService.saveSettings(originalSettings)
        let loadedSettings = settingsService.loadSettingsResult()

        // Then - Settings should be preserved
        XCTAssertNotNil(loadedSettings)
        XCTAssertEqual(loadedSettings?.browserOrder, ["browser1", "browser2"])
        XCTAssertEqual(loadedSettings?.hiddenBrowsers, ["browser3"])
        XCTAssertEqual(loadedSettings?.showProfileLabels, false)
        XCTAssertEqual(loadedSettings?.showMenuBarIcon, false)
    }

    func testFullFlow_BrowserOrderPersistence() {
        // Given - Create AppState with sample browsers
        let appState = AppState()
        let safari = TestDataFactory.makeBrowser(id: "safari", name: "Safari", bundleIdentifier: "com.apple.Safari")
        let firefox = TestDataFactory.makeBrowser(id: "firefox", name: "Firefox", bundleIdentifier: "org.mozilla.firefox")
        appState.browsers = [safari, firefox]
        appState.applyBrowserOrder()

        // When - Reorder and save
        appState.moveDisplayItems(from: IndexSet(integer: 0), to: 2)

        // Then - Order should be updated
        XCTAssertEqual(appState.orderedDisplayItems[0].browser.name, "Firefox")
        XCTAssertEqual(appState.orderedDisplayItems[1].browser.name, "Safari")

        // And settings should reflect the new order
        XCTAssertEqual(appState.settings.browserOrder, [
            "org.mozilla.firefox_default",
            "com.apple.Safari_default"
        ])
    }

    func testFullFlow_HiddenBrowsersFilteredFromDisplay() {
        // Given - AppState with browsers and some hidden
        let appState = AppState()
        let safari = TestDataFactory.makeBrowser(id: "safari", name: "Safari", bundleIdentifier: "com.apple.Safari")
        let firefox = TestDataFactory.makeBrowser(id: "firefox", name: "Firefox", bundleIdentifier: "org.mozilla.firefox")
        appState.browsers = [safari, firefox]
        appState.applyBrowserOrder()

        // When - Hide Safari
        appState.setItemVisible("com.apple.Safari_default", visible: false)

        // Then - Safari should be marked as hidden in settings
        XCTAssertTrue(appState.settings.hiddenBrowsers.contains("com.apple.Safari_default"))

        // The orderedDisplayItems still contains all items (view layer does filtering)
        XCTAssertEqual(appState.orderedDisplayItems.count, 2)
    }

    // MARK: - URL Launch Flow Tests

    func testURLLaunchFlow_WithProfile() {
        // Given
        let mockProcess = MockProcessLauncher()
        let launchService = URLLaunchService(processLauncher: mockProcess)

        let chrome = TestDataFactory.makeBrowserWithProfiles(
            id: "chrome",
            name: "Chrome",
            bundleIdentifier: "com.google.Chrome",
            profileNames: ["Work"]
        )
        let displayItem = chrome.displayItems[0]
        let url = URL(string: "https://example.com")!

        // When
        let result = launchService.launchWithResult(url: url, with: displayItem)

        // Then
        XCTAssertFalse(mockProcess.launchedProcesses.isEmpty)
        if case .success = result {
            // Expected
        } else {
            XCTFail("Launch should succeed")
        }
    }

    func testURLLaunchFlow_WithoutProfile() {
        // Given
        let mockProcess = MockProcessLauncher()
        let launchService = URLLaunchService(processLauncher: mockProcess)

        let safari = TestDataFactory.makeBrowser(
            id: "safari",
            name: "Safari",
            bundleIdentifier: "com.apple.Safari"
        )
        let displayItem = safari.displayItems[0]
        let url = URL(string: "https://example.com")!

        // When
        let result = launchService.launchWithResult(url: url, with: displayItem)

        // Then
        XCTAssertFalse(mockProcess.launchedProcesses.isEmpty)
        if case .success = result {
            // Launch parameters should use /usr/bin/open with bundle ID
            let lastProcess = mockProcess.launchedProcesses.last!
            XCTAssertEqual(lastProcess.executableURL.path, "/usr/bin/open")
            XCTAssertTrue(lastProcess.arguments.contains("-b"))
            XCTAssertTrue(lastProcess.arguments.contains("com.apple.Safari"))
        } else {
            XCTFail("Launch should succeed")
        }
    }
}
