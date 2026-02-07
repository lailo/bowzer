import AppKit
@testable import Bowzer

class MockWorkspace: WorkspaceProviding {
    var applicationURLs: [URL] = []
    var icons: [String: NSImage] = [:]

    func urlsForApplications(toOpen url: URL) -> [URL] {
        return applicationURLs
    }

    func icon(forFile fullPath: String) -> NSImage {
        return icons[fullPath] ?? NSImage()
    }
}
