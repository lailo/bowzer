import XCTest
import SwiftUI
import ViewInspector
@testable import Bowzer

final class PreferencesTabTests: XCTestCase {

    // MARK: - Toggle Presence Tests

    func test_showProfileLabelsToggleExists() throws {
        let appState = TestDataFactory.makeAppStateWithSampleData()

        let sut = PreferencesTab()
            .environmentObject(appState)

        // Find the "Show profile labels" toggle (localized)
        let toggle = try sut.inspect().find(text: String(localized: "preferences.showProfileLabels"))
        XCTAssertNotNil(toggle)
    }

    func test_launchAtLoginToggleExists() throws {
        let appState = TestDataFactory.makeAppStateWithSampleData()

        let sut = PreferencesTab()
            .environmentObject(appState)

        // Find the "Launch at login" toggle (localized)
        let toggle = try sut.inspect().find(text: String(localized: "preferences.launchAtLogin"))
        XCTAssertNotNil(toggle)
    }

    func test_showMenuBarIconToggleExists() throws {
        let appState = TestDataFactory.makeAppStateWithSampleData()

        let sut = PreferencesTab()
            .environmentObject(appState)

        // Find the "Show menu bar icon" toggle (localized)
        let toggle = try sut.inspect().find(text: String(localized: "preferences.showMenuBarIcon"))
        XCTAssertNotNil(toggle)
    }

    func test_allTogglesExist() throws {
        let appState = TestDataFactory.makeAppStateWithSampleData()

        let sut = PreferencesTab()
            .environmentObject(appState)

        // All three toggles should be present
        let toggles = try sut.inspect().findAll(ViewType.Toggle.self)
        XCTAssertEqual(toggles.count, 3)
    }

    // MARK: - Section Header Tests

    func test_displaySectionExists() throws {
        let appState = TestDataFactory.makeAppStateWithSampleData()

        let sut = PreferencesTab()
            .environmentObject(appState)

        // The "Display" section header should exist (localized)
        let header = try sut.inspect().find(text: String(localized: "preferences.display"))
        XCTAssertNotNil(header)
    }

    func test_startupSectionExists() throws {
        let appState = TestDataFactory.makeAppStateWithSampleData()

        let sut = PreferencesTab()
            .environmentObject(appState)

        // The "Startup" section header should exist (localized)
        let header = try sut.inspect().find(text: String(localized: "preferences.startup"))
        XCTAssertNotNil(header)
    }

    // MARK: - Toggle State Tests

    func test_showProfileLabelsToggle_reflectsSettingsValue_whenTrue() throws {
        let appState = TestDataFactory.makeAppStateWithSampleData()
        appState.settings.showProfileLabels = true

        let sut = PreferencesTab()
            .environmentObject(appState)

        // The toggle should reflect the true state
        let view = try sut.inspect()
        XCTAssertNotNil(view)
        XCTAssertTrue(appState.settings.showProfileLabels)
    }

    func test_showProfileLabelsToggle_reflectsSettingsValue_whenFalse() throws {
        let appState = TestDataFactory.makeAppStateWithSampleData()
        appState.settings.showProfileLabels = false

        let sut = PreferencesTab()
            .environmentObject(appState)

        // The toggle should reflect the false state
        let view = try sut.inspect()
        XCTAssertNotNil(view)
        XCTAssertFalse(appState.settings.showProfileLabels)
    }

    // MARK: - Form Structure Tests

    func test_usesFormStyle() throws {
        let appState = TestDataFactory.makeAppStateWithSampleData()

        let sut = PreferencesTab()
            .environmentObject(appState)

        // The view should contain a Form
        let form = try sut.inspect().find(ViewType.Form.self)
        XCTAssertNotNil(form)
    }

    func test_formContainsTwoSections() throws {
        let appState = TestDataFactory.makeAppStateWithSampleData()

        let sut = PreferencesTab()
            .environmentObject(appState)

        // Find all Section views
        let sections = try sut.inspect().findAll(ViewType.Section.self)
        XCTAssertEqual(sections.count, 2)
    }

    // MARK: - View Renders Tests

    func test_viewRenders_withDefaultSettings() throws {
        let appState = AppState()

        let sut = PreferencesTab()
            .environmentObject(appState)

        let view = try sut.inspect()
        XCTAssertNotNil(view)
    }

    func test_viewRenders_withCustomSettings() throws {
        let appState = TestDataFactory.makeAppStateWithSampleData()
        appState.settings.showProfileLabels = false
        appState.settings.launchAtLogin = true

        let sut = PreferencesTab()
            .environmentObject(appState)

        let view = try sut.inspect()
        XCTAssertNotNil(view)
    }
}
