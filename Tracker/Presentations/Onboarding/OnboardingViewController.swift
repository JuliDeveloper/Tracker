import UIKit

final class OnboardingViewController: UIPageViewController {
    
    //MARK: - Properties
    private lazy var pages: [UIViewController] = {
        let bluePage = CustomViewController(
            imageTitle: "pageBlue",
            textLabel: "Отслеживайте только то, что хотите"
        )
        let redPage = CustomViewController(
            imageTitle: "pageRed",
            textLabel: "Даже если это не литры воды и йога"
        )
        
        return [bluePage, redPage]
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .ypDefaultBlack
        pageControl.pageIndicatorTintColor = .ypDefaultBlack.withAlphaComponent(0.3)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let firstVC = pages.first {
            setViewControllers([firstVC], direction: .forward, animated: true)
        }
        
        view.addSubview(pageControl)
        setConstraints()
    }
    
    //MARK: - Helpers
    private func setConstraints() {
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            pageControl.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -155
            )
        ])
    }
}

//MARK: - UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = vcIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = vcIndex + 1
        
        guard nextIndex < pages.count else {
            return nil
        }
        
        return pages[nextIndex]
    }
}

//MARK: - UIPageViewControllerDelegate
extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let currentVC = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentVC) {
            pageControl.currentPage = currentIndex
        }
    }
}
