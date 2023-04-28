import UIKit
import CoreData

enum TrackerCategoryStoreError: Error {
    case decodingErrorInvalidTitle
    case decodingErrorInvalidTrackers
    case dataNotReceived
    case errorFetchingCategories
}

final class TrackerCategoryStore: NSObject {
    
    //MARK: - Properties
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    
    private(set) lazy var categories: [TrackerCategory] = {
        do {
            return try fetchCategories()
        } catch {
            print(TrackerCategoryStoreError.errorFetchingCategories)
            return []
        }
    }()

    //MARK: - LifeCycle
    convenience override init() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        try! self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
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
