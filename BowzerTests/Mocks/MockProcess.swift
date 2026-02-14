import Foundation
@testable import Bowzer

class MockProcessLauncher: ProcessLaunching {
    var launchedProcesses: [(executableURL: URL, arguments: [String])] = []
    var shouldThrowError: Bool = false

    func launch(executableURL: URL, arguments: [String]) throws {
        if shouldThrowError {
            throw NSError(domain: "MockProcessError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        }
        launchedProcesses.append((executableURL: executableURL, arguments: arguments))
    }
}
