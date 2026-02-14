import AppKit

struct Browser: Identifiable, Equatable {
    let id: String
    let name: String
    let bundleIdentifier: String
    let path: URL
    let icon: NSImage
    var profiles: [BrowserProfile]

    var displayItems: [BrowserDisplayItem] {
        if profiles.isEmpty || profiles.count == 1 {
            return [BrowserDisplayItem(browser: self, profile: profiles.first)]
        } else {
            return profiles.map { BrowserDisplayItem(browser: self, profile: $0) }
        }
    }

    static func == (lhs: Browser, rhs: Browser) -> Bool {
        lhs.bundleIdentifier == rhs.bundleIdentifier
    }
}

struct BrowserDisplayItem: Identifiable {
    let id: String
    let browser: Browser
    let profile: BrowserProfile?

    init(browser: Browser, profile: BrowserProfile?) {
        self.browser = browser
        self.profile = profile
        // Use profile ID directly if available (it already includes browser bundle ID)
        // Otherwise construct ID with default suffix
        self.id = profile?.id ?? "\(browser.bundleIdentifier)_default"
    }

    var displayName: String {
        profile?.displayName ?? browser.name
    }

    var showProfileLabel: Bool {
        profile != nil && browser.profiles.count > 1
    }
}

enum BrowserType: String, CaseIterable {
    case safari = "com.apple.Safari"
    case chrome = "com.google.Chrome"
    case firefox = "org.mozilla.firefox"
    case edge = "com.microsoft.edgemac"
    case brave = "com.brave.Browser"
    case arc = "company.thebrowser.Browser"

    var profileType: ProfileType {
        switch self {
        case .safari:
            return .none
        case .chrome, .edge, .brave:
            return .chromium
        case .firefox:
            return .firefox
        case .arc:
            return .none // Arc handles profiles differently
        }
    }

    var applicationSupportFolder: String? {
        switch self {
        case .chrome:
            return "Google/Chrome"
        case .edge:
            return "Microsoft Edge"
        case .brave:
            return "BraveSoftware/Brave-Browser"
        case .firefox:
            return "Firefox"
        default:
            return nil
        }
    }
}

enum ProfileType {
    case none
    case chromium
    case firefox
}
