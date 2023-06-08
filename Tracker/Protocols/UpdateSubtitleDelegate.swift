import Foundation

protocol UpdateSubtitleDelegate: AnyObject {
    func updateCategorySubtitle(from string: String?, and indexPath: IndexPath?)
    func updateScheduleSubtitle(from weekDays: [WeekDay]?)
}
