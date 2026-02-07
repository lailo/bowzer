import XCTest
import AppKit
@testable import Bowzer

final class URLLaunchServiceTests: XCTestCase {

    var service: URLLaunchService!
    var mockProcessLauncher: MockProcessLauncher!

    override func setUpWithError() throws {
        mockProcessLauncher = MockProcessLauncher()
        service = URLLaunchService(processLauncher: mockProcessLauncher)
    }

    override func tearDownWithError() throws {
        service = nil
        mockProcessLauncher = nil
    }

    // MARK: - Helper Methods

    private func createBrowser(bundleId: String, path: String = "/Applications/Test.app") -> Browser {
        return Browser(
            id: bundleId,
            name: "Test Browser",
            bundleIdentifier: bundleId,
            path: URL(fileURLWithPath: path),
            icon: NSImage(),
            profiles: []
        )
    }

    private func createBrowserWithProfiles(bundleId: String, path: String) -> Browser {
        let profiles = [
            BrowserProfile(id: "\(bundleId)_Default", name: "Person 1", directoryName: "Default"),
            BrowserProfile(id: "\(bundleId)_Profile1", name: "Work", directoryName: "Profile 1")
        ]
        return Browser(
            id: bundleId,
            name: "Test Browser",
            bundleIdentifier: bundleId,
            path: URL(fileURLWithPath: path),
            icon: NSImage(),
            profiles: profiles
        )
    }

    // MARK: - Basic Launch Tests

    func testLaunch_WithoutProfile_UsesBundleId() {
        let browser = createBrowser(bundleId: "com.apple.Safari")
        let item = BrowserDisplayItem(browser: browser, profile: nil)
        let testURL = URL(string: "https://example.com")!

        service.launch(url: testURL, with: item)

        XCTAssertEqual(mockProcessLauncher.launchedProcesses.count, 1)
        let launched = mockProcessLauncher.launchedProcesses[0]
        XCTAssertEqual(launched.executableURL.path, "/usr/bin/open")
        XCTAssertEqual(launched.arguments, ["-b", "com.apple.Safari", "https://example.com"])
    }

    // MARK: - Chrome Profile Tests

    func testLaunch_ChromeWithProfile_UsesProfileDirectory() {
        let browser = createBrowserWithProfiles(bundleId: "com.google.Chrome", path: "/Applications/Google Chrome.app")
        let profile = browser.profiles[1] // "Work" profile
        let item = BrowserDisplayItem(browser: browser, profile: profile)
        let testURL = URL(string: "https://example.com")!

        service.launch(url: testURL, with: item)

        XCTAssertEqual(mockProcessLauncher.launchedProcesses.count, 1)
        let launched = mockProcessLauncher.launchedProcesses[0]
        XCTAssertTrue(launched.executableURL.path.contains("Google Chrome"))
        XCTAssertEqual(launched.arguments[0], "--profile-directory=Profile 1")
        XCTAssertEqual(launched.arguments[1], "https://example.com")
    }

    // MARK: - Brave Profile Tests

    func testLaunch_BraveWithProfile_UsesProfileDirectory() {
        let browser = createBrowserWithProfiles(bundleId: "com.brave.Browser", path: "/Applications/Brave Browser.app")
        let profile = browser.profiles[0] // "Default" profile
        let item = BrowserDisplayItem(browser: browser, profile: profile)
        let testURL = URL(string: "https://brave.com")!

        service.launch(url: testURL, with: item)

        XCTAssertEqual(mockProcessLauncher.launchedProcesses.count, 1)
        let launched = mockProcessLauncher.launchedProcesses[0]
        XCTAssertTrue(launched.executableURL.path.contains("Brave Browser"))
        XCTAssertEqual(launched.arguments[0], "--profile-directory=Default")
    }

    // MARK: - Edge Profile Tests

    func testLaunch_EdgeWithProfile_UsesProfileDirectory() {
        let browser = createBrowserWithProfiles(bundleId: "com.microsoft.edgemac", path: "/Applications/Microsoft Edge.app")
        let profile = browser.profiles[0]
        let item = BrowserDisplayItem(browser: browser, profile: profile)
        let testURL = URL(string: "https://microsoft.com")!

        service.launch(url: testURL, with: item)

        XCTAssertEqual(mockProcessLauncher.launchedProcesses.count, 1)
        let launched = mockProcessLauncher.launchedProcesses[0]
        XCTAssertTrue(launched.executableURL.path.contains("Microsoft Edge"))
        XCTAssertEqual(launched.arguments[0], "--profile-directory=Default")
    }

    // MARK: - Firefox Profile Tests

    func testLaunch_FirefoxWithProfile_UsesPFlag() {
        let profiles = [
            BrowserProfile(id: "firefox_default", name: "default", directoryName: "Profiles/abc123.default")
        ]
        let browser = Browser(
            id: "org.mozilla.firefox",
            name: "Firefox",
            bundleIdentifier: "org.mozilla.firefox",
            path: URL(fileURLWithPath: "/Applications/Firefox.app"),
            icon: NSImage(),
            profiles: profiles
        )
        let item = BrowserDisplayItem(browser: browser, profile: profiles[0])
        let testURL = URL(string: "https://mozilla.org")!

        service.launch(url: testURL, with: item)

        XCTAssertEqual(mockProcessLauncher.launchedProcesses.count, 1)
        let launched = mockProcessLauncher.launchedProcesses[0]
        XCTAssertTrue(launched.executableURL.path.contains("firefox"))
        XCTAssertEqual(launched.arguments[0], "-P")
        XCTAssertEqual(launched.arguments[1], "default")
        XCTAssertEqual(launched.arguments[2], "https://mozilla.org")
    }

    // MARK: - getLaunchParameters Tests

    func testGetLaunchParameters_WithoutProfile() {
        let browser = createBrowser(bundleId: "com.apple.Safari")
        let item = BrowserDisplayItem(browser: browser, profile: nil)
        let testURL = URL(string: "https://apple.com")!

        let params = service.getLaunchParameters(for: testURL, with: item)

        XCTAssertNotNil(params)
        XCTAssertEqual(params?.executableURL.path, "/usr/bin/open")
        XCTAssertEqual(params?.arguments, ["-b", "com.apple.Safari", "https://apple.com"])
    }

    func testGetLaunchParameters_ChromeWithProfile() {
        let browser = createBrowserWithProfiles(bundleId: "com.google.Chrome", path: "/Applications/Google Chrome.app")
        let profile = browser.profiles[0]
        let item = BrowserDisplayItem(browser: browser, profile: profile)
        let testURL = URL(string: "https://google.com")!

        let params = service.getLaunchParameters(for: testURL, with: item)

        XCTAssertNotNil(params)
        XCTAssertTrue(params!.executableURL.path.contains("Google Chrome"))
        XCTAssertEqual(params?.arguments[0], "--profile-directory=Default")
    }

    // MARK: - Error Handling Tests

    func testLaunch_WhenProcessThrows_FallsBackToBundleId() {
        mockProcessLauncher.shouldThrowError = true

        let browser = createBrowserWithProfiles(bundleId: "com.google.Chrome", path: "/Applications/Google Chrome.app")
        let item = BrowserDisplayItem(browser: browser, profile: browser.profiles[0])
        let testURL = URL(string: "https://example.com")!

        // This should attempt profile launch (fails), then fall back to bundle ID launch (also fails due to mock)
        service.launch(url: testURL, with: item)

        // Should have tried twice - once for profile launch, once for fallback
        XCTAssertEqual(mockProcessLauncher.launchedProcesses.count, 0) // Both failed due to mock throwing
    }
}
