import UIKit

final class TabBarController: UITabBarController {
    
    //MARK: - Lifecycle
    override func loadView() {
        super.loadView()
        let listTrackers = ListTrackersViewController()
        listTrackers.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "record.circle.fill"),
            selectedImage: nil
        )
        
        let statistic = StatisticsViewController()
        statistic.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "hare.fill"),
            selectedImage: nil
        )
        
        tabBar.tintColor = .ypBlue
        viewControllers = [listTrackers, statistic]
    }
}
