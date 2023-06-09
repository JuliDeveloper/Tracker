import UIKit
import CoreData

enum TrackerCategoryStoreError: Error {
    case decodingErrorInvalidTitle
    case decodingErrorInvalidTrackers
    case dataNotReceived
    case errorFetchingCategories
    case categoryNotFound
}

struct TrackerCategoryStoreUpdate {
    let insertedIndexes: [IndexPath]
    var deletedIndexPaths: [IndexPath]
}

final class TrackerCategoryStore: NSObject {
    
    //MARK: - Properties
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
 
    private var insertedIndexPaths: [IndexPath] = []
    private var deletedIndexPaths: [IndexPath] = []
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: false),
        ]
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()

    weak var delegate: TrackerCategoryStoreDelegate?
    
    //MARK: - LifeCycle
    convenience override init() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        try! self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
    }
    
    init(delegate: TrackerCategoryStoreDelegate) {
        self.delegate = delegate
        self.context = CoreDataManager.shared.persistentContainer.viewContext
        super.init()
    }
    
    //MARK: - Methods
    private func updatedIndexes() {
        insertedIndexPaths = []
        deletedIndexPaths = []
    }
            
    private func convert(from trackerCoreData: TrackerCoreData?) -> Tracker {
        let id = trackerCoreData?.trackerId ?? UUID()
        let title = trackerCoreData?.title ?? ""
        let color = uiColorMarshalling.fromHexString(hex: trackerCoreData?.colorHex ?? "")
        let emoji = trackerCoreData?.emoji ?? ""
        let schedule = WeekDay.stringToWeekdays(string: trackerCoreData?.schedule) ?? [WeekDay]()
        let countRecords = trackerCoreData?.records?.count ?? 0
        
        return Tracker(
            id: id,
            title: title,
            color: color,
            emoji: emoji,
            schedule: schedule,
            countRecords: countRecords
        )
    }
}

extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    var categories: [TrackerCategory] {
        guard
            let objects = self.fetchedResultsController.fetchedObjects,
            let categories = try? objects.map({
                try getTrackerCategory(from: $0)
            })
        else {
            return []
        }
        
        return categories
    }
    
    func getCategoryFromCoreData(with categoryId: UUID) throws -> TrackerCategoryCoreData {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(format: "categoryId == %@", categoryId as CVarArg)
        let categories = try context.fetch(request)
        
        guard let existingCategory = categories.first else {
            throw TrackerCategoryStoreError.categoryNotFound
        }
        
        return existingCategory
    }
    
    func getCategory(at indexPath: IndexPath) -> TrackerCategory? {
        guard indexPath.row < fetchedResultsController.sections?[0].numberOfObjects ?? 0 else {
            return nil
        }
        
        let trackerCategoryCoreData = fetchedResultsController.object(at: indexPath)
        
        do {
            let category = try getTrackerCategory(from: trackerCategoryCoreData)
            return category
        } catch {
            return nil
        }
    }
    
    func getTrackerCategoryCoreData(from trackerCategory: TrackerCategory) throws -> TrackerCategoryCoreData {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "categoryId == %@", trackerCategory.categoryId as CVarArg)

        let categories = try context.fetch(fetchRequest)
        return categories.first ?? TrackerCategoryCoreData()
    }
    
    func add(newCategory: TrackerCategory) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.categoryId = newCategory.categoryId
        trackerCategoryCoreData.title = newCategory.title
        trackerCategoryCoreData.trackers = NSSet()
        
        try context.save()
    }
    
    func getTrackerCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = trackerCategoryCoreData.title else {
            throw TrackerCategoryStoreError.decodingErrorInvalidTitle
        }
        
        guard let trackers = trackerCategoryCoreData.trackers else {
            throw TrackerCategoryStoreError.decodingErrorInvalidTrackers
        }
        
        guard let id = trackerCategoryCoreData.categoryId else {
            throw TrackerCategoryStoreError.decodingErrorInvalidTrackers // id
        }
        
        return TrackerCategory(
            title: title,
            trackers: trackers.allObjects.map { self.convert(from: $0 as? TrackerCoreData) },
            categoryId: id
        )
    }
    
    func deleteCategory(category: TrackerCategory) throws {
        let categoryCoreData = try getTrackerCategoryCoreData(from: category)
        let trackersCoreData = categoryCoreData.trackers?.allObjects as? [TrackerCoreData] ?? []
        
        trackersCoreData.forEach { trackerCoreData in
            context.delete(trackerCoreData)
        }
        
        context.delete(categoryCoreData)
        try context.save()
    }
    
    func editCategory(trackerCategory: TrackerCategory, newTitle: String) throws {
        let trackerCategoryCoreData = try getTrackerCategoryCoreData(from: trackerCategory)
        trackerCategoryCoreData.title = newTitle
        try context.save()
    }
    
    func createPinnedCategory() throws -> TrackerCategory {
        let pinnedCategoryTitle = "Закрепленные"
        if let existingPinnedCategory = categories.first(where: { $0.title == pinnedCategoryTitle }) {
            return existingPinnedCategory
        } else {
            let pinnedCategory = TrackerCategory(title: pinnedCategoryTitle, trackers: [], categoryId: UUID())
            try add(newCategory: pinnedCategory)
            return pinnedCategory
        }
    }
    
    func setDelegate(_ delegate: TrackerCategoryStoreDelegate) {
        self.delegate = delegate
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(
            TrackerCategoryStoreUpdate(
                insertedIndexes: insertedIndexPaths,
                deletedIndexPaths: deletedIndexPaths
            )
        )
        updatedIndexes()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexPaths.append(indexPath)
            }
        case .delete:
            if let indexPath = indexPath {
                deletedIndexPaths.append(indexPath)
            }
        default:
            break
        }
    }
}
