import UIKit

protocol NewTitleTrackerCellDelegate: AnyObject {
    func updateTrackerTitle(_ newText: String)
}

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
        button.isEnabled = false
        button.addTarget(self, action: #selector(create), for: .touchUpInside)
        return button
    }()
    
    private var tracker: Tracker = Tracker(id: UUID(), title: "", color: .red, emoji: "", schedule: nil)
    private var trackerTitle = ""
    
    weak var delegate: TitleTrackerCellDelegate?
    weak var updateDelegate: ListTrackersViewControllerDelegate?
    
    let colors: [UIColor] = [.ypColorSection4, .ypColorSection15, .ypColorSection7]
    
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
        self.navigationItem.setHidesBackButton(true, animated: true)
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
    
    private func saveTracker() {
        let dataManager = DataManager.shared
        let categoryToUpdate = dataManager.category
        
        let color = colors.randomElement() ?? UIColor()
        let newTracker = Tracker(id: UUID(), title: trackerTitle, color: color, emoji: "🐶", schedule: nil)
        let newTrackers = categoryToUpdate.trackers + [newTracker]

        let updatedCategory = TrackerCategory(
            title: categoryToUpdate.title,
            trackers: newTrackers
        )
        
        var categories = dataManager.getCategories()

        if let index = dataManager.getCategories().firstIndex(where: { $0.title == categoryToUpdate.title }) {
            categories[index] = updatedCategory
            
            dataManager.category = updatedCategory
            dataManager.category = categories[index]
        }
    }
    
    @objc private func cancel() {
        dismiss(animated: true)
    }
    
    @objc private func create() {
        saveTracker()
        updateDelegate?.updateCollectionView()
        let tabBar = TabBarController()
        tabBar.modalPresentationStyle = .fullScreen
        present(tabBar, animated: true)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.titleTrackerCellIdentifier) as! TitleTrackerCell
            cell.configureCell(delegate: self)
            
            let size = cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            return size.height
        } else {
            return 175
        }
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
            titleCell.delegateUpdateTitle = self
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
        
        if newText.count >= 1 {
            createButton.backgroundColor = .ypBlack
            createButton.isEnabled = true
        } else {
            createButton.backgroundColor = .ypGray
            createButton.isEnabled = false
        }
        
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
    func showViewController(_ viewController: UIViewController) {
        let viewController = viewController
        let navVC = UINavigationController(rootViewController: viewController)
        present(navVC, animated: true)
    }
}

extension AddNewTrackerViewController: NewTitleTrackerCellDelegate {
    func updateTrackerTitle(_ newText: String) {
        trackerTitle = newText
    }
}
