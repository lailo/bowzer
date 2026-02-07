import XCTest

class PickerWindowPage {
    let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    // MARK: - Elements

    func browserItem(at index: Int) -> XCUIElement {
        app.buttons["browserItem_\(index)"]
    }

    func browserItem(withId id: String) -> XCUIElement {
        app.buttons["browserItem_\(id)"]
    }

    // MARK: - Keyboard Actions

    func pressEscape() {
        app.typeKey(.escape, modifierFlags: [])
    }

    func pressDigit(_ digit: Int) {
        guard digit >= 1 && digit <= 9 else { return }
        app.typeKey(XCUIKeyboardKey(rawValue: String(digit)), modifierFlags: [])
    }

    // MARK: - Actions

    func selectBrowser(at index: Int) {
        browserItem(at: index).tap()
    }

    func selectBrowser(withId id: String) {
        browserItem(withId: id).tap()
    }

    func dismissPicker() {
        pressEscape()
    }

    func selectBrowserWithKeyboard(_ digit: Int) {
        pressDigit(digit)
    }

    // MARK: - Verification

    func isPickerVisible() -> Bool {
        // The picker window doesn't have a title, so we check for any visible browser items
        return browserItem(at: 0).exists || browserItem(at: 1).exists
    }

    func waitForPicker(timeout: TimeInterval = 5) -> Bool {
        return browserItem(at: 0).waitForExistence(timeout: timeout)
    }

    func browserItemCount() -> Int {
        return app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'browserItem_'")).count
    }
}
