import XCTest
@testable import Bowzer

/// Tests for error scenarios across the application
final class ErrorScenarioTests: XCTestCase {

    var mockWorkspace: MockWorkspace!
    var mockFileManager: MockFileManager!
    var mockUserDefaults: MockUserDefaults!

    override func setUpWithError() throws {
        mockWorkspace = MockWorkspace()
        mockFileManager = MockFileManager()
        mockUserDefaults = MockUserDefaults()
    }

    override func tearDownWithError() throws {
        mockWorkspace = nil
        mockFileManager = nil
        mockUserDefaults = nil
    }

    // MARK: - Browser Detection Error Scenarios

    func testBrowserDetection_NoBrowsersInstalled_ReturnsEmptyList() {
        // Given - No browsers in mock workspace
        mockWorkspace.applicationURLs = []

        let service = BrowserDetectionService(
            workspace: mockWorkspace,
            fileManager: mockFileManager
        )

        // When
        let browsers = service.detectBrowsers()

        // Then
        XCTAssertTrue(browsers.isEmpty)
    }

    func testBrowserDetection_UnsupportedBrowser_IsFiltered() {
        // Given - Only an unsupported browser installed
        let customBrowserPath = URL(fileURLWithPath: "/Applications/CustomBrowser.app")
        mockWorkspace.applicationURLs = [customBrowserPath]

        let service = BrowserDetectionService(
            workspace: mockWorkspace,
            fileManager: mockFileManager
        )

        // When
        let browsers = service.detectBrowsers()

        // Then - Custom browser should be filtered out
        XCTAssertTrue(browsers.isEmpty)
    }

    // MARK: - Profile Detection Error Scenarios

    func testProfileDetection_CorruptedLocalState_ReturnsEmptyProfiles() {
        // Given - Chrome installed but Local State is corrupted JSON
        let homeDir = URL(fileURLWithPath: "/Users/testuser")
        mockFileManager.mockHomeDirectory = homeDir

        let localStatePath = homeDir
            .appendingPathComponent("Library/Application Support/Google/Chrome/Local State")
        let corruptedData = "not valid json {{{".data(using: .utf8)!

        mockFileManager.existingPaths = [localStatePath.path]
        mockFileManager.fileContents = [localStatePath.path: corruptedData]

        let service = ProfileDetectionService(fileManager: mockFileManager)

        // When
        let profiles = service.detectProfiles(for: .chrome)

        // Then
        XCTAssertTrue(profiles.isEmpty)
    }

    func testProfileDetection_MissingLocalStateFile_ReturnsEmptyProfiles() {
        // Given - Chrome installed but no Local State file
        let homeDir = URL(fileURLWithPath: "/Users/testuser")
        mockFileManager.mockHomeDirectory = homeDir
        mockFileManager.existingPaths = [] // No files exist

        let service = ProfileDetectionService(fileManager: mockFileManager)

        // When
        let profiles = service.detectProfiles(for: .chrome)

        // Then
        XCTAssertTrue(profiles.isEmpty)
    }

    func testProfileDetection_MissingProfileKey_ReturnsEmptyProfiles() {
        // Given - Local State exists but missing 'profile' key
        let homeDir = URL(fileURLWithPath: "/Users/testuser")
        mockFileManager.mockHomeDirectory = homeDir

        let localStatePath = homeDir
            .appendingPathComponent("Library/Application Support/Google/Chrome/Local State")
        let incompleteData = """
        {
            "other_key": "value"
        }
        """.data(using: .utf8)!

        mockFileManager.existingPaths = [localStatePath.path]
        mockFileManager.fileContents = [localStatePath.path: incompleteData]

        let service = ProfileDetectionService(fileManager: mockFileManager)

        // When
        let profiles = service.detectProfiles(for: .chrome)

        // Then
        XCTAssertTrue(profiles.isEmpty)
    }

    func testProfileDetection_MissingInfoCache_ReturnsEmptyProfiles() {
        // Given - Local State has 'profile' but no 'info_cache'
        let homeDir = URL(fileURLWithPath: "/Users/testuser")
        mockFileManager.mockHomeDirectory = homeDir

        let localStatePath = homeDir
            .appendingPathComponent("Library/Application Support/Google/Chrome/Local State")
        let incompleteData = """
        {
            "profile": {
                "other_key": "value"
            }
        }
        """.data(using: .utf8)!

        mockFileManager.existingPaths = [localStatePath.path]
        mockFileManager.fileContents = [localStatePath.path: incompleteData]

        let service = ProfileDetectionService(fileManager: mockFileManager)

        // When
        let profiles = service.detectProfiles(for: .chrome)

        // Then
        XCTAssertTrue(profiles.isEmpty)
    }

