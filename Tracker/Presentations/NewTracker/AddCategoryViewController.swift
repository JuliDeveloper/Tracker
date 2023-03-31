import UIKit

final class AddCategoryViewController: UIViewController {
    
    private let defaultStack = DefaultStackView(
        title: "Привычки и события можно объединить по смыслу"
    )
    private let button = CustomButton(title: "")
    
    var categories: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        title = "Категория"
        
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.ypFontMedium16,
            .foregroundColor: UIColor.ypBlack
        ]
        
        view.addSubview(defaultStack)
        view.addSubview(button)
        
        if categories.isEmpty {
            button.setTitle("Добавить категорию", for: .normal)
        } else {
            button.setTitle("Готово", for: .normal)

        }
        
        
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
        
        if categories.isEmpty {
            defaultStack.isHidden = false
        }
    }
}
