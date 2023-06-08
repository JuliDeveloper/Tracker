import UIKit

final class CreateTrackerViewController: UIViewController {
    
    //MARK: - Properties
    private lazy var habitButton: CustomButton = {
        let button = CustomButton(title: S.Button.Habit.title)
        button.addTarget(
            self,
            action: #selector(addHabits),
            for: .touchUpInside
        )
        return button
    }()
    private lazy var irregularEventButton: CustomButton = {
        let button = CustomButton(title: S.Button.IrregularEvent.title)
        button.addTarget(
            self,
            action: #selector(addIrregularEvent),
            for: .touchUpInside
        )
        return button
    }()
    
    private let buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    weak var updateDelegate: ListTrackersViewControllerDelegate?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = S.NavBar.CreateTracker.title
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.ypFontMedium16,
            .foregroundColor: UIColor.ypBlack
        ]
        
        view.backgroundColor = .ypWhite
        view.addSubview(buttonsStackView)
        
        configureStackView()
    }
    
    //MARK: - Helpers
    private func configureStackView() {
        buttonsStackView.addArrangedSubview(habitButton)
        buttonsStackView.addArrangedSubview(irregularEventButton)
        
        NSLayoutConstraint.activate([
            buttonsStackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20
            ),
            buttonsStackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20
            ),
            buttonsStackView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            )
        ])
    }
    
    private func showViewController(with array: [String], isIrregular: Bool, isEditTracker: Bool) {
        let addTrackerVC = AddNewTrackerViewController()
        addTrackerVC.updateDelegate = updateDelegate
        addTrackerVC.titlesCells = array
        addTrackerVC.isIrregular = isIrregular
        
        let navTitle = isIrregular ? S.NavBar.NewIrregularEvent.title : S.NavBar.NewHabit.title
        addTrackerVC.title = navTitle
        
        navigationController?.pushViewController(addTrackerVC, animated: true)
    }
    
    @objc private func addHabits() {
        showViewController(
            with: Constants.isHabitTitlesCells,
            isIrregular: false,
            isEditTracker: false
        )
    }
    
    @objc private func addIrregularEvent() {        
        showViewController(
            with: Constants.isIrregularTitlesCells,
            isIrregular: true,
            isEditTracker: false
        )
    }
}
