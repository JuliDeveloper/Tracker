import Foundation

protocol ListTrackersViewControllerDelegate: AnyObject {
    func updateCollectionView()
    func updateButtonStateFromDate() -> Date
    func updateCompletedTrackers(tracker: Tracker)
}
