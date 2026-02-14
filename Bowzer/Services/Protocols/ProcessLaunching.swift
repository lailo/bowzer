import Foundation

protocol ProcessLaunching {
    func launch(executableURL: URL, arguments: [String]) throws
}

class DefaultProcessLauncher: ProcessLaunching {
    func launch(executableURL: URL, arguments: [String]) throws {
        let process = Process()
        process.executableURL = executableURL
        process.arguments = arguments
        try process.run()
    }
}
