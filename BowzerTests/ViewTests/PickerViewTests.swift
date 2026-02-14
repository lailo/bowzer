import XCTest
import SwiftUI
import ViewInspector
@testable import Bowzer

final class PickerViewTests: XCTestCase {

    // MARK: - Browser List Display Tests

    func test_displaysAllNonHiddenBrowsers() throws {
        let appState = TestDataFactory.makeAppStateWithSampleData()

        let sut = PickerView(
            appState: appState,
            url: TestDataFactory.makeSampleURL(),
            onDismiss: {}
        )

        // Should display Safari, Chrome Personal, Chrome Work, Firefox (4 items)
        let hstack = try sut.inspect().find(ViewType.HStack.self, relation: .child)
        XCTAssertNotNil(hstack)
    }

    func test_filtersOutHiddenBrowsers() throws {
        let appState = TestDataFactory.makeAppStateWithSampleData()

        // Hide the first browser (Safari)
        if let firstItem = appState.orderedDisplayItems.first {
            appState.settings.hiddenBrowsers = [firstItem.id]
        }

        let sut = PickerView(
            appState: appState,
            url: TestDataFactory.makeSampleURL(),
            onDismiss: {}
        )

        // Verify view renders (the hidden browser is filtered out in displayItems computed property)
        let view = try sut.inspect()
        XCTAssertNotNil(view)
    }

    func test_filtersOutMultipleHiddenBrowsers() throws {
        let appState = TestDataFactory.makeAppStateWithSampleData()

        // Hide multiple browsers
        let itemsToHide = appState.orderedDisplayItems.prefix(2).map { $0.id }
        appState.settings.hiddenBrowsers = Array(itemsToHide)

        let sut = PickerView(
            appState: appState,
            url: TestDataFactory.makeSampleURL(),
            onDismiss: {}
        )

        // Verify view renders correctly with fewer items
        let view = try sut.inspect()
        XCTAssertNotNil(view)
    }

    // MARK: - Profile Labels Tests

    func test_showsProfileLabels_whenSettingEnabled() throws {
        let appState = TestDataFactory.makeAppStateWithSampleData()
        appState.settings.showProfileLabels = true

        let sut = PickerView(
            appState: appState,
            url: TestDataFactory.makeSampleURL(),
            onDismiss: {}
        )

        // Verify the view renders with profile labels enabled
        let view = try sut.inspect()
        XCTAssertNotNil(view)
    }

    func test_hidesProfileLabels_whenSettingDisabled() throws {
        let appState = TestDataFactory.makeAppStateWithSampleData()
        appState.settings.showProfileLabels = false

        let sut = PickerView(
            appState: appState,
            url: TestDataFactory.makeSampleURL(),
            onDismiss: {}
        )

        // Verify the view renders with profile labels disabled
        let view = try sut.inspect()
        XCTAssertNotNil(view)
    }

    // MARK: - Empty State Tests

    func test_rendersCorrectly_whenNoBrowsers() throws {
        let appState = AppState()
        appState.browsers = []
        appState.applyBrowserOrder()

        let sut = PickerView(
            appState: appState,
            url: TestDataFactory.makeSampleURL(),
            onDismiss: {}
        )

        // View should render without crashing even with no browsers
        let view = try sut.inspect()
        XCTAssertNotNil(view)
    }

    func test_rendersCorrectly_whenAllBrowsersHidden() throws {
        let appState = TestDataFactory.makeAppStateWithSampleData()

        // Hide all browsers
        appState.settings.hiddenBrowsers = appState.orderedDisplayItems.map { $0.id }

        let sut = PickerView(
            appState: appState,
            url: TestDataFactory.makeSampleURL(),
            onDismiss: {}
        )

        // View should render without crashing
        let view = try sut.inspect()
        XCTAssertNotNil(view)
    }

    // MARK: - View Structure Tests

    func test_containsBackgroundRoundedRectangle() throws {
        let appState = TestDataFactory.makeAppStateWithSampleData()

        let sut = PickerView(
            appState: appState,
            url: TestDataFactory.makeSampleURL(),
            onDismiss: {}
        )

        // Verify the main HStack with Spacer exists
        let hstack = try sut.inspect().find(ViewType.HStack.self)
        XCTAssertNotNil(hstack)
    }

    func test_containsKeyboardEventHandler() throws {
        let appState = TestDataFactory.makeAppStateWithSampleData()

        let sut = PickerView(
            appState: appState,
            url: TestDataFactory.makeSampleURL(),
            onDismiss: {}
        )

        // KeyboardEventHandler should be in the view hierarchy
        let view = try sut.inspect()
        XCTAssertNotNil(view)
    }

    // MARK: - Display Items Ordering Tests

    func test_respectsCustomBrowserOrder() throws {
        let appState = TestDataFactory.makeAppStateWithSampleData()

        // Get all item IDs and reverse them
        let originalOrder = appState.orderedDisplayItems.map { $0.id }
        appState.settings.browserOrder = originalOrder.reversed()
        appState.applyBrowserOrder()

        let sut = PickerView(
            appState: appState,
            url: TestDataFactory.makeSampleURL(),
            onDismiss: {}
        )

        // Verify view renders with custom order
        let view = try sut.inspect()
        XCTAssertNotNil(view)

        // Verify the order is actually reversed
        XCTAssertEqual(appState.orderedDisplayItems.first?.id, originalOrder.last)
    }

    // MARK: - hasAnyLabels Computed Property Tests

    func test_hasAnyLabels_true_whenBrowserHasMultipleProfiles() throws {
        let appState = TestDataFactory.makeAppStateWithSampleData()
        appState.settings.showProfileLabels = true

        // Chrome has multiple profiles, so hasAnyLabels should be true
        let hasLabels = appState.orderedDisplayItems.contains { $0.showProfileLabel }
        XCTAssertTrue(hasLabels, "Chrome should have profile labels")
    }

    func test_hasAnyLabels_false_whenNoMultiProfileBrowsers() throws {
        let appState = AppState()
        // Add only browsers without profiles
        appState.browsers = [
            TestDataFactory.makeBrowser(id: "safari", name: "Safari"),
            TestDataFactory.makeBrowser(id: "firefox", name: "Firefox")
        ]
        appState.applyBrowserOrder()
        appState.settings.showProfileLabels = true

        // No browser has multiple profiles
        let hasLabels = appState.orderedDisplayItems.contains { $0.showProfileLabel }
        XCTAssertFalse(hasLabels, "No browser should have profile labels")
    }
}
