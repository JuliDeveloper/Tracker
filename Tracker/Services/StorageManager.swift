import Foundation

final class StorageManager {
    static let shared = StorageManager()
    
    private let userDefaults = UserDefaults.standard
    private let launchedBeforeKey = "launchedBefore"
    
    private init() {}
    
    func checkLaunchedBefore() -> Bool {
        userDefaults.bool(forKey: launchedBeforeKey)
    }
    
    func setLaunchedBefore(value: Bool) {
        userDefaults.set(value, forKey: launchedBeforeKey)
    }
}
