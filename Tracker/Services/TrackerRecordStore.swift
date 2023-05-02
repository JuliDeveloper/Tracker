import Foundation
import CoreData

enum TrackerRecordsStoreError: Error {
    case notFoundObjectError
    case decodingErrorInvalidId
    case decodingErrorInvalidDate
}

final class TrackerRecordsStore: NSObject {
    
    //MARK: - Properties
    private let context: NSManagedObjectContext
    
    // MARK: - Lifecycle
    convenience override init() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
}

//MARK: - TrackerRecordsStoreProtocol
extension TrackerRecordsStore: TrackerRecordsStoreProtocol {
    func saveRecord(_ record: TrackerRecord) throws {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.trackerId), record.trackerId as CVarArg)
        guard let trackerCoreData = try? context.fetch(request).first else {
            throw TrackerRecordsStoreError.notFoundObjectError
        }
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.trackerId = record.trackerId
        trackerRecordCoreData.date = record.date
        trackerRecordCoreData.tracker = trackerCoreData
        try context.save()
    }
    
    func deleteRecord(_ record: TrackerRecord) throws {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%K == %@ AND %K == %@", #keyPath(TrackerRecordCoreData.tracker.trackerId), record.trackerId as CVarArg, #keyPath(TrackerRecordCoreData.date), record.date as CVarArg)
        guard let recordCoreData = try? context.fetch(request).first else {
            throw TrackerRecordsStoreError.notFoundObjectError
        }
        context.delete(recordCoreData)
        try context.save()
    }
}
