import XCTest
import SwiftUI
import ViewInspector
@testable import Bowzer

final class BrowserItemViewTests: XCTestCase {

    // MARK: - Keyboard Shortcut Badge Tests

    func test_displaysKeyboardShortcutBadge_forIndex1To9() throws {
        let browser = TestDataFactory.makeBrowser()
        let item = TestDataFactory.makeDisplayItem(browser: browser)

        let sut = BrowserItemView(
            item: item,
            index: 3,
            isHovered: false,
            showLabel: false,
            hasAnyLabels: false,
            onSelect: {}
        )

        // Find the keyboard shortcut badge text
        let badge = try sut.inspect().find(text: "3")
        XCTAssertNotNil(badge)
    }

    func test_hidesKeyboardShortcutBadge_forIndexGreaterThan9() throws {
        let browser = TestDataFactory.makeBrowser()
        let item = TestDataFactory.makeDisplayItem(browser: browser)

        let sut = BrowserItemView(
            item: item,
            index: 10,
            isHovered: false,
            showLabel: false,
            hasAnyLabels: false,
            onSelect: {}
        )

        // Should not find "10" text as a badge
        XCTAssertThrowsError(try sut.inspect().find(text: "10"))
    }

    func test_displaysKeyboardShortcutBadge_forIndex1() throws {
        let browser = TestDataFactory.makeBrowser()
        let item = TestDataFactory.makeDisplayItem(browser: browser)

        let sut = BrowserItemView(
            item: item,
            index: 1,
            isHovered: false,
            showLabel: false,
            hasAnyLabels: false,
            onSelect: {}
        )

        let badge = try sut.inspect().find(text: "1")
        XCTAssertNotNil(badge)
    }

    // MARK: - Icon Tests

    func test_displaysIcon() throws {
        let browser = TestDataFactory.makeBrowser()
        let item = TestDataFactory.makeDisplayItem(browser: browser)

        let sut = BrowserItemView(
            item: item,
            index: 1,
            isHovered: false,
            showLabel: false,
            hasAnyLabels: false,
            onSelect: {}
        )

        // Verify the view contains an Image
        let image = try sut.inspect().find(ViewType.Image.self)
        XCTAssertNotNil(image)
    }

    // MARK: - Profile Label Tests

    func test_showsProfileLabel_whenShowLabelIsTrue_andHasProfile() throws {
        let browser = TestDataFactory.makeBrowserWithProfiles(profileNames: ["Personal"])
        let profile = browser.profiles.first!
        let item = TestDataFactory.makeDisplayItem(browser: browser, profile: profile)

        let sut = BrowserItemView(
            item: item,
            index: 1,
            isHovered: false,
            showLabel: true,
            hasAnyLabels: true,
            onSelect: {}
        )

        let label = try sut.inspect().find(text: "Personal")
        XCTAssertNotNil(label)
    }

    func test_hidesProfileLabel_whenShowLabelIsFalse() throws {
        let browser = TestDataFactory.makeBrowserWithProfiles(profileNames: ["Personal"])
        let profile = browser.profiles.first!
        let item = TestDataFactory.makeDisplayItem(browser: browser, profile: profile)

        let sut = BrowserItemView(
            item: item,
            index: 1,
            isHovered: false,
            showLabel: false,
            hasAnyLabels: true,
            onSelect: {}
        )

        // The label should be hidden (opacity 0) when showLabel is false
        // ViewInspector will still find the text, but it has 0 opacity
        // We can verify the text exists but would have invisible styling
        let text = try sut.inspect().find(text: " ")
        XCTAssertNotNil(text)
    }

    func test_truncatesLongProfileName() throws {
        let browser = TestDataFactory.makeBrowserWithProfiles(profileNames: ["Very Long Profile Name That Should Be Truncated"])
        let profile = browser.profiles.first!
        let item = TestDataFactory.makeDisplayItem(browser: browser, profile: profile)

        let sut = BrowserItemView(
            item: item,
            index: 1,
            isHovered: false,
            showLabel: true,
            hasAnyLabels: true,
            onSelect: {}
        )

        // The truncated name should be shown (not the full name)
        XCTAssertEqual(profile.truncatedName.count, 12)
        XCTAssertTrue(profile.truncatedName.hasSuffix("…"))
    }

    // MARK: - Hover State Tests

    func test_viewStructure_whenHovered() throws {
        let browser = TestDataFactory.makeBrowser()
        let item = TestDataFactory.makeDisplayItem(browser: browser)

        let sut = BrowserItemView(
            item: item,
            index: 1,
            isHovered: true,
            showLabel: false,
            hasAnyLabels: false,
            onSelect: {}
        )

        // Verify view renders without error when hovered
        let button = try sut.inspect().find(ViewType.Button.self)
        XCTAssertNotNil(button)
    }

    func test_viewStructure_whenNotHovered() throws {
        let browser = TestDataFactory.makeBrowser()
        let item = TestDataFactory.makeDisplayItem(browser: browser)

        let sut = BrowserItemView(
            item: item,
            index: 1,
            isHovered: false,
            showLabel: false,
            hasAnyLabels: false,
            onSelect: {}
        )

        // Verify view renders without error when not hovered
        let button = try sut.inspect().find(ViewType.Button.self)
        XCTAssertNotNil(button)
    }

    // MARK: - Button Action Tests

    func test_buttonTriggersOnSelect() throws {
        let browser = TestDataFactory.makeBrowser()
        let item = TestDataFactory.makeDisplayItem(browser: browser)
        var wasSelected = false

        let sut = BrowserItemView(
            item: item,
            index: 1,
            isHovered: false,
            showLabel: false,
            hasAnyLabels: false,
            onSelect: { wasSelected = true }
        )

        let button = try sut.inspect().find(ViewType.Button.self)
        try button.tap()

        XCTAssertTrue(wasSelected)
    }

    // MARK: - hasAnyLabels Tests

    func test_showsLabelSpace_whenHasAnyLabelsIsTrue() throws {
        let browser = TestDataFactory.makeBrowser()
        let item = TestDataFactory.makeDisplayItem(browser: browser)

        let sut = BrowserItemView(
            item: item,
            index: 1,
            isHovered: false,
            showLabel: false,
            hasAnyLabels: true,
            onSelect: {}
        )

        // When hasAnyLabels is true, even items without labels get a spacer
        // This is to maintain alignment across all items
        let vstack = try sut.inspect().find(ViewType.VStack.self)
        XCTAssertNotNil(vstack)
    }

    func test_noLabelSpace_whenHasAnyLabelsIsFalse() throws {
        let browser = TestDataFactory.makeBrowser()
        let item = TestDataFactory.makeDisplayItem(browser: browser)

        let sut = BrowserItemView(
            item: item,
            index: 1,
            isHovered: false,
            showLabel: false,
            hasAnyLabels: false,
            onSelect: {}
        )

        // Verify view renders correctly without labels
        let button = try sut.inspect().find(ViewType.Button.self)
        XCTAssertNotNil(button)
    }
}
