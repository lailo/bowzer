import XCTest
@testable import Bowzer

final class ProfileDetectionServiceTests: XCTestCase {

    var service: ProfileDetectionService!
    var mockFileManager: MockFileManager!

    override func setUpWithError() throws {
        mockFileManager = MockFileManager()
        service = ProfileDetectionService(fileManager: mockFileManager)
    }

    override func tearDownWithError() throws {
        service = nil
        mockFileManager = nil
    }

    // MARK: - Chromium Profile Tests

    func testParseChromiumLocalState_WithValidProfiles() {
        let localStateJSON = """
        {
            "profile": {
                "info_cache": {
                    "Default": {"name": "Person 1"},
                    "Profile 1": {"name": "Work"},
                    "Profile 2": {"name": "Personal"}
                }
            }
        }
        """

        let data = localStateJSON.data(using: .utf8)!
        let profiles = service.parseChromiumLocalState(data: data, browserType: .chrome)

        XCTAssertEqual(profiles.count, 3)
        // Default should be first
        XCTAssertEqual(profiles[0].directoryName, "Default")
        XCTAssertEqual(profiles[0].name, "Person 1")
    }

    func testParseChromiumLocalState_SortsDefaultFirst() {
        let localStateJSON = """
        {
            "profile": {
                "info_cache": {
                    "Profile 1": {"name": "Zebra"},
                    "Default": {"name": "Alpha"},
                    "Profile 2": {"name": "Beta"}
                }
            }
        }
        """

        let data = localStateJSON.data(using: .utf8)!
        let profiles = service.parseChromiumLocalState(data: data, browserType: .chrome)

        XCTAssertEqual(profiles.count, 3)
        XCTAssertEqual(profiles[0].directoryName, "Default")
        // Remaining sorted alphabetically by name
        XCTAssertEqual(profiles[1].name, "Beta")
        XCTAssertEqual(profiles[2].name, "Zebra")
    }

    func testParseChromiumLocalState_WithMissingName() {
        let localStateJSON = """
        {
            "profile": {
                "info_cache": {
                    "Default": {"name": "Person 1"},
                    "Profile 1": {"other_key": "no name here"}
                }
            }
        }
        """

        let data = localStateJSON.data(using: .utf8)!
        let profiles = service.parseChromiumLocalState(data: data, browserType: .chrome)

        // Only the valid profile should be included
        XCTAssertEqual(profiles.count, 1)
        XCTAssertEqual(profiles[0].name, "Person 1")
    }

    func testParseChromiumLocalState_WithInvalidJSON() {
        let invalidJSON = "not valid json"
        let data = invalidJSON.data(using: .utf8)!
        let profiles = service.parseChromiumLocalState(data: data, browserType: .chrome)

        XCTAssertEqual(profiles.count, 0)
    }

    func testParseChromiumLocalState_WithMissingProfileKey() {
        let localStateJSON = """
        {
            "other_key": {}
        }
        """

        let data = localStateJSON.data(using: .utf8)!
        let profiles = service.parseChromiumLocalState(data: data, browserType: .chrome)

        XCTAssertEqual(profiles.count, 0)
    }

    func testParseChromiumLocalState_WithMissingInfoCache() {
        let localStateJSON = """
        {
            "profile": {
                "other_key": {}
            }
        }
        """

        let data = localStateJSON.data(using: .utf8)!
        let profiles = service.parseChromiumLocalState(data: data, browserType: .chrome)

        XCTAssertEqual(profiles.count, 0)
    }

    // MARK: - Firefox Profile Tests

    func testParseFirefoxProfilesIni_WithValidProfiles() {
        let profilesIni = """
        [General]
        StartWithLastProfile=1

        [Profile0]
        Name=default
        IsRelative=1
        Path=Profiles/abc123.default

        [Profile1]
        Name=Work
        IsRelative=1
        Path=Profiles/def456.work
        """

        let profiles = service.parseFirefoxProfilesIni(contents: profilesIni)

        XCTAssertEqual(profiles.count, 2)
        XCTAssertEqual(profiles[0].name, "default")
        XCTAssertEqual(profiles[0].directoryName, "Profiles/abc123.default")
        XCTAssertEqual(profiles[1].name, "Work")
        XCTAssertEqual(profiles[1].directoryName, "Profiles/def456.work")
    }

    func testParseFirefoxProfilesIni_WithEmptyContent() {
        let profiles = service.parseFirefoxProfilesIni(contents: "")
        XCTAssertEqual(profiles.count, 0)
    }

    func testParseFirefoxProfilesIni_WithOnlyGeneral() {
        let profilesIni = """
        [General]
        StartWithLastProfile=1
        """

        let profiles = service.parseFirefoxProfilesIni(contents: profilesIni)
        XCTAssertEqual(profiles.count, 0)
    }

    func testParseFirefoxProfilesIni_WithMissingPath() {
        let profilesIni = """
        [Profile0]
        Name=default
        IsRelative=1
        """

        let profiles = service.parseFirefoxProfilesIni(contents: profilesIni)
        // Profile should be skipped if path is missing
        XCTAssertEqual(profiles.count, 0)
    }

    func testParseFirefoxProfilesIni_WithMissingName() {
        let profilesIni = """
        [Profile0]
        IsRelative=1
        Path=Profiles/abc123.default
        """

        let profiles = service.parseFirefoxProfilesIni(contents: profilesIni)
        // Profile should be skipped if name is missing
        XCTAssertEqual(profiles.count, 0)
    }

    // MARK: - Browser Type Tests

    func testDetectProfiles_ForSafari() {
        // Safari doesn't have profiles
        let profiles = service.detectProfiles(for: .safari)
        XCTAssertEqual(profiles.count, 0)
    }

    func testDetectProfiles_ForArc() {
        // Arc doesn't use traditional profiles
        let profiles = service.detectProfiles(for: .arc)
        XCTAssertEqual(profiles.count, 0)
    }
}
