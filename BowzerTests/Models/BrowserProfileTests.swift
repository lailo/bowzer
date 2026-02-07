import XCTest
@testable import Bowzer

final class BrowserProfileTests: XCTestCase {

    // MARK: - Truncated Name Tests

    func testTruncatedName_ShortName_NoTruncation() {
        let profile = BrowserProfile(id: "1", name: "Work", directoryName: "Profile 1")

        XCTAssertEqual(profile.truncatedName, "Work")
    }

    func testTruncatedName_ExactlyMaxLength_NoTruncation() {
        let profile = BrowserProfile(id: "1", name: "123456789012", directoryName: "Profile 1")

        XCTAssertEqual(profile.truncatedName, "123456789012")
        XCTAssertEqual(profile.truncatedName.count, 12)
    }

    func testTruncatedName_LongerThanMax_TruncatesWithEllipsis() {
        let profile = BrowserProfile(id: "1", name: "1234567890123", directoryName: "Profile 1")

        XCTAssertEqual(profile.truncatedName, "12345678901…")
        XCTAssertEqual(profile.truncatedName.count, 12)
    }

    func testTruncatedName_VeryLongName_TruncatesWithEllipsis() {
        let profile = BrowserProfile(id: "1", name: "This is a very long profile name", directoryName: "Profile 1")

        XCTAssertEqual(profile.truncatedName, "This is a v…")
        XCTAssertEqual(profile.truncatedName.count, 12)
    }

    func testTruncatedName_EmptyName() {
        let profile = BrowserProfile(id: "1", name: "", directoryName: "Profile 1")

        XCTAssertEqual(profile.truncatedName, "")
    }

    func testTruncatedName_SingleCharacter() {
        let profile = BrowserProfile(id: "1", name: "A", directoryName: "Profile 1")

        XCTAssertEqual(profile.truncatedName, "A")
    }

    // MARK: - Display Name Tests

    func testDisplayName_ReturnsPrimaryName() {
        let profile = BrowserProfile(id: "1", name: "Personal Account", directoryName: "Default")

        XCTAssertEqual(profile.displayName, "Personal Account")
    }

    // MARK: - Equality Tests

    func testEquality_SameIdAndDirectory_AreEqual() {
        let profile1 = BrowserProfile(id: "chrome_Default", name: "Person 1", directoryName: "Default")
        let profile2 = BrowserProfile(id: "chrome_Default", name: "Different Name", directoryName: "Default")

        XCTAssertEqual(profile1, profile2)
    }

    func testEquality_DifferentId_AreNotEqual() {
        let profile1 = BrowserProfile(id: "chrome_Default", name: "Person 1", directoryName: "Default")
        let profile2 = BrowserProfile(id: "chrome_Profile1", name: "Person 1", directoryName: "Default")

        XCTAssertNotEqual(profile1, profile2)
    }

    func testEquality_DifferentDirectory_AreNotEqual() {
        let profile1 = BrowserProfile(id: "chrome_Default", name: "Person 1", directoryName: "Default")
        let profile2 = BrowserProfile(id: "chrome_Default", name: "Person 1", directoryName: "Profile 1")

        XCTAssertNotEqual(profile1, profile2)
    }
}
