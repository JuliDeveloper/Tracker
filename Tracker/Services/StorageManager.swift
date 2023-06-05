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
    
    func setOldCategory(for tracker: Tracker, _ oldCategory: TrackerCategoryCoreData?) {
        UserDefaults.standard.set(oldCategory?.categoryId?.uuidString, forKey: tracker.id.uuidString)
    }
    
    func getCategoryIdString(for tracker: Tracker) -> String? {
        let originalCategoryIdString = UserDefaults.standard.string(forKey: tracker.id.uuidString)
        return originalCategoryIdString
    }
}
