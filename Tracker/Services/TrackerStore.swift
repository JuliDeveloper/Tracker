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
    var deletedSections: IndexSet
    var updateSections: IndexSet
    let insertedIndexes: [IndexPath]
    var deletedIndexPaths: [IndexPath]
    var updateIndexPaths: [IndexPath]
}

final class TrackerStore: NSObject {
    
    //MARK: - Properties
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    private let trackerCategoryStore = TrackerCategoryStore()
    
    private var insertedSections = IndexSet()
    private var deletedSections = IndexSet()
    private var updateSections = IndexSet()
    private var insertedIndexPaths: [IndexPath] = []
    private var deletedIndexPaths: [IndexPath] = []
    private var updateIndexPaths: [IndexPath] = []
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.category?.title, ascending: false),
            NSSortDescriptor(keyPath: \TrackerCoreData.title, ascending: true)
        ]
        fetchRequest.predicate = NSPredicate(format: "%K CONTAINS[n] %@", #keyPath(TrackerCoreData.schedule), currentDayOfWeek())
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: #keyPath(TrackerCoreData.category.title),
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
    
    init(delegate: TrackerStoreDelegate) {
        self.delegate = delegate
        self.context = CoreDataManager.shared.persistentContainer.viewContext
        super.init()
    }
    
    //MARK: - Helpers
    private func currentDayOfWeek() -> String {
        return Date().currentDayOfWeek()
    }
    
    private func updatedIndexes() {
        insertedIndexPaths = []
        insertedSections = IndexSet()
        updateIndexPaths = []
        updateSections = IndexSet()
    }
    
    private func getRecord(from recordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let trackerId = recordCoreData.tracker?.trackerId else {
            throw TrackerRecordsStoreError.decodingErrorInvalidId
        }
        guard let date = recordCoreData.date else {
            throw TrackerRecordsStoreError.decodingErrorInvalidDate
        }
        return TrackerRecord(trackerId: trackerId, date: date)
    }
    
    //MARK: - Methods
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
        let categoryCoreData = try trackerCategoryStore.categoryCoreData(with: category.categoryId)
        
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
    
    func deleteTracker(at indexPath: IndexPath) throws {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        context.delete(trackerCoreData)
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
    
    func getRecords(for indexPath: IndexPath) -> Set<TrackerRecord> {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        
        guard let trackerRecordsCoreData = trackerCoreData.records as? Set<TrackerRecordCoreData> else { return Set<TrackerRecord>() }
        
        do {
            let trackerRecords = try trackerRecordsCoreData.map { try getRecord(from: $0) }
            return Set(trackerRecords)
        } catch {
            return Set<TrackerRecord>()
        }
    }
    
    func loadInitialData(date: String) {
        fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "%K CONTAINS[n] %@", #keyPath(TrackerCoreData.schedule), date)
        try? fetchedResultsController.performFetch()
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(
            TrackerStoreUpdate(
                insertedSections: insertedSections,
                deletedSections: deletedSections,
                updateSections: updateSections,
                insertedIndexes: insertedIndexPaths,
                deletedIndexPaths: deletedIndexPaths,
                updateIndexPaths: updateIndexPaths
            )
        )
        updatedIndexes()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            insertedSections.insert(sectionIndex)
        case .delete:
            deletedSections.insert(sectionIndex)
//        case .update:
//            updateSections.update(with: sectionIndex)
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
        case .delete:
            if let indexPath = indexPath {
                deletedIndexPaths.append(indexPath)
            }
        case .update:
            if let indexPath = indexPath {
                updateIndexPaths.append(indexPath)
            }
        default:
            break
        }
    }
}
