import Foundation

protocol ListTrackersViewControllerDelegate: AnyObject {
    func getDate() -> Date
    func updateButtonStateFromDate() -> Date
    func completedTracker(_ trackerId: UUID, _ trackerRecords: Set<TrackerRecord>) -> Bool
    func updateCompletedTrackers(_ tracker: Tracker)
    func updateCompletedTrackers(cell: TrackerCell,  _ tracker: Tracker)
    func updateCollectionView()
    func getPinnedTracker(_ tracker: Tracker) -> Bool
}
