import UIKit
import CoreData

enum TrackerStoreError: Error {
    case decodingErrorInvalidId
    case decodingErrorInvalidTitle
    case decodingErrorInvalidColor
    case decodingErrorInvalidEmoji
    case decodingErrorInvalidSchedule
}

struct TrackerStoreUpdate {
    let insertedSections: IndexSet
    let insertedIndexes: [IndexPath]
}

final class TrackerStore: NSObject {
    
    //MARK: - Properties
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    private let trackerCategoryStore = TrackerCategoryStore()
    
    private var insertedSections = IndexSet()
    private var insertedIndexPaths: [IndexPath] = []
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.category?.title, ascending: true),
            NSSortDescriptor(keyPath: \TrackerCoreData.createdAt, ascending: true)
        ]
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category",
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    weak var delegate: TrackerStoreDelegate?
        
    // MARK: - Lifecycle
    convenience override init() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    //MARK: - Methods
    private func updatedIndexes() {
        insertedIndexPaths = []
        insertedSections = IndexSet()
    }
    
    func getTracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = trackerCoreData.trackerId else {
            throw TrackerStoreError.decodingErrorInvalidId
        }

        guard let title = trackerCoreData.title else {
            throw TrackerStoreError.decodingErrorInvalidTitle
        }

        guard let colorHex = trackerCoreData.colorHex else {
            throw TrackerStoreError.decodingErrorInvalidColor
        }

        guard let emoji = trackerCoreData.emoji else {
            throw TrackerStoreError.decodingErrorInvalidEmoji
        }
        
        guard let countRecords = trackerCoreData.records?.count else {
            throw TrackerStoreError.decodingErrorInvalidEmoji
        }

        guard let scheduleString = trackerCoreData.schedule else {
            throw TrackerStoreError.decodingErrorInvalidSchedule
        }

        let color = uiColorMarshalling.fromHexString(hex: colorHex)
        let schedule = WeekDay.stringToWeekdays(string: scheduleString)

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

//MARK: - TrackerStoreProtocol
extension TrackerStore: TrackerStoreProtocol {
    var countTrackers: Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func headerTitleSection(_ section: Int) -> String? {
        guard let trackerCoreData = fetchedResultsController.sections?[section].objects?.first as? TrackerCoreData else { return "" }
        return trackerCoreData.category?.title
    }
    
    func getTracker(at indexPath: IndexPath) -> Tracker? {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        
        do {
            let tracker = try getTracker(from: trackerCoreData)
            return tracker
        } catch {
            return nil
        }
    }
    
    func addNewTracker(from tracker: Tracker, and category: TrackerCategory) throws {
        let categoryCoreData = try trackerCategoryStore.categoryCoreData(with: category.title)
        
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.trackerId = tracker.id
        trackerCoreData.title = tracker.title
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.colorHex = uiColorMarshalling.toHexString(color: tracker.color)
        trackerCoreData.schedule = WeekDay.weekdaysToString(weekdays: tracker.schedule)
        trackerCoreData.createdAt = Date()
        trackerCoreData.category = categoryCoreData

        try context.save()
    }
    
    func trackerFiltering(from currentDate: String?, or searchText: String?) {
        if currentDate != nil {
            fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "%K CONTAINS[n] %@", #keyPath(TrackerCoreData.schedule), currentDate ?? "")
        } else {
            fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "%K CONTAINS[n] %@", #keyPath(TrackerCoreData.title), searchText ?? "")
        }
        
        try? fetchedResultsController.performFetch()
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(
            TrackerStoreUpdate(
                insertedSections: insertedSections,
                insertedIndexes: insertedIndexPaths
            )
        )
        updatedIndexes()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            insertedSections.insert(sectionIndex)
        default:
            break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexPaths.append(indexPath)
            }
        default:
            break
        }
    }
}
