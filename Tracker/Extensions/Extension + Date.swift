
import Foundation

extension Date {
    func currentDayOfWeek() -> String {
        let currentDate = getDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        return dateFormatter.string(from: currentDate)
    }

    func getDate() -> Date {
        let calendar = Calendar.current
        let selectedDate = Date()
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        guard let currentDate = calendar.date(from: dateComponents) else { return Date()}
        return currentDate
    }
    
}
