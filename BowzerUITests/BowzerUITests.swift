import XCTest

final class BowzerUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testExample() throws {
        // This is a placeholder test to verify the UI test target works
        XCTAssertTrue(true)
    }
}
