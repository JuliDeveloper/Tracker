import UIKit

final class TabBarController: UITabBarController {
    
    //MARK: - Lifecycle
    override func loadView() {
        super.loadView()
        
        let listTitle = NSLocalizedString("trackers.title", comment: "")
        let statisticTitle = NSLocalizedString("statistic.title", comment: "")

        let listTrackers = ListTrackersViewController()
        listTrackers.tabBarItem = UITabBarItem(
            title: listTitle,
            image: UIImage(named: "record.circle.fill"),
            selectedImage: nil
        )
        
        let statistic = StatisticsViewController()
        statistic.tabBarItem = UITabBarItem(
            title: statisticTitle,
            image: UIImage(named: "hare.fill"),
            selectedImage: nil
        )
        
        tabBar.tintColor = .ypBlue
        viewControllers = [listTrackers, statistic]
    }
}
