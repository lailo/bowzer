import XCTest
import AppKit
@testable import Bowzer

final class BrowserTests: XCTestCase {

    // MARK: - Helper Methods

    private func createBrowser(
        id: String = "test",
        name: String = "Test Browser",
        bundleIdentifier: String = "com.test.browser",
        profiles: [BrowserProfile] = []
    ) -> Browser {
        return Browser(
            id: id,
            name: name,
            bundleIdentifier: bundleIdentifier,
            path: URL(fileURLWithPath: "/Applications/Test.app"),
            icon: NSImage(),
            profiles: profiles
        )
    }

    // MARK: - Display Items Tests

    func testDisplayItems_WithNoProfiles_ReturnsSingleItem() {
        let browser = createBrowser(profiles: [])

        let items = browser.displayItems

        XCTAssertEqual(items.count, 1)
        XCTAssertNil(items[0].profile)
    }

    func testDisplayItems_WithOneProfile_ReturnsSingleItem() {
        let profile = BrowserProfile(id: "p1", name: "Default", directoryName: "Default")
        let browser = createBrowser(profiles: [profile])

        let items = browser.displayItems

        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items[0].profile?.name, "Default")
    }

    func testDisplayItems_WithMultipleProfiles_ReturnsMultipleItems() {
        let profiles = [
            BrowserProfile(id: "p1", name: "Personal", directoryName: "Default"),
            BrowserProfile(id: "p2", name: "Work", directoryName: "Profile 1"),
            BrowserProfile(id: "p3", name: "Gaming", directoryName: "Profile 2")
        ]
        let browser = createBrowser(profiles: profiles)

        let items = browser.displayItems

        XCTAssertEqual(items.count, 3)
        XCTAssertEqual(items[0].profile?.name, "Personal")
        XCTAssertEqual(items[1].profile?.name, "Work")
        XCTAssertEqual(items[2].profile?.name, "Gaming")
    }

    // MARK: - Equality Tests

    func testEquality_SameBundleIdentifier_AreEqual() {
        let browser1 = createBrowser(id: "1", name: "Chrome", bundleIdentifier: "com.google.Chrome")
        let browser2 = createBrowser(id: "2", name: "Google Chrome", bundleIdentifier: "com.google.Chrome")

        XCTAssertEqual(browser1, browser2)
    }

    func testEquality_DifferentBundleIdentifier_AreNotEqual() {
        let browser1 = createBrowser(bundleIdentifier: "com.google.Chrome")
        let browser2 = createBrowser(bundleIdentifier: "com.apple.Safari")

        XCTAssertNotEqual(browser1, browser2)
    }

    // MARK: - BrowserDisplayItem Tests

    func testBrowserDisplayItem_IdFormat_WithoutProfile() {
        let browser = createBrowser(bundleIdentifier: "com.apple.Safari")
        let item = BrowserDisplayItem(browser: browser, profile: nil)

        XCTAssertEqual(item.id, "com.apple.Safari_default")
    }

    func testBrowserDisplayItem_IdFormat_WithProfile() {
        let profile = BrowserProfile(id: "chrome_Default", name: "Personal", directoryName: "Default")
        let browser = createBrowser(bundleIdentifier: "com.google.Chrome", profiles: [profile])
        let item = BrowserDisplayItem(browser: browser, profile: profile)

        XCTAssertEqual(item.id, "com.google.Chrome_chrome_Default")
    }

    func testBrowserDisplayItem_DisplayName_WithoutProfile() {
        let browser = createBrowser(name: "Safari", bundleIdentifier: "com.apple.Safari")
        let item = BrowserDisplayItem(browser: browser, profile: nil)

        XCTAssertEqual(item.displayName, "Safari")
    }

    func testBrowserDisplayItem_DisplayName_WithProfile() {
        let profile = BrowserProfile(id: "p1", name: "Work Account", directoryName: "Profile 1")
        let browser = createBrowser(name: "Chrome", profiles: [profile])
        let item = BrowserDisplayItem(browser: browser, profile: profile)

        XCTAssertEqual(item.displayName, "Work Account")
    }

    func testBrowserDisplayItem_ShowProfileLabel_NoProfile() {
        let browser = createBrowser()
        let item = BrowserDisplayItem(browser: browser, profile: nil)

        XCTAssertFalse(item.showProfileLabel)
    }

    func testBrowserDisplayItem_ShowProfileLabel_SingleProfile() {
        let profile = BrowserProfile(id: "p1", name: "Default", directoryName: "Default")
        let browser = createBrowser(profiles: [profile])
        let item = BrowserDisplayItem(browser: browser, profile: profile)

        XCTAssertFalse(item.showProfileLabel)
    }

    func testBrowserDisplayItem_ShowProfileLabel_MultipleProfiles() {
        let profiles = [
            BrowserProfile(id: "p1", name: "Personal", directoryName: "Default"),
            BrowserProfile(id: "p2", name: "Work", directoryName: "Profile 1")
        ]
        let browser = createBrowser(profiles: profiles)
        let item = BrowserDisplayItem(browser: browser, profile: profiles[0])

        XCTAssertTrue(item.showProfileLabel)
    }

    // MARK: - BrowserType Tests

    func testBrowserType_ProfileType_Safari() {
        XCTAssertEqual(BrowserType.safari.profileType, .none)
    }

    func testBrowserType_ProfileType_Chrome() {
        XCTAssertEqual(BrowserType.chrome.profileType, .chromium)
    }

    func testBrowserType_ProfileType_Edge() {
        XCTAssertEqual(BrowserType.edge.profileType, .chromium)
    }

    func testBrowserType_ProfileType_Brave() {
        XCTAssertEqual(BrowserType.brave.profileType, .chromium)
    }

    func testBrowserType_ProfileType_Firefox() {
        XCTAssertEqual(BrowserType.firefox.profileType, .firefox)
    }

    func testBrowserType_ProfileType_Arc() {
        XCTAssertEqual(BrowserType.arc.profileType, .none)
    }

    func testBrowserType_ApplicationSupportFolder_Chrome() {
        XCTAssertEqual(BrowserType.chrome.applicationSupportFolder, "Google/Chrome")
    }

    func testBrowserType_ApplicationSupportFolder_Edge() {
        XCTAssertEqual(BrowserType.edge.applicationSupportFolder, "Microsoft Edge")
    }

    func testBrowserType_ApplicationSupportFolder_Brave() {
        XCTAssertEqual(BrowserType.brave.applicationSupportFolder, "BraveSoftware/Brave-Browser")
    }

    func testBrowserType_ApplicationSupportFolder_Firefox() {
        XCTAssertEqual(BrowserType.firefox.applicationSupportFolder, "Firefox")
    }

    func testBrowserType_ApplicationSupportFolder_Safari() {
        XCTAssertNil(BrowserType.safari.applicationSupportFolder)
    }
}
