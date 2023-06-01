import Foundation

protocol TrackerCategoryStoreProtocol {
    var categories: [TrackerCategory] { get }
    func getCategoryFromCoreData(with categoryId: UUID) throws -> TrackerCategoryCoreData
    func getCategory(at indexPath: IndexPath) -> TrackerCategory?
    func getTrackerCategoryCoreData(from trackerCategory: TrackerCategory) throws -> TrackerCategoryCoreData
    func getTrackerCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory
    func add(newCategory: TrackerCategory) throws
    func deleteCategory(category: TrackerCategory) throws
    func editCategory(trackerCategory: TrackerCategory, newTitle: String) throws
    func createPinnedCategory() throws -> TrackerCategory
    func setDelegate(_ delegate: TrackerCategoryStoreDelegate)
}
