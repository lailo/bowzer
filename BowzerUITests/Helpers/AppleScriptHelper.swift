import Foundation

class AppleScriptHelper {

    static func clickStatusBarItem() throws {
        let script = """
        tell application "System Events"
            tell process "Bowzer"
                click menu bar item 1 of menu bar 2
            end tell
        end tell
        """
        try executeAppleScript(script)
    }

    static func clickStatusBarMenuItem(_ menuItem: String) throws {
        let script = """
        tell application "System Events"
            tell process "Bowzer"
                click menu bar item 1 of menu bar 2
                delay 0.5
                click menu item "\(menuItem)" of menu 1 of menu bar item 1 of menu bar 2
            end tell
        end tell
        """
        try executeAppleScript(script)
    }

    static func openSettings() throws {
        try clickStatusBarMenuItem("Settings...")
    }

    static func openAbout() throws {
        try clickStatusBarMenuItem("About Bowzer")
    }

    static func quitApp() throws {
        try clickStatusBarMenuItem("Quit Bowzer")
    }

    // MARK: - Private

    private static func executeAppleScript(_ script: String) throws {
        var error: NSDictionary?
        if let appleScript = NSAppleScript(source: script) {
            appleScript.executeAndReturnError(&error)
            if let error = error {
                throw AppleScriptError.executionFailed(error.description)
            }
        } else {
            throw AppleScriptError.scriptCreationFailed
        }
    }
}

enum AppleScriptError: Error {
    case scriptCreationFailed
    case executionFailed(String)
}
