import UIKit

final class AddCategoryViewController: UIViewController {
    
    //MARK: - Properties
    private let defaultStack: DefaultStackView = {
        let stack = DefaultStackView(
            title: S.StackView.AddCategory.title, image: "star"
        )
        return stack
    }()
    
    private let tableView = UITableView()
    
    private let button: CustomButton = {
        let button = CustomButton(title: S.Button.AddNewCategory.title)
        return button
    }()
        
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
        configureNavBar()
        
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
            guard let self else { return }
            self.showScenario()
            self.tableView.performBatchUpdates {
                self.tableView.insertRows(at: update.insertedIndexes, with: .automatic)
                self.tableView.deleteRows(at: update.deletedIndexPaths, with: .automatic)
            }
        }
    }
    
    private func configureNavBar() {
        title = S.Category.title
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.ypFontMedium16,
            .foregroundColor: UIColor.ypBlack
        ]
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = .clear
        
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
        let deleteAction = UIAlertAction(title: S.delete, style: .destructive) { [weak self] _ in
            guard let self else { return }
            guard let currentCategory = viewModel.getCategory(at: indexPath) else { return }
            
            if !currentCategory.trackers.isEmpty {
                let deleteAction = UIAlertAction(title: S.delete, style: .destructive) { _ in
                    self.viewModel.delete(category: currentCategory)
                }
                let cancelAction = UIAlertAction(title: S.cancel, style: .default)
                
                self.showAlert(
                    title: S.Alert.DeleteNonEmptyCategory.title,
                    message: S.Alert.DeleteNonEmptyCategory.message,
                    preferredStyle: .alert,
                    actions: [deleteAction, cancelAction]
                )
            } else {
                viewModel.delete(category: currentCategory)
            }
        }
        
        let cancelAction = UIAlertAction(title: S.cancel, style: .default)
        
        showAlert(
            title: nil,
            message: S.Alert.DeleteCategory.message,
            preferredStyle: .actionSheet,
            actions: [deleteAction, cancelAction]
        )
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
        let selectedIndexPath = viewModel.selectedIndexPath ?? IndexPath()
      
        cell.configure(
            title,
            indexPath,
            lastIndex,
            selectedIndexPath
        )
        
        if selectedIndexPath == indexPath {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.dismiss(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let currentCategory = viewModel.categories[indexPath.row]
               
        return UIContextMenuConfiguration(actionProvider: { [weak self] actions in
            guard let self else { return UIMenu() }
            return UIMenu(children: [
                UIAction(
                    title: S.edit
                ) { _ in
                    let addNewCategoryVC = AddNewCategoryViewController(viewModel: self.viewModel)
                    addNewCategoryVC.text = currentCategory.title
                    addNewCategoryVC.category = currentCategory
                    self.present(addNewCategoryVC, animated: true)
                },
                UIAction(
                    title: S.delete,
                    attributes: .destructive
                ) { _ in
                    self.deleteCategory(from: indexPath)
                }
            ])
        })
    }
}
