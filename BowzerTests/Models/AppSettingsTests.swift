import XCTest
@testable import Bowzer

final class AppSettingsTests: XCTestCase {

    // MARK: - Codable Tests

    func testEncodeDecode_EmptySettings() throws {
        let settings = AppSettings()

        let data = try JSONEncoder().encode(settings)
        let decoded = try JSONDecoder().decode(AppSettings.self, from: data)

        XCTAssertEqual(decoded.browserOrder, [])
        XCTAssertEqual(decoded.hiddenBrowsers, [])
        XCTAssertEqual(decoded.launchAtLogin, false)
        XCTAssertEqual(decoded.showProfileLabels, true)
        XCTAssertEqual(decoded.showMenuBarIcon, true)
        XCTAssertEqual(decoded.hasCompletedFirstLaunch, false)
    }

    func testEncodeDecode_PopulatedSettings() throws {
        let settings = AppSettings(
            browserOrder: ["browser1", "browser2", "browser3"],
            hiddenBrowsers: ["browser4", "browser5"],
            launchAtLogin: true,
            showProfileLabels: false,
            showMenuBarIcon: false,
            hasCompletedFirstLaunch: true
        )

        let data = try JSONEncoder().encode(settings)
        let decoded = try JSONDecoder().decode(AppSettings.self, from: data)

        XCTAssertEqual(decoded.browserOrder, ["browser1", "browser2", "browser3"])
        XCTAssertEqual(decoded.hiddenBrowsers, ["browser4", "browser5"])
        XCTAssertEqual(decoded.launchAtLogin, true)
        XCTAssertEqual(decoded.showProfileLabels, false)
        XCTAssertEqual(decoded.showMenuBarIcon, false)
        XCTAssertEqual(decoded.hasCompletedFirstLaunch, true)
    }

    func testEncodeDecode_WithSpecialCharacters() throws {
        let settings = AppSettings(
            browserOrder: ["com.google.Chrome_Default", "org.mozilla.firefox_Profiles/abc.default"],
            hiddenBrowsers: [],
            launchAtLogin: false,
            showProfileLabels: true
        )

        let data = try JSONEncoder().encode(settings)
        let decoded = try JSONDecoder().decode(AppSettings.self, from: data)

        XCTAssertEqual(decoded.browserOrder, ["com.google.Chrome_Default", "org.mozilla.firefox_Profiles/abc.default"])
    }

    // MARK: - Default Values Tests

    func testDefaultValues() {
        let settings = AppSettings()

        XCTAssertEqual(settings.browserOrder, [])
        XCTAssertEqual(settings.hiddenBrowsers, [])
        XCTAssertEqual(settings.launchAtLogin, false)
        XCTAssertEqual(settings.showProfileLabels, true)
        XCTAssertEqual(settings.showMenuBarIcon, true)
        XCTAssertEqual(settings.hasCompletedFirstLaunch, false)
    }

    // MARK: - Mutability Tests

    func testBrowserOrder_IsMutable() {
        var settings = AppSettings()
        settings.browserOrder = ["a", "b", "c"]

        XCTAssertEqual(settings.browserOrder, ["a", "b", "c"])
    }

    func testHiddenBrowsers_IsMutable() {
        var settings = AppSettings()
        settings.hiddenBrowsers = ["x", "y"]

        XCTAssertEqual(settings.hiddenBrowsers, ["x", "y"])
    }

    func testLaunchAtLogin_IsMutable() {
        var settings = AppSettings()
        settings.launchAtLogin = true

        XCTAssertEqual(settings.launchAtLogin, true)
    }

    func testShowProfileLabels_IsMutable() {
        var settings = AppSettings()
        settings.showProfileLabels = false

        XCTAssertEqual(settings.showProfileLabels, false)
    }

    func testShowMenuBarIcon_IsMutable() {
        var settings = AppSettings()
        settings.showMenuBarIcon = false

        XCTAssertEqual(settings.showMenuBarIcon, false)
    }

    // MARK: - Backward Compatibility Tests

    func testDecode_WithMissingShowMenuBarIcon_UsesDefaultTrue() throws {
        // Simulate old settings JSON without showMenuBarIcon
        let oldSettingsJSON = """
        {
            "browserOrder": ["browser1"],
            "hiddenBrowsers": [],
            "launchAtLogin": false,
            "showProfileLabels": true
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(AppSettings.self, from: oldSettingsJSON)

        XCTAssertEqual(decoded.showMenuBarIcon, true)
        XCTAssertEqual(decoded.browserOrder, ["browser1"])
    }

    func testDecode_WithMissingHasCompletedFirstLaunch_UsesDefaultFalse() throws {
        // Simulate old settings JSON without hasCompletedFirstLaunch
        let oldSettingsJSON = """
        {
            "browserOrder": ["browser1"],
            "hiddenBrowsers": [],
            "launchAtLogin": false,
            "showProfileLabels": true,
            "showMenuBarIcon": true,
            "usageCount": {}
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(AppSettings.self, from: oldSettingsJSON)

        XCTAssertEqual(decoded.hasCompletedFirstLaunch, false)
    }

    func testDecode_WithMissingUsageCount_UsesEmptyDictionary() throws {
        // Simulate old settings JSON without usageCount
        let oldSettingsJSON = """
        {
            "browserOrder": ["browser1"],
            "hiddenBrowsers": [],
            "launchAtLogin": false,
            "showProfileLabels": true,
            "showMenuBarIcon": true
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(AppSettings.self, from: oldSettingsJSON)

        XCTAssertEqual(decoded.usageCount, [:])
    }

    // MARK: - Usage Count Tests

    func testUsageCount_DefaultsToEmpty() {
        let settings = AppSettings()
        XCTAssertEqual(settings.usageCount, [:])
    }

    func testGetUsageCount_ReturnsZeroForUnknownItem() {
        let settings = AppSettings()
        XCTAssertEqual(settings.getUsageCount(for: "unknown_item"), 0)
    }

    func testGetUsageCount_ReturnsStoredValue() {
        let settings = AppSettings(usageCount: ["browser1": 5, "browser2": 10])
        XCTAssertEqual(settings.getUsageCount(for: "browser1"), 5)
        XCTAssertEqual(settings.getUsageCount(for: "browser2"), 10)
    }

    func testIncrementUsageCount_IncrementsExistingValue() {
        var settings = AppSettings(usageCount: ["browser1": 5])
        settings.incrementUsageCount(for: "browser1")
        XCTAssertEqual(settings.getUsageCount(for: "browser1"), 6)
    }

    func testIncrementUsageCount_CreatesNewEntry() {
        var settings = AppSettings()
        settings.incrementUsageCount(for: "new_browser")
        XCTAssertEqual(settings.getUsageCount(for: "new_browser"), 1)
    }

    func testEncodeDecode_PreservesHasCompletedFirstLaunch() throws {
        let settings = AppSettings(hasCompletedFirstLaunch: true)

        let data = try JSONEncoder().encode(settings)
        let decoded = try JSONDecoder().decode(AppSettings.self, from: data)

        XCTAssertEqual(decoded.hasCompletedFirstLaunch, true)
    }

    func testEncodeDecode_PreservesUsageCount() throws {
        let settings = AppSettings(usageCount: ["browser1": 42, "browser2": 7])

        let data = try JSONEncoder().encode(settings)
        let decoded = try JSONDecoder().decode(AppSettings.self, from: data)

        XCTAssertEqual(decoded.usageCount, ["browser1": 42, "browser2": 7])
    }
}
