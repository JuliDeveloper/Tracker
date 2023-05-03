import Foundation

protocol TrackerRecordsStoreProtocol {
    func saveRecord(_ record: TrackerRecord) throws
    func deleteRecord(_ record: TrackerRecord) throws
}
