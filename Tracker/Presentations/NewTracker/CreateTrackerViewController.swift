import UIKit

final class CreateTrackerViewController: UIViewController {
    
    private let habitButton = CustomButton(title: "Привычка")
    private let irregularEventButton = CustomButton(title: "Нерегулярные событие")
    
    private let buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
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
}
