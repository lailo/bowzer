import XCTest
@testable import Bowzer

final class SettingsServiceTests: XCTestCase {

    var service: SettingsService!
    var mockUserDefaults: MockUserDefaults!

    override func setUpWithError() throws {
        mockUserDefaults = MockUserDefaults()
        service = SettingsService(userDefaults: mockUserDefaults)
    }

    override func tearDownWithError() throws {
        service = nil
        mockUserDefaults = nil
    }

    // MARK: - Save and Load Tests

    func testSaveSettings_StoresEncodedData() {
        let settings = AppSettings(
            browserOrder: ["browser1", "browser2"],
            hiddenBrowsers: ["browser3"],
            launchAtLogin: true,
            showProfileLabels: false,
            showMenuBarIcon: false
        )

        service.saveSettings(settings)

        XCTAssertNotNil(mockUserDefaults.storage["BowzerSettings"])
        XCTAssertTrue(mockUserDefaults.storage["BowzerSettings"] is Data)
    }

    func testLoadSettingsResult_ReturnsDefaultsWhenEmpty() {
        let settings = service.loadSettingsResult()
        XCTAssertNotNil(settings)
        // Should return default settings when no saved data exists
        XCTAssertEqual(settings?.browserOrder, [])
        XCTAssertEqual(settings?.hiddenBrowsers, [])
        XCTAssertEqual(settings?.launchAtLogin, false)
        XCTAssertEqual(settings?.showProfileLabels, true)
        XCTAssertEqual(settings?.showMenuBarIcon, true)
    }

    func testLoadSettingsResult_ReturnsStoredSettings() {
        // Save settings first
        let originalSettings = AppSettings(
            browserOrder: ["browser1", "browser2"],
            hiddenBrowsers: ["browser3"],
            launchAtLogin: true,
            showProfileLabels: false,
            showMenuBarIcon: false
        )
        service.saveSettings(originalSettings)

        // Load them back
        let loadedSettings = service.loadSettingsResult()

        XCTAssertNotNil(loadedSettings)
        XCTAssertEqual(loadedSettings?.browserOrder, ["browser1", "browser2"])
        XCTAssertEqual(loadedSettings?.hiddenBrowsers, ["browser3"])
        XCTAssertEqual(loadedSettings?.launchAtLogin, true)
        XCTAssertEqual(loadedSettings?.showProfileLabels, false)
        XCTAssertEqual(loadedSettings?.showMenuBarIcon, false)
    }

    func testLoadSettingsResult_ReturnsNilForCorruptedData() {
        mockUserDefaults.storage["BowzerSettings"] = "not valid json".data(using: .utf8)

        let settings = service.loadSettingsResult()
        XCTAssertNil(settings)
    }

    // MARK: - Default Values Tests

    func testAppSettings_DefaultValues() {
        let settings = AppSettings()

        XCTAssertEqual(settings.browserOrder, [])
        XCTAssertEqual(settings.hiddenBrowsers, [])
        XCTAssertEqual(settings.launchAtLogin, false)
        XCTAssertEqual(settings.showProfileLabels, true)
        XCTAssertEqual(settings.showMenuBarIcon, true)
    }

    // MARK: - Round-trip Tests

    func testSaveAndLoad_PreservesBrowserOrder() {
        let order = ["com.google.Chrome_Default", "com.apple.Safari_default", "org.mozilla.firefox_default"]
        let settings = AppSettings(browserOrder: order, hiddenBrowsers: [], launchAtLogin: false, showProfileLabels: true)

        service.saveSettings(settings)
        let loaded = service.loadSettingsResult()

        XCTAssertEqual(loaded?.browserOrder, order)
    }

    func testSaveAndLoad_PreservesHiddenBrowsers() {
        let hidden = ["com.brave.Browser_default"]
        let settings = AppSettings(browserOrder: [], hiddenBrowsers: hidden, launchAtLogin: false, showProfileLabels: true)

        service.saveSettings(settings)
        let loaded = service.loadSettingsResult()

        XCTAssertEqual(loaded?.hiddenBrowsers, hidden)
    }

