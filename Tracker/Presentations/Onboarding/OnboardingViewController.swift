import UIKit

final class OnboardingViewController: UIPageViewController {
    
    //MARK: - Properties
    private lazy var pages: [UIViewController] = {
        let bluePage = CustomViewController(imageTitle: "pageBlue")
        let redPage = CustomViewController(imageTitle: "pageRed")
        
        return [bluePage, redPage]
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ypFontBold32
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let onboardingStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = .ypDefaultBlack
        pageControl.pageIndicatorTintColor = .ypDefaultBlack.withAlphaComponent(0.3)
        
        return pageControl
    }()
    
    private let openListTrackerButton = CustomButton(title: "Вот это технологии!")
    
    //MARK: - Lifecycle
    init() {
        super.init(transitionStyle: .scroll,
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
            titleLabel.text = "Отслеживайте только то, что хотите"
            setViewControllers([firstVC], direction: .forward, animated: true)
        }
        
        addElements()
        setConstraints()
        
        openListTrackerButton.addTarget(
            self,
            action: #selector(openTrackers),
            for: .touchUpInside
        )
    }
    
    //MARK: - Helpers
    private func addElements() {
        view.addSubview(titleLabel)
        view.addSubview(onboardingStack)
        
        onboardingStack.addArrangedSubview(pageControl)
        onboardingStack.addArrangedSubview(openListTrackerButton)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            onboardingStack.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20
            ),
            onboardingStack.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20
            ),
            onboardingStack.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -71
            ),
            
            titleLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 16
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -16
            ),
            titleLabel.bottomAnchor.constraint(
                equalTo: onboardingStack.topAnchor, constant: -130
            )
        ])
    }
    
    @objc private func openTrackers() {
        let tabBarVC = TabBarController()
        tabBarVC.modalPresentationStyle = .fullScreen
        present(tabBarVC, animated: true)
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
            
            switch currentIndex {
            case 0:
                titleLabel.text = "Отслеживайте только то, что хотите"
            case 1:
                titleLabel.text = "Даже если это не литры воды и йога"
            default:
                break
            }
        }
    }
}
