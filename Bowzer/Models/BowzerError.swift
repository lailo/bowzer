import Foundation

/// Errors that can occur in Bowzer
enum BowzerError: LocalizedError, Equatable {
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
            return String(localized: "error.noBrowsersFound")
        case .browserNotInstalled(let browser):
            return String(localized: "error.browserNotInstalled \(browser)")
        case .profileConfigNotFound(let browser):
            return String(localized: "error.profileConfigNotFound \(browser)")
        case .profileParsingFailed(let browser, let reason):
            return String(localized: "error.profileParsingFailed \(browser) \(reason)")
        case .launchFailed(let browser, let reason):
            return String(localized: "error.launchFailed \(browser) \(reason)")
        case .executableNotFound(let path):
            return String(localized: "error.executableNotFound \(path)")
        case .settingsEncodingFailed:
            return String(localized: "error.settingsEncodingFailed")
        case .settingsDecodingFailed:
            return String(localized: "error.settingsDecodingFailed")
        case .launchAtLoginFailed(let enabled, let reason):
            if enabled {
                return String(localized: "error.launchAtLoginEnableFailed \(reason)")
            } else {
                return String(localized: "error.launchAtLoginDisableFailed \(reason)")
            }
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .noBrowsersFound:
            return String(localized: "recovery.installSupportedBrowser")
        case .browserNotInstalled:
            return String(localized: "recovery.installBrowser")
        case .profileConfigNotFound:
            return String(localized: "recovery.launchBrowserFirst")
        case .profileParsingFailed:
            return String(localized: "recovery.refreshBrowserList")
        case .launchFailed, .executableNotFound:
            return String(localized: "recovery.refreshOrReinstall")
        case .settingsEncodingFailed, .settingsDecodingFailed:
            return String(localized: "recovery.settingsReset")
        case .launchAtLoginFailed:
            return String(localized: "recovery.checkLoginItems")
        }
    }
}
