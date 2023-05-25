import Foundation

protocol TrackerCategoryStoreProtocol {
    var categories: [TrackerCategory] { get }
    func getCategory(at indexPath: IndexPath) -> TrackerCategory?
    func add(newCategory: TrackerCategory) throws
    func deleteCategory(category: TrackerCategory) throws
    func editCategory(trackerCategory: TrackerCategory, newTitle: String) throws
    func setDelegate(_ delegate: TrackerCategoryStoreDelegate)
}
