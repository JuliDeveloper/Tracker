import Foundation

struct Schedule {
    let weekDays: [WeekDay]
}

enum WeekDay: Int {
    case monday = 1 //"Понедельник"
    case tuesday = 2 //"Вторник"
    case wednesday = 3 //"Среда"
    case thursday = 4 //"Четверг"
    case friday = 5 //"Пятница"
    case saturday = 6 //"Суббота"
    case sunday = 7 //"Воскресенье"
}
