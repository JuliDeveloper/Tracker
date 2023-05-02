import Foundation

protocol TrackerStoreProtocol {
    var countTrackers: Int { get }
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func headerTitleSection(_ section: Int) -> String?
    func getTracker(at indexPath: IndexPath) -> Tracker?
    func addNewTracker(from tracker: Tracker, and category: TrackerCategory) throws
    func deleteTracker(at indexPath: IndexPath) throws
    func trackerFiltering(from currentDate: String?, or searchText: String?)
    func getRecords(for trackerIndexPath: IndexPath) -> Set<TrackerRecord>
}
