import Foundation

struct BrowserProfile: Identifiable, Equatable {
    let id: String
    let name: String
    let directoryName: String

    var displayName: String {
        name
    }

    var truncatedName: String {
        truncate(name, maxLength: 12)
    }

    private func truncate(_ string: String, maxLength: Int) -> String {
        if string.count <= maxLength {
            return string
        }
        return String(string.prefix(maxLength - 1)) + "…"
    }

    static func == (lhs: BrowserProfile, rhs: BrowserProfile) -> Bool {
        lhs.id == rhs.id && lhs.directoryName == rhs.directoryName
    }
}
