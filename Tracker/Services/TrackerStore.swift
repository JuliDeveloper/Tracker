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
    let movedIndexPaths: [(from: IndexPath, to: IndexPath)]
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
    private var movedIndexPaths = [(from: IndexPath, to: IndexPath)]()
    
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
        deletedIndexPaths = []
        deletedSections = IndexSet()
        updateIndexPaths = []
        updateSections = IndexSet()
        movedIndexPaths = []
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
    
    private func getTracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
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
    
    private func getTrackerCoreData(from tracker: Tracker) throws -> TrackerCoreData {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerId == %@", tracker.id as CVarArg)

        let trackers = try context.fetch(fetchRequest)
        return trackers.first ?? TrackerCoreData()
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
        let categoryCoreData = try trackerCategoryStore.getCategoryFromCoreData(with: category.categoryId)
        
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
    
    func editTracker(_ tracker: Tracker, _ newTitle: String?, _ category: TrackerCategory?, _ newSchedule: [WeekDay]?, _ newEmoji: String?, _ newColor: UIColor?) throws {
        
        guard let category else { return }
        
        let trackerCoreData = try getTrackerCoreData(from: tracker)
        trackerCoreData.title = newTitle
        trackerCoreData.schedule = WeekDay.weekdaysToString(weekdays: newSchedule)
        trackerCoreData.emoji = newEmoji
        trackerCoreData.colorHex = uiColorMarshalling.toHexString(color: newColor ?? UIColor())
        
        let oldCategory = trackerCoreData.category
        let newCategory = try trackerCategoryStore.getTrackerCategoryCoreData(from: category)
        
        if oldCategory != newCategory {
            oldCategory?.removeFromTrackers(trackerCoreData)
            newCategory.addToTrackers(trackerCoreData)
            
            trackerCoreData.category = newCategory
            
            if oldCategory?.title == "Закрепленные" && oldCategory?.trackers?.count == 0 {
                let pinnedCategory = try trackerCategoryStore.getTrackerCategory(from: oldCategory ?? TrackerCategoryCoreData())
                try trackerCategoryStore.deleteCategory(category: pinnedCategory)
            }
        }
        
        try context.save()
    }
    
    func isPinned(_ tracker: Tracker) -> Bool {
        if let pinnedCategory = trackerCategoryStore.categories.first(where: { $0.title == "Закрепленные" }) {
            return pinnedCategory.trackers.contains(where: { $0.id == tracker.id })
        }
        return false
    }

    func pinTracker(_ tracker: Tracker) throws {
        let trackerCoreData = try getTrackerCoreData(from: tracker)
        let pinnedCategory = try trackerCategoryStore.createPinnedCategory()

        let oldCategory = trackerCoreData.category
        let newCategory = try trackerCategoryStore.getTrackerCategoryCoreData(from: pinnedCategory)

        if oldCategory?.categoryId != newCategory.categoryId {
            UserDefaults.standard.set(oldCategory?.categoryId?.uuidString, forKey: tracker.id.uuidString)
            oldCategory?.removeFromTrackers(trackerCoreData)
            newCategory.addToTrackers(trackerCoreData)
            trackerCoreData.category = newCategory
        }
        
        try context.save()
    }
    
    func unpinTracker(_ tracker: Tracker) throws {
        let trackerCoreData = try getTrackerCoreData(from: tracker)
        
        if let originalCategoryIdString = UserDefaults.standard.string(forKey: tracker.id.uuidString),
           let originalCategoryId = UUID(uuidString: originalCategoryIdString) {
            
            let originalCategoryCoreData = try trackerCategoryStore.getCategoryFromCoreData(with: originalCategoryId)
            let originalCategory = try trackerCategoryStore.getTrackerCategory(from: originalCategoryCoreData)
            
            let oldCategory = trackerCoreData.category
            let newCategory = try trackerCategoryStore.getTrackerCategoryCoreData(from: originalCategory)
                        
            if oldCategory?.categoryId != newCategory.categoryId {
                oldCategory?.removeFromTrackers(trackerCoreData)
                newCategory.addToTrackers(trackerCoreData)
                trackerCoreData.category = newCategory
                
                if oldCategory?.trackers?.count == 0 {
                    let pinCategory = try trackerCategoryStore.getTrackerCategory(from: oldCategory ?? TrackerCategoryCoreData())
                    try trackerCategoryStore.deleteCategory(category: pinCategory)
                }
            }
        }
        
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
    
    func getRecords(from tracker: Tracker) -> Set<TrackerRecord> {
        guard let trackerCoreData = try? getTrackerCoreData(from: tracker) else { return Set<TrackerRecord>() }
        
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
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updatedIndexes()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(
            TrackerStoreUpdate(
                insertedSections: insertedSections,
                deletedSections: deletedSections,
                updateSections: updateSections,
                insertedIndexes: insertedIndexPaths,
                deletedIndexPaths: deletedIndexPaths,
                updateIndexPaths: updateIndexPaths,
                movedIndexPaths: movedIndexPaths
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
        case .update:
            updateSections.update(with: sectionIndex)
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
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                movedIndexPaths.append((from: indexPath, to: newIndexPath))
            }
        default:
            break
        }
    }
}
