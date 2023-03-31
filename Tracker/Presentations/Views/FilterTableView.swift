import UIKit

final class FilterTableViewCell: UITableViewCell {
    //MARK: - Properties
    private let tableView = UITableView()
    private let titlesCells = ["Категория", "Расписание"]
    
    weak var delegate: AddNewTrackerViewControllerDelegate?
    
    //MARK: - Helpers
    func configureCell() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellIdentifier)
        
        tableView.separatorStyle = .singleLine
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        tableView.addGestureRecognizer(tapGesture)
        
        tableView.backgroundColor = .ypBackground
        tableView.layer.cornerRadius = Constants.bigRadius
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(tableView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 16
            ),
            tableView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -16
            ),
            tableView.topAnchor.constraint(
                equalTo: contentView.topAnchor, constant: 24
            ),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    @objc private func tableViewTapped() {
        delegate?.showViewController()
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension FilterTableViewCell: UITableViewDelegate, UITableViewDataSource {
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
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
        }
    }    
}

