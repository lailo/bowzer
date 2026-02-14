import Foundation
import os.log

enum Log {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.bowzer.app"

    static let browser = Logger(subsystem: subsystem, category: "Browser")
    static let profile = Logger(subsystem: subsystem, category: "Profile")
    static let launch = Logger(subsystem: subsystem, category: "Launch")
    static let settings = Logger(subsystem: subsystem, category: "Settings")
}
