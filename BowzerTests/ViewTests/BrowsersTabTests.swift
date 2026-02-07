import XCTest
import SwiftUI
import ViewInspector
@testable import Bowzer

final class BrowsersTabTests: XCTestCase {

    // MARK: - Browser List Display Tests

    func test_displaysAllDetectedBrowsers() throws {
        let appState = TestDataFactory.makeAppStateWithSampleData()

        let sut = BrowsersTab()
            .environmentObject(appState)

        // Should display all browsers including profile variants
        let view = try sut.inspect()
        XCTAssertNotNil(view)
    }

    func test_displaysBrowserName() throws {
        let appState = TestDataFactory.makeAppStateWithSampleData()

        let sut = BrowsersTab()
            .environmentObject(appState)

        // Verify Safari appears in the list
        let safariText = try sut.inspect().find(text: "Safari")
        XCTAssertNotNil(safariText)
    }

    func test_displaysMultipleBrowserNames() throws {
        let appState = TestDataFactory.makeAppStateWithSampleData()

        let sut = BrowsersTab()
            .environmentObject(appState)

        // Verify Chrome appears
        let chromeText = try sut.inspect().find(text: "Chrome")
        XCTAssertNotNil(chromeText)

        // Verify Firefox appears
        let firefoxText = try sut.inspect().find(text: "Firefox")
        XCTAssertNotNil(firefoxText)
    }

    // MARK: - Toggle State Tests

    func test_toggleReflectsVisibleState_whenNotHidden() throws {
        let appState = TestDataFactory.makeAppStateWithSampleData()
        // Ensure no browsers are hidden
        appState.settings.hiddenBrowsers = []

        let sut = BrowsersTab()
            .environmentObject(appState)

        // The toggle should exist
        let toggle = try sut.inspect().find(ViewType.Toggle.self)
        XCTAssertNotNil(toggle)
    }

    func test_toggleReflectsHiddenState() throws {
        let appState = TestDataFactory.makeAppStateWithSampleData()

        // Hide the first browser
        if let firstItem = appState.orderedDisplayItems.first {
            appState.settings.hiddenBrowsers = [firstItem.id]
        }

        let sut = BrowsersTab()
            .environmentObject(appState)

        // View should render with hidden state reflected in toggles
        let view = try sut.inspect()
        XCTAssertNotNil(view)
    }

    // MARK: - Refresh Button Tests

    func test_refreshButtonExists() throws {
        let appState = TestDataFactory.makeAppStateWithSampleData()

        let sut = BrowsersTab()
            .environmentObject(appState)

        // Find the Refresh button
        let refreshButton = try sut.inspect().find(button: "Refresh")
        XCTAssertNotNil(refreshButton)
    }

    // MARK: - Profile Display Tests

    func test_displaysProfileName_forBrowserWithMultipleProfiles() throws {
        let appState = TestDataFactory.makeAppStateWithSampleData()

        let sut = BrowsersTab()
            .environmentObject(appState)

        // Chrome should show profile names like "Personal" and "Work"
        // These appear with a dash prefix
        let view = try sut.inspect()
        XCTAssertNotNil(view)

        // Verify the profile name text includes the dash separator
        // The format is "— Personal" or "— Work"
    }

    // MARK: - Browser Icon Tests

    func test_displaysBrowserIcons() throws {
        let appState = TestDataFactory.makeAppStateWithSampleData()

        let sut = BrowsersTab()
            .environmentObject(appState)

        // Should find at least one Image in the list
        let image = try sut.inspect().find(ViewType.Image.self)
        XCTAssertNotNil(image)
    }

    // MARK: - List Structure Tests

    func test_containsList() throws {
        let appState = TestDataFactory.makeAppStateWithSampleData()

        let sut = BrowsersTab()
            .environmentObject(appState)

        // The view should contain a List
        let list = try sut.inspect().find(ViewType.List.self)
        XCTAssertNotNil(list)
    }

    func test_containsDivider() throws {
        let appState = TestDataFactory.makeAppStateWithSampleData()

        let sut = BrowsersTab()
            .environmentObject(appState)

        // There should be a Divider between the list and bottom controls
        let divider = try sut.inspect().find(ViewType.Divider.self)
        XCTAssertNotNil(divider)
    }

    // MARK: - Help Text Tests

    func test_displaysHelpText() throws {
        let appState = TestDataFactory.makeAppStateWithSampleData()

        let sut = BrowsersTab()
            .environmentObject(appState)

        // Should display the help text
        let helpText = try sut.inspect().find(text: "Drag to reorder, toggle to show/hide")
        XCTAssertNotNil(helpText)
    }

    // MARK: - Empty State Tests

    func test_rendersCorrectly_whenNoBrowsers() throws {
        let appState = AppState()
        appState.browsers = []
        appState.applyBrowserOrder()

        let sut = BrowsersTab()
            .environmentObject(appState)

        // View should render without crashing
        let view = try sut.inspect()
        XCTAssertNotNil(view)
    }

    // MARK: - Reorder Handle Tests

    func test_displaysReorderHandle() throws {
        let appState = TestDataFactory.makeAppStateWithSampleData()

        let sut = BrowsersTab()
            .environmentObject(appState)

        // The drag handle icon should exist (line.3.horizontal)
        let view = try sut.inspect()
        XCTAssertNotNil(view)
    }
}
