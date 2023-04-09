import Foundation

class DataManager {
    static let shared = DataManager()
    
    var category = TrackerCategory(
        title: "Радостные мелочи",
        trackers: [
            Tracker(
                id: UUID(),
                title: "Поливать растения",
                color: .ypColorSection5,
                emoji: "❤️",
                schedule: [WeekDay.monday, WeekDay.saturday]
            ),
            Tracker(
                id: UUID(),
                title: "Свидание в апреле",
                color: .ypColorSection14,
                emoji: "🌺",
                schedule: [WeekDay.tuesday, WeekDay.friday]
            )
        ]
    )
    
    func getCategories() -> [TrackerCategory] {
        var dataCategories: [TrackerCategory] = []
        
        dataCategories.append(category)
        
        return dataCategories
    }
    
    private init() {}
}
