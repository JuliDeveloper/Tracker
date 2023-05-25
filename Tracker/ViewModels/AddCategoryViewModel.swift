import Foundation

enum AddCategoryViewModelError: Error {
    case failedAddNewCategory
    case failedDeleteCategory
    case failedEditCategory
}

@propertyWrapper
final class Observable<Value> {
    private var onCategoriesChange: ((Value) -> Void)? = nil
    
    var wrappedValue: Value {
        didSet {
            onCategoriesChange?(wrappedValue)
        }
    }
    
    var projectedValue: Observable<Value> {
        return self
    }
        
    init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    func bind(action: @escaping (Value) -> Void) {
        self.onCategoriesChange = action
    }
}

final class AddCategoryViewModel {
    
    //MARK: - Properties
    @Observable private(set) var categories: [TrackerCategory] = []
    @Observable private(set) var selectedIndexPath: IndexPath? = nil
    
    private var trackerCategoryStore: TrackerCategoryStoreProtocol
    
    var onDidUpdate: ((TrackerCategoryStoreUpdate) -> Void)?
    
    //MARK: - LifeCycle
    init(trackerCategoryStore: TrackerCategoryStoreProtocol = TrackerCategoryStore()) {
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerCategoryStore.setDelegate(self)
        categories = fetchCategories()
    }
    
    //MARK: - Helpers
    private func fetchCategories() -> [TrackerCategory] {
        trackerCategoryStore.categories
    }
    
    func add(category: TrackerCategory) {
        do {
            try trackerCategoryStore.add(newCategory: category)
            categories = fetchCategories()
        } catch {
            print(AddCategoryViewModelError.failedAddNewCategory)
        }
    }
    
    func delete(category: TrackerCategory) {
        do {
            try trackerCategoryStore.deleteCategory(category: category)
            categories = fetchCategories()
        } catch {
            print(AddCategoryViewModelError.failedDeleteCategory)
        }
    }
    
    func edit(category: TrackerCategory, newTitle: String) {
        do {
            try trackerCategoryStore.editCategory(
                trackerCategory: category,
                newTitle: newTitle
            )
            categories = fetchCategories()
        } catch {
            print(AddCategoryViewModelError.failedEditCategory)
        }
    }
    
    func getCategory(at indexPath: IndexPath?) -> TrackerCategory? {
        guard let indexPath else {
            return TrackerCategory(title: "", trackers: [], categoryId: UUID())
        }
        
        let category = trackerCategoryStore.getCategory(at: indexPath)
        return category
    }
        
    func getSelectedCategory(from indexPath: IndexPath?) {
        selectedIndexPath = indexPath
    }
}

extension AddCategoryViewModel: TrackerCategoryStoreDelegate {
    func didUpdate(_ update: TrackerCategoryStoreUpdate) {
        categories = fetchCategories()
        onDidUpdate?(update)
    }
}
