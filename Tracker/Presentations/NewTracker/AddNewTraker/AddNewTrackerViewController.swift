import UIKit

final class AddNewTrackerViewController: UIViewController {
    
    //MARK: - Properties
    private let scrollView = UIScrollView()
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
    
    private let titleStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let trackerTitleTextField = CustomTextField(
        text: "Введите название трекера"
    )
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.font = UIFont.ypFontMedium17
        label.textColor = .ypRed
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView = UITableView()
    
    private let titlesCells = ["Категория", "Расписание"]
    private let colors: [UIColor] = [.ypColorSection4, .ypColorSection15, .ypColorSection7]
    
    private var trackerTitle = ""
    private var categorySubtitle = ""
    private var currentIndexCategory: IndexPath?
    private var setSchedule = [WeekDay]()
    private var currentSwitchStates = [Int: Bool]()
    
    weak var updateDelegate: ListTrackersViewControllerDelegate?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        configureNavBar()
        addElements()
        configureScrollView()
        configureTableView()
        configureTextField()
        setupConstraints()
    }
    
    //MARK: - Helpers
    private func addElements() {
        view.addSubview(buttonsStackView)
        view.addSubview(scrollView)
        
        scrollView.addSubview(titleStackView)
        scrollView.addSubview(tableView)
        
        titleStackView.addArrangedSubview(trackerTitleTextField)
        
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(createButton)
    }
    
    private func configureNavBar() {
        title = "Новая привычка"
        
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.ypFontMedium16,
            .foregroundColor: UIColor.ypBlack
        ]
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    private func configureScrollView() {
        scrollView.frame = view.bounds
        scrollView.contentSize = CGSize(width: view.bounds.width, height: view.bounds.height)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .ypWhite
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellIdentifier)
        
        tableView.separatorStyle = .singleLine
        
        tableView.backgroundColor = .ypBackground
        tableView.layer.cornerRadius = Constants.bigRadius
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureTextField() {
        trackerTitleTextField.delegate = self
        trackerTitleTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            buttonsStackView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),
            buttonsStackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 16
            ),
            buttonsStackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -16
            ),
            
            scrollView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            scrollView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            scrollView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            scrollView.bottomAnchor.constraint(
                equalTo: buttonsStackView.topAnchor
            ),
            
            titleStackView.topAnchor.constraint(
                equalTo: scrollView.topAnchor, constant: 24
            ),
            titleStackView.leadingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16
            ),
            titleStackView.trailingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16
            ),
            
            tableView.leadingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16
            ),
            tableView.trailingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16
            ),
            tableView.topAnchor.constraint(
                equalTo: titleStackView.bottomAnchor, constant: 24
            ),
            tableView.heightAnchor.constraint(
                equalToConstant: 150
            )
        ])
    }
    
    private func showViewController(_ viewController: UIViewController) {
        let viewController = viewController
        let navVC = UINavigationController(rootViewController: viewController)
        present(navVC, animated: true)
    }
    
    private func saveTracker() {
        let dataManager = DataManager.shared
        let categoryToUpdate = dataManager.category
        
        let color = colors.randomElement() ?? UIColor()
        let newTracker = Tracker(id: UUID(), title: trackerTitle, color: color, emoji: "🐶", schedule: setSchedule)
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
    
    private func showWarningLabel(state: Bool) {
        UIView.animate(withDuration: 0.3) {
            if state {
                self.titleStackView.addArrangedSubview(self.warningLabel)
                self.warningLabel.alpha = 1
            } else {
                self.warningLabel.alpha = 0
                self.titleStackView.removeArrangedSubview(self.warningLabel)
                self.warningLabel.removeFromSuperview()
            }
        }
    }
    
    private func getSchedule(from array: [WeekDay]) -> String {
        let scheduleSubtitle = array.compactMap { $0.abbreviationValue }.joined(separator: ", ")
        return scheduleSubtitle
    }
    
    @objc private func textFieldDidChange() {
        if let text = trackerTitleTextField.text {
            trackerTitle = text
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

//MARK: - UITextFieldDelegate
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
            showWarningLabel(state: true)
        } else {
            showWarningLabel(state: false)
        }
        
        return newText.count <= 38
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension AddNewTrackerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.cellIdentifier, for: indexPath
        )
        
        let title = titlesCells[indexPath.row]
        
        cell.backgroundColor = .ypBackground
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            
            content.text = title
            
            if indexPath.row == 0 {
                content.secondaryText = categorySubtitle
            } else {
                content.secondaryText = getSchedule(from: setSchedule)
            }
            
            content.textProperties.font = UIFont.ypFontMedium17
            content.textProperties.color = .ypBlack
            content.secondaryTextProperties.font = UIFont.ypFontMedium17
            content.secondaryTextProperties.color = .ypGray
            
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = title
            
            if indexPath.row == 0 {
                cell.detailTextLabel?.text = categorySubtitle
            } else {
                cell.detailTextLabel?.text = getSchedule(from: setSchedule)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let vc = AddCategoryViewController()
            vc.delegate = self
            vc.selectedIndexPath = currentIndexCategory
            showViewController(vc)
        } else {
            let vc = AddScheduleViewController()
            vc.delegate = self
            vc.schedule = setSchedule
            vc.switchStates = currentSwitchStates
            showViewController(vc)
        }
    }
}

//MARK: - UpdateSubtitleDelegate
extension AddNewTrackerViewController: UpdateSubtitleDelegate {
    func updateCategorySubtitle(from string: String?, and indexPath: IndexPath?) {
        categorySubtitle = string ?? ""
        currentIndexCategory = indexPath
        
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func updateScheduleSubtitle(from weekDays: [WeekDay]?, and switchStates: [Int: Bool]) {
        setSchedule = weekDays ?? []
        currentSwitchStates = switchStates
        
        let indexPath = IndexPath(row: 1, section: 0)
        tableView.reloadData()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