    func testProfileDetection_ProfileMissingName_SkipsProfile() {
        // Given - Profile entry exists but missing 'name' field
        let homeDir = URL(fileURLWithPath: "/Users/testuser")
        mockFileManager.mockHomeDirectory = homeDir

        let localStatePath = homeDir
            .appendingPathComponent("Library/Application Support/Google/Chrome/Local State")
        let incompleteData = """
        {
            "profile": {
                "info_cache": {
                    "Default": {"email": "test@test.com"},
                    "Profile 1": {"name": "Valid Profile"}
                }
            }
        }
        """.data(using: .utf8)!

        mockFileManager.existingPaths = [localStatePath.path]
        mockFileManager.fileContents = [localStatePath.path: incompleteData]

        let service = ProfileDetectionService(fileManager: mockFileManager)

        // When
        let profiles = service.detectProfiles(for: .chrome)

        // Then - Only the valid profile should be returned
        XCTAssertEqual(profiles.count, 1)
        XCTAssertEqual(profiles[0].name, "Valid Profile")
    }

    // MARK: - Firefox Profile Error Scenarios

    func testFirefoxProfileDetection_MissingProfilesIni_ReturnsEmptyProfiles() {
        // Given - No profiles.ini file
        let homeDir = URL(fileURLWithPath: "/Users/testuser")
        mockFileManager.mockHomeDirectory = homeDir
        mockFileManager.existingPaths = []

        let service = ProfileDetectionService(fileManager: mockFileManager)

        // When
        let profiles = service.detectFirefoxProfiles()

        // Then
        XCTAssertTrue(profiles.isEmpty)
    }

    func testFirefoxProfileDetection_EmptyProfilesIni_ReturnsEmptyProfiles() {
        // Given - Empty profiles.ini file
        let homeDir = URL(fileURLWithPath: "/Users/testuser")
        mockFileManager.mockHomeDirectory = homeDir

        let profilesIniPath = homeDir
            .appendingPathComponent("Library/Application Support/Firefox/profiles.ini")
        let emptyData = "".data(using: .utf8)!

        mockFileManager.existingPaths = [profilesIniPath.path]
        mockFileManager.fileContents = [profilesIniPath.path: emptyData]

        let service = ProfileDetectionService(fileManager: mockFileManager)

        // When
        let profiles = service.detectFirefoxProfiles()

        // Then
        XCTAssertTrue(profiles.isEmpty)
    }

    // MARK: - URL Launch Error Scenarios

    func testURLLaunch_ProcessThrows_ReturnsFailed() {
        // Given
        let mockProcess = MockProcessLauncher()
        mockProcess.shouldThrowError = true

        let launchService = URLLaunchService(processLauncher: mockProcess)

        let safari = TestDataFactory.makeBrowser(
            id: "safari",
            name: "Safari",
            bundleIdentifier: "com.apple.Safari"
        )
        let displayItem = safari.displayItems[0]
        let url = URL(string: "https://example.com")!

        // When
        let result = launchService.launchWithResult(url: url, with: displayItem)

        // Then
        if case .failure(let error) = result {
            XCTAssertNotNil(error.errorDescription)
        } else {
            XCTFail("Should have returned failure")
        }
    }

    func testURLLaunch_ProfileLaunchFails_FallsBackToBundleId() {
        // Given - Process that fails on first call but succeeds on fallback
        let mockProcess = FailOnceProcessLauncher()

        let launchService = URLLaunchService(processLauncher: mockProcess)

        let chrome = TestDataFactory.makeBrowserWithProfiles(
            id: "chrome",
            name: "Chrome",
            bundleIdentifier: "com.google.Chrome",
            profileNames: ["Work"]
        )
        let displayItem = chrome.displayItems[0]
        let url = URL(string: "https://example.com")!

        // When
        let result = launchService.launchWithResult(url: url, with: displayItem)

        // Then - Should succeed via fallback
        if case .success = result {
            XCTAssertEqual(mockProcess.launchCount, 2)
        } else {
            XCTFail("Should have succeeded via fallback")
        }
    }

    // MARK: - Settings Error Scenarios

    func testSettings_CorruptedData_ReturnsFailure() {
        // Given - Corrupted settings data
        mockUserDefaults.storage["BowzerSettings"] = "not valid json".data(using: .utf8)

        let service = SettingsService(userDefaults: mockUserDefaults)

        // When
        let result = service.loadSettingsWithResult()

        // Then - Should return failure
        if case .failure(let error) = result {
            XCTAssertEqual(error, BowzerError.settingsDecodingFailed)
        } else {
            XCTFail("Should have returned failure for corrupted data")
        }
    }

    func testSettings_EmptyStorage_ReturnsDefaults() {
        // Given - No saved settings
        mockUserDefaults.storage = [:]

        let service = SettingsService(userDefaults: mockUserDefaults)

        // When
        let result = service.loadSettingsWithResult()

        // Then - Should return default settings
        if case .success(let settings) = result {
            XCTAssertEqual(settings.browserOrder, [])
            XCTAssertEqual(settings.hiddenBrowsers, [])
            XCTAssertEqual(settings.showProfileLabels, true)
        } else {
            XCTFail("Should return default settings when empty")
        }
    }
}

// MARK: - Test Helpers

/// Process launcher that fails on first call but succeeds on subsequent calls
class FailOnceProcessLauncher: ProcessLaunching {
    var launchCount = 0

    func launch(executableURL: URL, arguments: [String]) throws {
        launchCount += 1
        if launchCount == 1 {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
    }
}
