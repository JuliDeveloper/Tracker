import UIKit

final class AddNewTrackerViewController: UIViewController {
    //MARK: - Properties
    private let mainTableView = UITableView()
        
    private let buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
        
    private lazy var cancelButton: CustomButton = {
        let button = CustomButton(title: "Отменить")
        button.backgroundColor = .ypWhite
        button.setTitleColor(.ypRed, for: .normal)
        button.clipsToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton: CustomButton = {
        let button = CustomButton(title: "Создать")
        button.setTitleColor(.ypDefaultWhite, for: .normal)
        button.backgroundColor = .ypGray
        button.addTarget(self, action: #selector(create), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: TitleTrackerCellDelegate?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        addElements()
        configureNavBar()
        configureMainTableView()
        setupConstraints()
    }
    
    //MARK: - Helpers
    private func configureNavBar() {
        title = "Новая привычка"
        
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.ypFontMedium16,
            .foregroundColor: UIColor.ypBlack
        ]
    }
    
    private func configureMainTableView() {
        mainTableView.delegate = self
        mainTableView.dataSource = self
        
        mainTableView.register(
            TitleTrackerCell.self,
            forCellReuseIdentifier: Constants.titleTrackerCellIdentifier
        )
        mainTableView.register(
            FilterTableViewCell.self,
            forCellReuseIdentifier: Constants.filterCellIdentifier
        )
        
        mainTableView.backgroundColor = .red
        mainTableView.separatorStyle = .none
        
        mainTableView.translatesAutoresizingMaskIntoConstraints = false
        mainTableView.backgroundColor = .ypWhite
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        mainTableView.addGestureRecognizer(tapGesture)
    }
    
    private func addElements() {
        view.addSubview(mainTableView)
        view.addSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(createButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainTableView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor),
            
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    @objc private func tableViewTapped() {
        view.endEditing(true)
    }
    
    @objc private func cancel() {
        dismiss(animated: true)
    }
    
    @objc private func create() {
        dismiss(animated: true)
    }
}

extension AddNewTrackerViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        default:
            break
        }
        
        return Int()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 99
        } else if indexPath.section == 1 {
            return 174
        }
        
        return CGFloat()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            guard
                let titleCell = tableView.dequeueReusableCell(
                    withIdentifier: Constants.titleTrackerCellIdentifier,
                    for: indexPath) as? TitleTrackerCell
            else { return UITableViewCell() }
            titleCell.configureCell(delegate: self)
            delegate = titleCell
            return titleCell
        case 1:
            guard
                let filterCell = tableView.dequeueReusableCell(
                    withIdentifier: Constants.filterCellIdentifier,
                    for: indexPath) as? FilterTableViewCell
            else { return UITableViewCell() }
            filterCell.configureCell()
            filterCell.delegate = self
            return filterCell
        default:
            break
        }
        
        return UITableViewCell()
    }
}

extension AddNewTrackerViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if newText.count > 38 {
            mainTableView.performBatchUpdates {
                self.delegate?.updateCell(state: false)
            }
        } else {
            mainTableView.performBatchUpdates {
                self.delegate?.updateCell(state: true)
            }
        }
        
        return newText.count <= 38
    }
}

extension AddNewTrackerViewController: AddNewTrackerViewControllerDelegate {
    func showViewController() {
        let viewController = AddCategoryViewController()
        let navVC = UINavigationController(rootViewController: viewController)
        present(navVC, animated: true)
    }
}
