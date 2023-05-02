import Foundation

protocol ListTrackersViewControllerDelegate: AnyObject {
    func updateButtonStateFromDate() -> Date
    func completedTracker(_ trackerId: UUID, _ trackerRecords: Set<TrackerRecord>) -> Bool
    func updateCompletedTrackers(cell: TrackerCell,  _ tracker: Tracker)
}