    func testSaveAndLoad_PreservesAllBooleanStates() {
        // Test with all true
        let settingsAllTrue = AppSettings(browserOrder: [], hiddenBrowsers: [], launchAtLogin: true, showProfileLabels: true, showMenuBarIcon: true)
        service.saveSettings(settingsAllTrue)
        var loaded = service.loadSettingsResult()
        XCTAssertEqual(loaded?.launchAtLogin, true)
        XCTAssertEqual(loaded?.showProfileLabels, true)
        XCTAssertEqual(loaded?.showMenuBarIcon, true)

        // Test with all false
        let settingsAllFalse = AppSettings(browserOrder: [], hiddenBrowsers: [], launchAtLogin: false, showProfileLabels: false, showMenuBarIcon: false)
        service.saveSettings(settingsAllFalse)
        loaded = service.loadSettingsResult()
        XCTAssertEqual(loaded?.launchAtLogin, false)
        XCTAssertEqual(loaded?.showProfileLabels, false)
        XCTAssertEqual(loaded?.showMenuBarIcon, false)
    }

    // MARK: - Ghost Browser Cleanup Tests

    func testCleanupStaleBrowserEntries_RemovesUninstalledFromOrder() {
        // Given - Settings with browser order including uninstalled browser
        let appState = AppState()
        appState.settings.browserOrder = [
            "com.google.Chrome_default",
            "com.uninstalled.Browser_default",
            "com.apple.Safari_default"
        ]
        service.appState = appState

        let installedBrowserIds: Set<String> = ["com.google.Chrome", "com.apple.Safari"]

        // When
        service.cleanupStaleBrowserEntries(installedBrowserIds: installedBrowserIds)

        // Then - Uninstalled browser should be removed
        XCTAssertEqual(appState.settings.browserOrder, [
            "com.google.Chrome_default",
            "com.apple.Safari_default"
        ])
    }

    func testCleanupStaleBrowserEntries_RemovesUninstalledFromHidden() {
        // Given - Settings with hidden browser including uninstalled browser
        let appState = AppState()
        appState.settings.hiddenBrowsers = [
            "com.google.Chrome_Profile1",
            "com.uninstalled.Browser_default"
        ]
        service.appState = appState

        let installedBrowserIds: Set<String> = ["com.google.Chrome", "com.apple.Safari"]

        // When
        service.cleanupStaleBrowserEntries(installedBrowserIds: installedBrowserIds)

        // Then - Uninstalled browser should be removed from hidden
        XCTAssertEqual(appState.settings.hiddenBrowsers, [
            "com.google.Chrome_Profile1"
        ])
    }

    func testCleanupStaleBrowserEntries_PreservesInstalledBrowsers() {
        // Given - Settings with only installed browsers
        let appState = AppState()
        appState.settings.browserOrder = [
            "com.google.Chrome_default",
            "com.apple.Safari_default"
        ]
        appState.settings.hiddenBrowsers = [
            "com.google.Chrome_Work"
        ]
        service.appState = appState

        let installedBrowserIds: Set<String> = ["com.google.Chrome", "com.apple.Safari"]

        // When
        service.cleanupStaleBrowserEntries(installedBrowserIds: installedBrowserIds)

        // Then - Nothing should change
        XCTAssertEqual(appState.settings.browserOrder, [
            "com.google.Chrome_default",
            "com.apple.Safari_default"
        ])
        XCTAssertEqual(appState.settings.hiddenBrowsers, [
            "com.google.Chrome_Work"
        ])
    }

    func testCleanupStaleBrowserEntries_HandlesProfileSuffix() {
        // Given - Browser entries with profile suffixes
        let appState = AppState()
        appState.settings.browserOrder = [
            "com.google.Chrome_Default",
            "com.google.Chrome_Profile 1",
            "com.uninstalled.Browser_Work Profile"
        ]
        service.appState = appState

        let installedBrowserIds: Set<String> = ["com.google.Chrome"]

        // When
        service.cleanupStaleBrowserEntries(installedBrowserIds: installedBrowserIds)

        // Then - Chrome profiles should be preserved, uninstalled removed
        XCTAssertEqual(appState.settings.browserOrder, [
            "com.google.Chrome_Default",
            "com.google.Chrome_Profile 1"
        ])
    }

    func testCleanupStaleBrowserEntries_NoChangesWhenEmpty() {
        // Given - Empty settings
        let appState = AppState()
        appState.settings.browserOrder = []
        appState.settings.hiddenBrowsers = []
        service.appState = appState

        let installedBrowserIds: Set<String> = ["com.google.Chrome"]

        // When
        service.cleanupStaleBrowserEntries(installedBrowserIds: installedBrowserIds)

        // Then - Should remain empty
        XCTAssertEqual(appState.settings.browserOrder, [])
        XCTAssertEqual(appState.settings.hiddenBrowsers, [])
    }
}
