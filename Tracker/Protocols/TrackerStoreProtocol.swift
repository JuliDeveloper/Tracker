import UIKit

protocol TrackerStoreProtocol {
    var countTrackers: Int { get }
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func headerTitleSection(_ section: Int) -> String?
    func getTracker(at indexPath: IndexPath) -> Tracker?
    func addNewTracker(from tracker: Tracker, and category: TrackerCategory) throws
    func editTracker(_ tracker: Tracker, _ newTitle: String?, _ newCategory: TrackerCategory?, _ newSchedule: [WeekDay]?, _ newEmoji: String?, _ newColor: UIColor?) throws
    func deleteTracker(at indexPath: IndexPath) throws
    func trackerFiltering(from currentDate: String?, or searchText: String?)
    func getRecords(from tracker: Tracker) -> Set<TrackerRecord>
    func getRecords(for trackerIndexPath: IndexPath) -> Set<TrackerRecord>
    func loadInitialData(date: String)
}
