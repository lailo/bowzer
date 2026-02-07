import XCTest

class SettingsWindowPage {
    let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    // MARK: - Tab Bar Elements

    var setupTab: XCUIElement {
        app.tabs["Setup"]
    }

    var browsersTab: XCUIElement {
        app.tabs["Browsers"]
    }

    var preferencesTab: XCUIElement {
        app.tabs["Preferences"]
    }

    var aboutTab: XCUIElement {
        app.tabs["About"]
    }

    // MARK: - Browsers Tab Elements

    var refreshBrowsersButton: XCUIElement {
        app.buttons["refreshBrowsersButton"]
    }

    func browserToggle(for browserId: String) -> XCUIElement {
        app.checkBoxes["browserToggle_\(browserId)"]
    }

    // MARK: - Preferences Tab Elements

    var showProfileLabelsToggle: XCUIElement {
        app.checkBoxes["showProfileLabelsToggle"]
    }

    var launchAtLoginToggle: XCUIElement {
        app.checkBoxes["launchAtLoginToggle"]
    }

    // MARK: - Actions

    func selectSetupTab() {
        setupTab.tap()
    }

    func selectBrowsersTab() {
        browsersTab.tap()
    }

    func selectPreferencesTab() {
        preferencesTab.tap()
    }

    func selectAboutTab() {
        aboutTab.tap()
    }

    func refreshBrowsers() {
        refreshBrowsersButton.tap()
    }

    func toggleBrowser(_ browserId: String) {
        browserToggle(for: browserId).tap()
    }

    func toggleShowProfileLabels() {
        showProfileLabelsToggle.tap()
    }

    func toggleLaunchAtLogin() {
        launchAtLoginToggle.tap()
    }

    // MARK: - Verification

    func isSettingsWindowVisible() -> Bool {
        return app.windows["Bowzer Settings"].exists
    }

    func waitForSettingsWindow(timeout: TimeInterval = 5) -> Bool {
        return app.windows["Bowzer Settings"].waitForExistence(timeout: timeout)
    }
}
