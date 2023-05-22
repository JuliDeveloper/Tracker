import UIKit

final class AddCategoryViewController: UIViewController {
    
    //MARK: - Properties
    private let defaultStack = DefaultStackView(
        title: "Привычки и события можно объединить по смыслу", image: "star"
    )
    
    private let tableView = UITableView()
    private let button = CustomButton(title: "Добавить категорию")
        
    private var titleCategory = ""
    
    private var viewModel: AddCategoryViewModel
    
    weak var delegate: UpdateSubtitleDelegate?
    
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
        
        title = "Категория"
        
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.ypFontMedium16,
            .foregroundColor: UIColor.ypBlack
        ]
        
        viewModel.$categories.bind { [weak self] _ in
            self?.bindViewModel()
        }
        
        viewModel.$selectedIndexPath.bind { [weak self] _ in
            self?.tableView.reloadData()
        }
        
        configureTableView()
        addElements()
        showScenario()
        
        button.addTarget(
            self,
            action: #selector(addCategory),
            for: .touchUpInside
        )
        
        bindViewModel()
    }
    
    //MARK: - Helpers
    private func bindViewModel() {
        viewModel.onDidUpdate = { [weak self] update in
            self?.tableView.performBatchUpdates {
                self?.tableView.insertRows(at: update.insertedIndexes, with: .automatic)
                self?.tableView.deleteRows(at: update.deletedIndexPaths, with: .automatic)
            }
        }
    }
    
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
        
        if viewModel.categories.count == 0 {
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
            guard let self else { return }

            guard let currentCategory = viewModel.getCategory(at: indexPath) else { return }
            
            if !currentCategory.trackers.isEmpty {
                let trackersExistAlert  = UIAlertController(title: "Вы еще не завершили все трекеры этой категории", message: "Сначала закончите их", preferredStyle: .alert)
                let action = UIAlertAction(title: "ОК", style: .default)
                trackersExistAlert.addAction(action)
                self.present(trackersExistAlert, animated: true)
            } else {
                viewModel.delete(category: currentCategory)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .default)
        deleteConfirmationAlert.addAction(deleteAction)
        deleteConfirmationAlert.addAction(cancelAction)
        present(deleteConfirmationAlert, animated: true)
    }
    
    @objc private func addCategory() {
        let newCategoryVC = AddNewCategoryViewController(viewModel: viewModel)
        let navVC = UINavigationController(rootViewController: newCategoryVC)
        present(navVC, animated: true)
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension AddCategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.categoryCellIdentifier, for: indexPath) as? CategoryCell else { return UITableViewCell() }
        
        let title = viewModel.categories[indexPath.row].title
        
        let lastIndex = viewModel.categories.count - 1
      
        cell.configure(
            title,
            indexPath,
            lastIndex,
            viewModel.selectedIndexPath ?? IndexPath()
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel.selectedIndexPath != nil {
            guard let selectedCell = tableView.cellForRow(at: viewModel.selectedIndexPath ?? IndexPath()) else { return }
            
            selectedCell.accessoryType = .none
        }
        
        viewModel.getSelectedCategory(from: indexPath)
        guard let currentCell = tableView.cellForRow(at: viewModel.selectedIndexPath ?? IndexPath()) else { return }
        
        currentCell.accessoryType = .checkmark
        
        let titleCategory = viewModel.categories[indexPath.row].title
        delegate?.updateCategorySubtitle(from: titleCategory, and: viewModel.selectedIndexPath)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let currentCategory = viewModel.categories[indexPath.row]
               
        return UIContextMenuConfiguration(actionProvider: { [weak self] actions in
            guard let self else { return UIMenu() }
            return UIMenu(children: [
                UIAction(
                    title: "Редактировать"
                ) { _ in
                    let addNewCategoryVC = AddNewCategoryViewController(viewModel: self.viewModel)
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

extension AddCategoryViewController: AddCategoryViewControllerDelegate {
    func updateTableView() {
        tableView.reloadData()
    }
}
