import UIKit

final class AddNewTrackerViewController: UITableViewController {
        
    private let buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let titlesCells = ["Категория", "Расписание"]
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        configureMainTableView()
    }
    
    private func configureNavBar() {
        title = "Новая привычка"
        
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.ypFontMedium16,
            .foregroundColor: UIColor.ypBlack
        ]
    }
    
    private func configureMainTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(
            TitleTrackerCell.self,
            forCellReuseIdentifier: Constants.titleTrackerCellIdentifier
        )
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: Constants.settingTrackerCellIdentifier
        )
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .ypWhite
    }
    
    private func addElements() {
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(createButton)
    }
    
    @objc private func cancel() {
        dismiss(animated: true)
    }
    
    @objc private func create() {
        dismiss(animated: true)
    }
}

extension AddNewTrackerViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 1
        case 1:
            return titlesCells.count
        default:
            break
        }
        
        return Int()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let title = titlesCells[indexPath.row]
        
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
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.settingTrackerCellIdentifier, for: indexPath)
            cell.backgroundColor = .ypBackground
            cell.selectionStyle = .none
            cell.accessoryType = .disclosureIndicator
            
            if #available(iOS 14.0, *) {
                var content = cell.defaultContentConfiguration()
                
                content.text = title
                content.secondaryText = ""
                
                content.textProperties.font = UIFont.ypFontMedium17
                content.textProperties.color = .ypBlack
                content.secondaryTextProperties.font = UIFont.ypFontMedium17
                content.secondaryTextProperties.color = .ypGray
                
                cell.contentConfiguration = content
            } else {
                cell.textLabel?.text = title
                cell.detailTextLabel?.text = ""
            }
            return cell
        default:
            break
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
        }
    }
}

extension AddNewTrackerViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if newText.count > 10 {
            tableView.performBatchUpdates {
                self.delegate?.updateCell(state: false)
            }
        } else {
            tableView.performBatchUpdates {
                self.delegate?.updateCell(state: true)
            }
        }
    
        return newText.count <= 10
    }
}
