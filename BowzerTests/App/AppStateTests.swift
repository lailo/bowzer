import XCTest
@testable import Bowzer

final class AppStateTests: XCTestCase {

    var appState: AppState!
    var mockUserDefaults: MockUserDefaults!

    override func setUpWithError() throws {
        mockUserDefaults = MockUserDefaults()
        // Create AppState with injected mock settings service
        let mockSettingsService = SettingsService(userDefaults: mockUserDefaults)
        appState = AppState(settingsService: mockSettingsService)
    }

    override func tearDownWithError() throws {
        appState = nil
        mockUserDefaults = nil
    }

    // MARK: - applyBrowserOrder Tests

    func testApplyBrowserOrder_WithEmptyOrder_ReturnsItemsInDefaultOrder() {
        // Given
        appState.browsers = TestDataFactory.makeSampleBrowsers()
        appState.settings.browserOrder = []

        // When
        appState.applyBrowserOrder()

        // Then
        XCTAssertEqual(appState.orderedDisplayItems.count, 4) // Safari + Chrome (2 profiles) + Firefox
        XCTAssertEqual(appState.orderedDisplayItems[0].browser.name, "Safari")
    }

    func testApplyBrowserOrder_WithCustomOrder_ReordersItems() {
        // Given
        let safari = TestDataFactory.makeBrowser(id: "safari", name: "Safari", bundleIdentifier: "com.apple.Safari")
        let firefox = TestDataFactory.makeBrowser(id: "firefox", name: "Firefox", bundleIdentifier: "org.mozilla.firefox")
        appState.browsers = [safari, firefox]

        // Set custom order: Firefox first, then Safari
        appState.settings.browserOrder = [
            "org.mozilla.firefox_default",
            "com.apple.Safari_default"
        ]

        // When
        appState.applyBrowserOrder()

        // Then
        XCTAssertEqual(appState.orderedDisplayItems.count, 2)
        XCTAssertEqual(appState.orderedDisplayItems[0].browser.name, "Firefox")
        XCTAssertEqual(appState.orderedDisplayItems[1].browser.name, "Safari")
    }

    func testApplyBrowserOrder_WithPartialOrder_AppendsUnorderedItems() {
        // Given
        let safari = TestDataFactory.makeBrowser(id: "safari", name: "Safari", bundleIdentifier: "com.apple.Safari")
        let firefox = TestDataFactory.makeBrowser(id: "firefox", name: "Firefox", bundleIdentifier: "org.mozilla.firefox")
        let brave = TestDataFactory.makeBrowser(id: "brave", name: "Brave", bundleIdentifier: "com.brave.Browser")
        appState.browsers = [safari, firefox, brave]

        // Only specify order for Firefox
        appState.settings.browserOrder = ["org.mozilla.firefox_default"]

        // When
        appState.applyBrowserOrder()

        // Then
        XCTAssertEqual(appState.orderedDisplayItems.count, 3)
        XCTAssertEqual(appState.orderedDisplayItems[0].browser.name, "Firefox") // Ordered first
        // Safari and Brave follow in their original order
    }

    func testApplyBrowserOrder_WithStaleOrder_IgnoresMissingItems() {
        // Given
        let safari = TestDataFactory.makeBrowser(id: "safari", name: "Safari", bundleIdentifier: "com.apple.Safari")
        appState.browsers = [safari]

        // Order references a browser that doesn't exist
        appState.settings.browserOrder = [
            "com.google.Chrome_default",
            "com.apple.Safari_default"
        ]

        // When
        appState.applyBrowserOrder()

        // Then
        XCTAssertEqual(appState.orderedDisplayItems.count, 1)
        XCTAssertEqual(appState.orderedDisplayItems[0].browser.name, "Safari")
    }

    func testApplyBrowserOrder_WithMultipleProfiles_OrdersAllProfiles() {
        // Given
        let chrome = TestDataFactory.makeBrowserWithProfiles(
            id: "chrome",
            name: "Chrome",
            bundleIdentifier: "com.google.Chrome",
            profileNames: ["Personal", "Work"]
        )
        appState.browsers = [chrome]

        // When
        appState.applyBrowserOrder()

        // Then - should have 2 display items for 2 profiles
        XCTAssertEqual(appState.orderedDisplayItems.count, 2)
        XCTAssertEqual(appState.orderedDisplayItems[0].profile?.name, "Personal")
        XCTAssertEqual(appState.orderedDisplayItems[1].profile?.name, "Work")
    }

    // MARK: - moveDisplayItems Tests

