import UIKit

final class AddCategoryViewController: UIViewController {
    
    //MARK: - Properties
    private let defaultStack = DefaultStackView(
        title: "Привычки и события можно объединить по смыслу"
    )
    
    private let tableView = UITableView()
    private let button = CustomButton(title: "Добавить категорию")
    
    private let trackerCategoryStore = TrackerCategoryStore()
    
    private var categories = [TrackerCategory]()
    private var titleCategory = ""
    
    var selectedIndexPath: IndexPath?
    weak var delegate: UpdateSubtitleDelegate?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        title = "Категория"
        
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.ypFontMedium16,
            .foregroundColor: UIColor.ypBlack
        ]
        
        getData()
        configureTableView()
        addElements()
        showScenario()
        
        button.addTarget(
            self,
            action: #selector(addCategory),
            for: .touchUpInside
        )
    }
    
    //MARK: - Helpers
    private func getData() {
        categories = trackerCategoryStore.categories
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: Constants.categoryCellIdentifier
        )
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = Constants.bigRadius
    }
    
    private func addElements() {
        view.addSubview(defaultStack)
        view.addSubview(tableView)
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
            
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 16
            ),
            tableView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -16
            ),
            tableView.bottomAnchor.constraint(
                equalTo: button.topAnchor,
                constant: -10
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
        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(
                equalTo: view.bottomAnchor, constant: -50
            )
        ])
        
        setupConstraints()
    }
    
    private func setupConstraintsForSEScreen() {
        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(
                equalTo: view.bottomAnchor, constant: -24
            )
        ])
        
        setupConstraints()
    }
    
    private func showScenario() {
        if 568 <= UIScreen.main.bounds.size.height,
           UIScreen.main.bounds.size.height <= 667 {
            setupConstraintsForSEScreen()
        } else {
            setupConstraintForDefaultScreen()
        }
        
        if categories.isEmpty {
            defaultStack.isHidden = false
            tableView.isHidden = false
        } else {
            tableView.isHidden = false
            defaultStack.isHidden = true
        }
    }
    
    @objc private func addCategory() {
        let newCategoryVC = AddNewCategoryViewController()
        newCategoryVC.delegate = self
        let navVC = UINavigationController(rootViewController: newCategoryVC)
        present(navVC, animated: true)
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension AddCategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.categoryCellIdentifier, for: indexPath)
        
        let title = categories[indexPath.row].title
        let lastIndex = categories.count - 1
        
        cell.backgroundColor = .ypBackground
        cell.selectionStyle = .none
        cell.separatorInset = UIEdgeInsets(
            top: 0, left: 16, bottom: 0, right: 16
        )
        
        if indexPath.row == lastIndex {
            cell.separatorInset = UIEdgeInsets(
                top: 0, left: cell.bounds.size.width, bottom: 0, right: 0
            )
            
            let maskLayer = CAShapeLayer()
            maskLayer.path = UIBezierPath(
                roundedRect: cell.bounds,
                byRoundingCorners: [.bottomLeft, .bottomRight],
                cornerRadii: CGSize(width: 16, height: 16)
            ).cgPath
            cell.layer.mask = maskLayer
        }
        
        if indexPath == selectedIndexPath {
            cell.accessoryType = .checkmark
        }
        
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = title
            content.textProperties.font = UIFont.ypFontMedium17
            content.textProperties.color = .ypBlack
            cell.contentConfiguration = content
            
        } else {
            cell.textLabel?.text = title
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedIndexPath != nil {
            guard let selectedCell = tableView.cellForRow(at: selectedIndexPath ?? IndexPath()) else { return }
            
            selectedCell.accessoryType = .none
        }
        
        selectedIndexPath = indexPath
        guard let currentCell = tableView.cellForRow(at: selectedIndexPath ?? IndexPath()) else { return }
        
        currentCell.accessoryType = .checkmark
        
        titleCategory = categories[indexPath.row].title
        delegate?.updateCategorySubtitle(from: titleCategory, and: selectedIndexPath)
    }
}

extension AddCategoryViewController: AddCategoryViewControllerDelegate {
    func updateListCategories(newCategory: TrackerCategory) {
        categories.append(newCategory)
        tableView.reloadData()
    }
}
