import UIKit

final class AddNewCategoryViewController: UIViewController {
    
    //MARK: - Properties
    private let textField = CustomTextField(text: "Введите название категории")
    private let button = CustomButton(title: "Готово")
    
    weak var delegate: AddCategoryViewControllerDelegate?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        title = "Новая категория"
        
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.ypFontMedium16,
            .foregroundColor: UIColor.ypBlack
        ]
        
        textField.delegate = self
        
        addElements()
        showScenario()
        
        setStateButton(for: textField)
        
        textField.addTarget(
            self,
            action: #selector(checkTextField),
            for: .editingChanged
        )
        
        button.addTarget(
            self,
            action: #selector(saveNewCategory),
            for: .touchUpInside
        )
    }
    
    //MARK: - Helpers
    private func addElements() {
        view.addSubview(textField)
        view.addSubview(button)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 16
            ),
            textField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -16
            ),
            textField.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24
            ),
            
            button.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20
            ),
            button.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20
            )
        ])
    }
    
    private func setupConstraintForDefaultScreen() {
        button.bottomAnchor.constraint(
            equalTo: view.bottomAnchor, constant: -50
        ).isActive = true
        
        setupConstraints()
    }
    
    private func setupConstraintsForSEScreen() {
        button.bottomAnchor.constraint(
            equalTo: view.bottomAnchor, constant: -24
        ).isActive = true
        
        setupConstraints()
    }
    
    private func showScenario() {
        if 568 <= UIScreen.main.bounds.size.height,
           UIScreen.main.bounds.size.height <= 667 {
            setupConstraintsForSEScreen()
        } else {
            setupConstraintForDefaultScreen()
        }
    }
    
    private func setStateButton(for textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            button.backgroundColor = .ypBlack
        } else {
            button.backgroundColor = .ypGray
        }
    }
    
    @objc private func checkTextField() {
        setStateButton(for: textField)
    }
    
    @objc private func saveNewCategory() {
        let newTitleCategory = textField.text ?? ""
        let newCategory = TrackerCategory(title: newTitleCategory, trackers: [])
        
        delegate?.updateListCategories(newCategory: newCategory)
        
        dismiss(animated: true)
    }
}

//MARK: - UITextFieldDelegate
extension AddNewCategoryViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