    func testMoveDisplayItems_MovesItemFromSourceToDestination() {
        // Given
        let safari = TestDataFactory.makeBrowser(id: "safari", name: "Safari", bundleIdentifier: "com.apple.Safari")
        let firefox = TestDataFactory.makeBrowser(id: "firefox", name: "Firefox", bundleIdentifier: "org.mozilla.firefox")
        let brave = TestDataFactory.makeBrowser(id: "brave", name: "Brave", bundleIdentifier: "com.brave.Browser")
        appState.browsers = [safari, firefox, brave]
        appState.applyBrowserOrder()

        // Verify initial order
        XCTAssertEqual(appState.orderedDisplayItems[0].browser.name, "Safari")
        XCTAssertEqual(appState.orderedDisplayItems[1].browser.name, "Firefox")
        XCTAssertEqual(appState.orderedDisplayItems[2].browser.name, "Brave")

        // When - move Safari to the end
        appState.moveDisplayItems(from: IndexSet(integer: 0), to: 3)

        // Then
        XCTAssertEqual(appState.orderedDisplayItems[0].browser.name, "Firefox")
        XCTAssertEqual(appState.orderedDisplayItems[1].browser.name, "Brave")
        XCTAssertEqual(appState.orderedDisplayItems[2].browser.name, "Safari")
    }

    func testMoveDisplayItems_UpdatesSettingsBrowserOrder() {
        // Given
        let safari = TestDataFactory.makeBrowser(id: "safari", name: "Safari", bundleIdentifier: "com.apple.Safari")
        let firefox = TestDataFactory.makeBrowser(id: "firefox", name: "Firefox", bundleIdentifier: "org.mozilla.firefox")
        appState.browsers = [safari, firefox]
        appState.applyBrowserOrder()

        // When
        appState.moveDisplayItems(from: IndexSet(integer: 0), to: 2)

        // Then - settings should reflect the new order
        XCTAssertEqual(appState.settings.browserOrder, [
            "org.mozilla.firefox_default",
            "com.apple.Safari_default"
        ])
    }

    // MARK: - Visibility Tests

    func testSetItemVisible_HidesItem() {
        // Given
        let itemId = "com.apple.Safari_default"
        XCTAssertTrue(appState.isItemVisible(itemId))

        // When
        appState.setItemVisible(itemId, visible: false)

        // Then
        XCTAssertFalse(appState.isItemVisible(itemId))
        XCTAssertTrue(appState.settings.hiddenBrowsers.contains(itemId))
    }

    func testSetItemVisible_ShowsItem() {
        // Given
        let itemId = "com.apple.Safari_default"
        appState.settings.hiddenBrowsers = [itemId]
        XCTAssertFalse(appState.isItemVisible(itemId))

        // When
        appState.setItemVisible(itemId, visible: true)

        // Then
        XCTAssertTrue(appState.isItemVisible(itemId))
        XCTAssertFalse(appState.settings.hiddenBrowsers.contains(itemId))
    }

    func testIsItemVisible_ReturnsTrueWhenNotHidden() {
        // Given
        let itemId = "com.apple.Safari_default"
        appState.settings.hiddenBrowsers = []

        // Then
        XCTAssertTrue(appState.isItemVisible(itemId))
    }

    func testIsItemVisible_ReturnsFalseWhenHidden() {
        // Given
        let itemId = "com.apple.Safari_default"
        appState.settings.hiddenBrowsers = [itemId]

        // Then
        XCTAssertFalse(appState.isItemVisible(itemId))
    }

    // MARK: - saveDisplayItemOrder Tests

    func testSaveDisplayItemOrder_UpdatesSettingsBrowserOrder() {
        // Given
        let safari = TestDataFactory.makeBrowser(id: "safari", name: "Safari", bundleIdentifier: "com.apple.Safari")
        let firefox = TestDataFactory.makeBrowser(id: "firefox", name: "Firefox", bundleIdentifier: "org.mozilla.firefox")
        appState.browsers = [safari, firefox]
        appState.applyBrowserOrder()

        // Manually reorder
        appState.orderedDisplayItems.reverse()

        // When
        appState.saveDisplayItemOrder()

        // Then
        XCTAssertEqual(appState.settings.browserOrder, [
            "org.mozilla.firefox_default",
            "com.apple.Safari_default"
        ])
    }

    // MARK: - Dependency Injection Tests

    func testInit_AcceptsDependencyInjection() {
        // Given - create AppState with injected services
        let mockSettings = SettingsService(userDefaults: MockUserDefaults())
        let newAppState = AppState(settingsService: mockSettings)

        // Then - AppState should be created successfully
        XCTAssertNotNil(newAppState)
    }
}
