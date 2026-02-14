import Foundation

protocol UserDefaultsProviding {
    func data(forKey defaultName: String) -> Data?
    func set(_ value: Any?, forKey defaultName: String)
}

extension UserDefaults: UserDefaultsProviding {
    // UserDefaults already implements these methods, so no additional implementation needed
}
