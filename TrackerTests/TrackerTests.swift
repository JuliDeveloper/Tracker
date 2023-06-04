import XCTest
import SnapshotTesting
@testable import Tracker

private class TrackerStoreTest: TrackerStoreProtocol {
    private static let category = TrackerCategory(
        title: "Радостные мелочи",
        trackers: [
            Tracker(
                id: UUID(),
                title: "Кошка заслонила камеру на созвоне",
                color: .ypColorSection17,
                emoji: "😻",
                schedule: nil,
                countRecords: 0
            ),
            Tracker(
                id: UUID(),
                title: "Бабушка прислала открытку в вотсапе",
                color: .ypColorSection10,
                emoji: "🌺",
                schedule: nil,
                countRecords: 0
            ),
            Tracker(
                id: UUID(),
                title: "Свидания в апреле",
                color: .ypColorSection5,
                emoji: "❤️",
                schedule: nil,
                countRecords: 0
            )
        ],
        categoryId: UUID()
    )
    
    var countTrackers: Int = 3
    var numberOfSections: Int = 1
    func numberOfRowsInSection(_ section: Int) -> Int {
        3
    }
    
    func headerTitleSection(_ section: Int) -> String? {
        TrackerStoreTest.category.title
    }
    
    func getTracker(at indexPath: IndexPath) -> Tracker? {
        let tracker = TrackerStoreTest.category.trackers[indexPath.row]
        return tracker
    }
    
    func addNewTracker(from tracker: Tracker, and category: TrackerCategory) throws {}
    
    func editTracker(_ tracker: Tracker, _ newTitle: String?, _ newCategory: TrackerCategory?, _ newSchedule: [WeekDay]?, _ newEmoji: String?, _ newColor: UIColor?, countDays: Int) throws {}
    
    func isPinned(_ tracker: Tracker) -> Bool {
        false
    }
    
    func pinTracker(_ tracker: Tracker) throws {}
    
    func unpinTracker(_ tracker: Tracker) throws {}
    
    func deleteTracker(at indexPath: IndexPath) throws {}
    
    func trackerFiltering(from currentDate: String?, or searchText: String?) {}
    
    func getRecords(from tracker: Tracker) -> Set<TrackerRecord> {
        Set<TrackerRecord>()
    }
    
    func getRecords(for trackerIndexPath: IndexPath) -> Set<TrackerRecord> {
        Set<TrackerRecord>()
    }
    
    func loadInitialData(date: String) {}
    
    var delegate: TrackerStoreDelegate?
}

final class TrackerTests: XCTestCase {

    func testViewControllerLightStyle() throws {
        let viewController = ListTrackersViewController(trackerStore: TrackerStoreTest())
        assertSnapshot(matching: viewController, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
    
    func testViewControllerDarkStyle() throws {
        let viewController = ListTrackersViewController(trackerStore: TrackerStoreTest())
        assertSnapshot(matching: viewController, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
    
}
