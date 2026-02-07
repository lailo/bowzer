import Foundation
@testable import Bowzer

class MockUserDefaults: UserDefaultsProviding {
    var storage: [String: Any] = [:]

    func data(forKey defaultName: String) -> Data? {
        return storage[defaultName] as? Data
    }

    func set(_ value: Any?, forKey defaultName: String) {
        if let value = value {
            storage[defaultName] = value
        } else {
            storage.removeValue(forKey: defaultName)
        }
    }
}
