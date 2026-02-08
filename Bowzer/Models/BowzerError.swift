import Foundation

/// Errors that can occur in Bowzer
enum BowzerError: LocalizedError {
    // Browser detection errors
    case noBrowsersFound
    case browserNotInstalled(String)

    // Profile detection errors
    case profileConfigNotFound(browser: String)
    case profileParsingFailed(browser: String, reason: String)

    // Launch errors
    case launchFailed(browser: String, reason: String)
    case executableNotFound(path: String)

    // Settings errors
    case settingsEncodingFailed
    case settingsDecodingFailed
    case launchAtLoginFailed(enabled: Bool, reason: String)

    var errorDescription: String? {
        switch self {
        case .noBrowsersFound:
            return "No supported browsers found on this system"
        case .browserNotInstalled(let browser):
            return "\(browser) is not installed"
        case .profileConfigNotFound(let browser):
            return "Profile configuration not found for \(browser)"
        case .profileParsingFailed(let browser, let reason):
            return "Failed to parse \(browser) profiles: \(reason)"
        case .launchFailed(let browser, let reason):
            return "Failed to launch \(browser): \(reason)"
        case .executableNotFound(let path):
            return "Browser executable not found at \(path)"
        case .settingsEncodingFailed:
            return "Failed to save settings"
        case .settingsDecodingFailed:
            return "Failed to load settings"
        case .launchAtLoginFailed(let enabled, let reason):
            return "Failed to \(enabled ? "enable" : "disable") launch at login: \(reason)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .noBrowsersFound:
            return "Install a supported browser (Safari, Chrome, Firefox, Edge, Brave, or Arc)"
        case .browserNotInstalled:
            return "Install the browser or refresh the browser list"
        case .profileConfigNotFound:
            return "The browser may need to be launched at least once to create its profile"
        case .profileParsingFailed:
            return "Try refreshing the browser list"
        case .launchFailed, .executableNotFound:
            return "Try refreshing the browser list or reinstalling the browser"
        case .settingsEncodingFailed, .settingsDecodingFailed:
            return "Settings will be reset to defaults"
        case .launchAtLoginFailed:
            return "Check System Preferences > Login Items"
        }
    }
}
