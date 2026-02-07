import Foundation
@testable import Bowzer

class MockFileManager: FileManagerProviding {
    var mockHomeDirectory: URL = URL(fileURLWithPath: "/Users/testuser")
    var existingPaths: Set<String> = []
    var fileContents: [String: Data] = [:]
    var displayNames: [String: String] = [:]

    var homeDirectoryForCurrentUser: URL {
        return mockHomeDirectory
    }

    func fileExists(atPath path: String) -> Bool {
        return existingPaths.contains(path)
    }

    func displayName(atPath path: String) -> String {
        return displayNames[path] ?? URL(fileURLWithPath: path).lastPathComponent
    }

    func contents(atPath path: String) -> Data? {
        return fileContents[path]
    }
}
