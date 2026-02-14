import Foundation

protocol FileManagerProviding {
    var homeDirectoryForCurrentUser: URL { get }
    func fileExists(atPath path: String) -> Bool
    func displayName(atPath path: String) -> String
    func contents(atPath path: String) -> Data?
}

extension FileManager: FileManagerProviding {}
