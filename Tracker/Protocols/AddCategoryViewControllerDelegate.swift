import Foundation

protocol AddCategoryViewControllerDelegate: AnyObject {
    func updateListCategories(newCategory: TrackerCategory)
}
