import AppKit

protocol WorkspaceProviding {
    func urlsForApplications(toOpen url: URL) -> [URL]
    func icon(forFile fullPath: String) -> NSImage
}

extension NSWorkspace: WorkspaceProviding {
    // NSWorkspace already implements these methods, so no additional implementation needed
}
