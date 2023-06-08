import Foundation

protocol ListTrackersViewControllerDelegate: AnyObject {
    func getDate() -> Date
    func updateStateFromDate() -> Date
    func resetDatePicker(_ today: Date)
    func completedTracker(_ trackerId: UUID, _ trackerRecords: Set<TrackerRecord>) -> Bool
    func updateCompletedTrackers(_ tracker: Tracker, _ countDays: Int)
    func updateCompletedTrackers(cell: TrackerCell,  _ tracker: Tracker)
    func filteringCompletedTrackers()
    func filteringUncompletedTrackers()
    func updateCollectionView()
    func getPinnedTracker(_ tracker: Tracker) -> Bool
}
