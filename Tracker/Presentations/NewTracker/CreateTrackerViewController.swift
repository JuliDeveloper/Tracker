import UIKit

final class CreateTrackerViewController: UIViewController {
    
    //MARK: - Properties
    private lazy var habitButton: CustomButton = {
        let button = CustomButton(title: "Привычка")
        button.addTarget(
            self,
            action: #selector(addHabits),
            for: .touchUpInside
        )
        return button
    }()
    private lazy var irregularEventButton: CustomButton = {
        let button = CustomButton(title: "Нерегулярные событие")
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
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Создание трекера"
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
    
    @objc private func addHabits() {
        
    }
    
    @objc private func addIrregularEvent() {
        
    }
}
