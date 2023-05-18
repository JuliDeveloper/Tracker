import UIKit

final class AddCategoryViewController: UIViewController {
    
    //MARK: - Properties
    private let defaultStack = DefaultStackView(
        title: "Привычки и события можно объединить по смыслу", image: "star"
    )
    
    private let tableView = UITableView()
    private let button = CustomButton(title: "Добавить категорию")
    
    private lazy var trackerCategoryStore: TrackerCategoryStoreProtocol = TrackerCategoryStore(delegate: self)
    
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
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(
            CategoryCell.self,
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
        
        if trackerCategoryStore.countCategories == 0 {
            defaultStack.isHidden = false
            tableView.isHidden = false
        } else {
            tableView.isHidden = false
            defaultStack.isHidden = true
        }
    }
    
    
    
    private func deleteCategory(from indexPath: IndexPath) {
        let deleteConfirmationAlert = UIAlertController(title: nil, message: "Уверены что хотите удалить категорию?", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let self = self else { return }

            let currentCategory = self.trackerCategoryStore.getCategory(at: indexPath)
            
            if let trackers = currentCategory?.trackers, !trackers.isEmpty {
                let trackersExistAlert  = UIAlertController(title: "Вы еще не завершили все трекеры этой категории", message: "Сначала закончите их", preferredStyle: .alert)
                let action = UIAlertAction(title: "ОК", style: .default)
                trackersExistAlert.addAction(action)
                self.present(trackersExistAlert, animated: true)
            } else {
                do {
                    if let currentCategory {
                        try self.trackerCategoryStore.deleteCategory(category: currentCategory)
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .default)
        deleteConfirmationAlert.addAction(deleteAction)
        deleteConfirmationAlert.addAction(cancelAction)
        present(deleteConfirmationAlert, animated: true)
    }
    
    @objc private func addCategory() {
        let newCategoryVC = AddNewCategoryViewController()
        let navVC = UINavigationController(rootViewController: newCategoryVC)
        present(navVC, animated: true)
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension AddCategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        trackerCategoryStore.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.categoryCellIdentifier, for: indexPath) as? CategoryCell else { return UITableViewCell() }
        
        guard let title = trackerCategoryStore.getCategoryTitle(indexPath.section)[indexPath.row] else {
            return UITableViewCell()
            
        }
        
        let lastIndex = trackerCategoryStore.numberOfRowsInSection(indexPath.section) - 1
      
        cell.configure(
            title,
            indexPath,
            lastIndex,
            selectedIndexPath ?? IndexPath()
        )
        
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
        
        guard let titleCategory = trackerCategoryStore.getCategoryTitle(indexPath.section)[indexPath.row] else {
            return
        }
        delegate?.updateCategorySubtitle(from: titleCategory, and: selectedIndexPath)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard let currentCategory = trackerCategoryStore.getCategory(at: indexPath) else { return UIContextMenuConfiguration() }
               
        return UIContextMenuConfiguration(actionProvider: { [weak self] actions in
            guard let self else { return UIMenu() }
            return UIMenu(children: [
                UIAction(
                    title: "Редактировать"
                ) { _ in
                    let addNewCategoryVC = AddNewCategoryViewController()
                    addNewCategoryVC.text = currentCategory.title
                    addNewCategoryVC.category = currentCategory
                    addNewCategoryVC.delegate = self
                    self.present(addNewCategoryVC, animated: true)
                },
                UIAction(
                    title: "Удалить",
                    attributes: .destructive
                ) { _ in
                    self.deleteCategory(from: indexPath)
                }
            ])
        })
    }
}

extension AddCategoryViewController: TrackerCategoryStoreDelegate {
    func didUpdate(_ update: TrackerCategoryStoreUpdate) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: update.insertedIndexes, with: .automatic)
            tableView.deleteRows(at: update.deletedIndexPaths, with: .automatic)
        }
    }
}

extension AddCategoryViewController: AddCategoryViewControllerDelegate {
    func updateTableView() {
        tableView.reloadData()
    }
}
