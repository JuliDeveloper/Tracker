import UIKit

final class OnboardingSinglePageController: UIPageViewController {
    
    //MARK: - Properties
    private lazy var pages: [UIViewController] = {
        let bluePage = CustomViewController(
            imageTitle: "pageBlue",
            textLabel: S.Onboarding.firstTitle
        )
        let redPage = CustomViewController(
            imageTitle: "pageRed",
            textLabel: S.Onboarding.secondTitle
        )
        
        return [bluePage, redPage]
    }()
    
    private let onboardingStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var openListTrackerButton: UIButton = {
        let button = CustomButton(title: S.Onboarding.Button.title)
        button.backgroundColor = .ypDefaultBlack
        button.setTitleColor(.ypDefaultWhite, for: .normal)
        button.addTarget(
            self,
            action: #selector(openTrackers),
            for: .touchUpInside
        )
        return button
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
    init() {
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let firstVC = pages.first {
            setViewControllers([firstVC], direction: .forward, animated: true)
        }
        
        addElements()
        setConstraints()
    }
    
    //MARK: - Helpers
    private func addElements() {
        view.addSubview(onboardingStackView)
        
        onboardingStackView.addArrangedSubview(pageControl)
        onboardingStackView.addArrangedSubview(openListTrackerButton)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            onboardingStackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20
            ),
            onboardingStackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20
            ),
            onboardingStackView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -71
            )
        ])
    }
    
    @objc private func openTrackers() {
        let tabBarVC = TabBarController()
        
        let window = UIApplication.shared.windows.first
        window?.rootViewController = tabBarVC
        window?.makeKeyAndVisible()
    }
}

//MARK: - UIPageViewControllerDataSource
extension OnboardingSinglePageController: UIPageViewControllerDataSource {
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
extension OnboardingSinglePageController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let currentVC = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentVC) {
            pageControl.currentPage = currentIndex
        }
    }
}
