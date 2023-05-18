import Foundation

protocol TrackerCategoryStoreProtocol {
    var categories: [TrackerCategory] { get }
    var countCategories: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func getCategoryTitle(_ section: Int) -> [String?]
    func getCategory(at indexPath: IndexPath) -> TrackerCategory?
    func add(newCategory: TrackerCategory) throws
    func deleteCategory(at indexPath: IndexPath) throws
    func editCategory(trackerCategory: TrackerCategory, newTitle: String) throws
}
