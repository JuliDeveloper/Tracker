import Foundation

enum WeekDay: String, CaseIterable {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
    
    var abbreviationValue: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
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
