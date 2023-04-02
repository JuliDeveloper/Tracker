import Foundation

class DataManager {
    static let shared = DataManager()
    
    func getCategories() -> [TrackerCategory] {
        var dataCategories: [TrackerCategory] = []
        
        let category = TrackerCategory(
            title: "Радостные мелочи",
            trackers: [
                Tracker(
                    id: UUID(),
                    title: "Поливать растения",
                    color: .ypColorSection5,
                    emoji: "❤️",
                    schedule: nil
                ),
                Tracker(
                    id: UUID(),
                    title: "Свидание в апреле",
                    color: .ypColorSection14,
                    emoji: "🌺",
                    schedule: nil
                )
            ]
        )
        
        dataCategories.append(category)
        
        return dataCategories
    }
    
    private init() {}
}
