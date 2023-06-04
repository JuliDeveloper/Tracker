import UIKit

struct Constants {
    static let smallRadius: CGFloat = 8
    static let mediumRadius: CGFloat = 10
    static let bigRadius: CGFloat = 16
    
    static let taskCellIdentifier = "taskCell"
    static let headerCellIdentifier = "header"
    static let cellIdentifier = "cell"
    static let categoryCellIdentifier = "categoryCell"
    static let weekDayCellIdentifier = "weekDayCell"
    static let filteringCellIdentifier = "filteringCell"
    
    static let cellCollectionView = "cellCollectionView"

    static let emojis = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶",
        "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]
    static let colors: [UIColor] = UIColor.getColors()
}
