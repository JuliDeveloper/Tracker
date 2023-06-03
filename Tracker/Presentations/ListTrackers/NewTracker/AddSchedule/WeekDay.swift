import Foundation

enum WeekDay: String, CaseIterable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    var localizedName: String {
        NSLocalizedString(rawValue, comment: "")
    }
    
    var abbreviationValue: String {
        return NSLocalizedString(String(self.rawValue.prefix(3)), comment: "")
    }
    
    var numberValue: Int {
        switch self {
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        case .sunday: return 1
        }
    }
    
    static func weekdaysToString(weekdays: [WeekDay]?) -> String? {
        guard let weekdays = weekdays else { return nil }
        let weekdayNumbers = weekdays.map { String($0.numberValue) }
        return weekdayNumbers.joined(separator: ",")
    }

    static func stringToWeekdays(string: String?) -> [WeekDay]? {
        guard let string = string else { return nil }
        let weekdayNumbers = string.split(separator: ",").map { Int(String($0)) }
        let weekdays = weekdayNumbers.compactMap { (number) -> WeekDay? in
            guard let number = number else { return nil }
            return WeekDay.allCases.first { $0.numberValue == number }
        }
        return weekdays
    }
}
