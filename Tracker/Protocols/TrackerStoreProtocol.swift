import UIKit

protocol TrackerStoreProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func headerTitleSection(_ section: Int) -> String?
    func getTracker(at indexPath: IndexPath) -> Tracker?
    func addNewTracker(from tracker: Tracker, and category: TrackerCategory) throws
    func editTracker(_ tracker: Tracker, _ newTitle: String?, _ newCategory: TrackerCategory?, _ newSchedule: [WeekDay]?, _ newEmoji: String?, _ newColor: UIColor?, _ countDays: Int) throws
    func isPinned(_ tracker: Tracker) -> Bool
    func pinTracker(_ tracker: Tracker) throws
    func unpinTracker(_ tracker: Tracker) throws
    func deleteTracker(at indexPath: IndexPath) throws
    func trackerFiltering(from currentDate: String?, or searchText: String?)
    func fetchAllRecords() throws -> [TrackerRecordCoreData]
    func filterCompletedTrackers(for ids: [UUID])
    func filterUncompletedTrackers(for ids: [UUID])
    func getCompletedTrackers(forDate date: Date) -> [TrackerRecord]
    func getRecords(from tracker: Tracker) -> Set<TrackerRecord>
    func getRecords(for trackerIndexPath: IndexPath) -> Set<TrackerRecord>
    func loadInitialData(date: String)
    func setDelegate(_ vc: ListTrackersViewController)
}
