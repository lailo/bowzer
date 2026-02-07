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
    }

    func testEncodeDecode_PopulatedSettings() throws {
        let settings = AppSettings(
            browserOrder: ["browser1", "browser2", "browser3"],
            hiddenBrowsers: ["browser4", "browser5"],
            launchAtLogin: true,
            showProfileLabels: false,
            showMenuBarIcon: false
        )

        let data = try JSONEncoder().encode(settings)
        let decoded = try JSONDecoder().decode(AppSettings.self, from: data)

        XCTAssertEqual(decoded.browserOrder, ["browser1", "browser2", "browser3"])
        XCTAssertEqual(decoded.hiddenBrowsers, ["browser4", "browser5"])
        XCTAssertEqual(decoded.launchAtLogin, true)
        XCTAssertEqual(decoded.showProfileLabels, false)
        XCTAssertEqual(decoded.showMenuBarIcon, false)
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
}
