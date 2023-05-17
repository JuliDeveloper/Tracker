import UIKit
import CoreData

enum TrackerCategoryStoreError: Error {
    case decodingErrorInvalidTitle
    case decodingErrorInvalidTrackers
    case dataNotReceived
    case errorFetchingCategories
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
    func categoryCoreData(with searchText: String) throws -> TrackerCategoryCoreData {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(format: "title == %@", searchText)
        let categories = try context.fetch(request)
        return categories[0]
    }
    
    func fetchCategories() throws -> [TrackerCategory] {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        let result = try context.fetch(fetchRequest)

        if result.isEmpty {
            let _ = [
                TrackerCategory(title: "Радостные мелочи", trackers: []),
            ].map { category in
                let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
                trackerCategoryCoreData.title = category.title
                trackerCategoryCoreData.trackers = []
            }

            try context.save()
        }

        let categories = try result.map({ try getTrackerCategory(from: $0) })
        return categories
    }
    
    private func updatedIndexes() {
        insertedIndexPaths = []
    }
    
    private func getTrackerCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = trackerCategoryCoreData.title else {
            throw TrackerCategoryStoreError.decodingErrorInvalidTitle
        }
        
        guard let trackers = trackerCategoryCoreData.trackers else {
            throw TrackerCategoryStoreError.decodingErrorInvalidTrackers
        }
        
        return TrackerCategory(
            title: title,
            trackers: trackers.allObjects.map { self.convert(from: $0 as? TrackerCoreData) }
        )
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
    var countCategories: Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    func getCategoryTitle(_ section: Int) -> [String?] {
        guard let categories = fetchedResultsController.fetchedObjects else {
            return []
        }
        
        let titles = categories.compactMap { $0.title }
        return titles
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
    
    func add(newCategory: TrackerCategory) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.title = newCategory.title
        
        try context.save()
    }
    
    func deleteCategory(at indexPath: IndexPath) throws {
        
    }
    
    var categories: [TrackerCategory] {
        do {
            return try fetchCategories()
        } catch {
            print(TrackerCategoryStoreError.errorFetchingCategories)
            return []
        }
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
