import UIKit

final class AddCategoryViewController: UIViewController {
    //MARK: - Properties
    private let defaultStack = DefaultStackView(
        title: "Привычки и события можно объединить по смыслу"
    )
    private let button = CustomButton(title: "Добавить категорию")
    
    var categories: [String] = []
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        title = "Категория"
        
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.ypFontMedium16,
            .foregroundColor: UIColor.ypBlack
        ]
        
        addElements()
        setupConstraints()
        showScenario()
    
        button.addTarget(self, action: #selector(addCategory), for: .touchUpInside)
    }
    
    //MARK: - Helpers
    private func addElements() {
        view.addSubview(defaultStack)
        view.addSubview(button)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            defaultStack.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            defaultStack.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
            
            button.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20
            ),
            button.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20
            ),
            button.bottomAnchor.constraint(
                equalTo: view.bottomAnchor, constant: -50
            )
        ])
    }
    
    private func showScenario() {
        if categories.isEmpty {
            defaultStack.isHidden = false
        } else {
            defaultStack.isHidden = true
        }
    }
    
    @objc private func addCategory() {
        let newCategoryVC = AddNewCategoryViewController()
        let navVC = UINavigationController(rootViewController: newCategoryVC)
        present(navVC, animated: true)
    }
}
