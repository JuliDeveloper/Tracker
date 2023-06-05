import UIKit

final class TabBarController: UITabBarController {
    
    //MARK: - Lifecycle
    override func loadView() {
        super.loadView()

        let listTrackers = ListTrackersViewController()
        listTrackers.tabBarItem = UITabBarItem(
            title: S.Trackers.title,
            image: UIImage(named: "record.circle.fill"),
            selectedImage: nil
        )
        
        let statistic = UINavigationController(rootViewController: StatisticsViewController())
        statistic.tabBarItem = UITabBarItem(
            title: S.Statistic.title,
            image: UIImage(named: "hare.fill"),
            selectedImage: nil
        )
        
        tabBar.tintColor = .ypBlue
        viewControllers = [listTrackers, statistic]
    }
}
