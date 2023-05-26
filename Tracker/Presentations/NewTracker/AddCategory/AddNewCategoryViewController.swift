import UIKit

final class AddNewCategoryViewController: UIViewController {
    
    //MARK: - Properties
    private let textField: CustomTextField = {
        let placeholder = NSLocalizedString("textField.newHabit.placeholder", comment: "")
        let textField = CustomTextField(text: placeholder)
        return textField
    }()
    
    private let button: CustomButton = {
        let title = NSLocalizedString("done", comment: "")
        let button = CustomButton(title: title)
        return button
    }()
    
    private var viewModel: AddCategoryViewModel
    
    var text: String?
    var category: TrackerCategory?
    weak var delegate: AddCategoryViewControllerDelegate?
    
    //MARK: - Lifecycle
    init(viewModel: AddCategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        title = NSLocalizedString("navBar.addNewCategory.title", comment: "")
        
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.ypFontMedium16,
            .foregroundColor: UIColor.ypBlack
        ]
        
        textField.delegate = self
        textField.returnKeyType = .done
        textField.text = text
        
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
        
        if category == nil {
            let newCategory = TrackerCategory(
                title: newTitleCategory,
                trackers: [],
                categoryId: UUID()
            )
            viewModel.add(category: newCategory)
        } else {
            guard let category else { return }
            viewModel.edit(category: category, newTitle: newTitleCategory)
            delegate?.updateTableView()
        }
        
        dismiss(animated: true)
    }
}

//MARK: - UITextFieldDelegate
extension AddNewCategoryViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
