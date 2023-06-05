import UIKit

final class TrackerFilteringViewController: UIViewController {
    //MARK: - Properties
    private let tableView = UITableView()
    private let titlesCell = Constants.trackerFilterTitlesCells

    private let trackerStore: TrackerStoreProtocol
    
    private var selectedIndexPath: IndexPath? = nil
    
    weak var delegate: ListTrackersViewControllerDelegate?
    
    //MARK: - Lifecycle
    init(trackerStore: TrackerStoreProtocol = TrackerStore()) {
        self.trackerStore = trackerStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        configureView()
        configureTableView()
        setupConstraints()
    }
    
    //MARK: - Helpers
    private func configureNavBar() {
        title = S.Filter.title
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.ypFontMedium16,
            .foregroundColor: UIColor.ypBlack
        ]
    }
    
    private func configureView() {
        view.backgroundColor = .ypWhite
        
        view.addSubview(tableView)
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: Constants.filteringCellIdentifier
        )
        
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = Constants.bigRadius
        
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 1))
        tableView.tableHeaderView?.backgroundColor = .ypWhite
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 16
            ),
            tableView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -16
            ),
            tableView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private func configureCellContent(_ cell: UITableViewCell, with text: String) {
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = text
            content.textProperties.font = UIFont.ypFontMedium17
            content.textProperties.color = .ypBlack
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = text
        }
        
        cell.backgroundColor = .ypBackground
        cell.selectionStyle = .none
    }
    
    private func configureSeparator(for cell: UITableViewCell, at indexPath: IndexPath) {
        let lastIndex = titlesCell.count - 1
        let isLastCell = indexPath.row == lastIndex
        let leftInset = isLastCell ? cell.bounds.size.width : 16
        cell.separatorInset = UIEdgeInsets(
            top: 0,
            left: leftInset,
            bottom: 0,
            right: 16
        )
    }
    
    private func filterAllTrackersFromSelectedDate() {
        guard let datePickerDate = delegate?.updateStateFromDate() else { return }
        delegate?.resetDatePicker(datePickerDate)
    }
    
    private func filterTrackersForToday() {
        let currentDate = Date()
        delegate?.resetDatePicker(currentDate)
    }
    
    private func filteringCompletedTrackers() {
        delegate?.filteringCompletedTrackers()
    }
    
    private func filterUncompletedTrackers() {
        delegate?.filteringUncompletedTrackers()
    }
    
    private func selectedFiltering(at row: Int) {
        switch row {
        case 0: filterAllTrackersFromSelectedDate()
        case 1: filterTrackersForToday()
        case 2: filteringCompletedTrackers()
        case 3: filterUncompletedTrackers()
        default:
            break
        }
    }
}

extension TrackerFilteringViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        titlesCell.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.filteringCellIdentifier, for: indexPath)
        
        let title = titlesCell[indexPath.row]
        
        configureSeparator(for: cell, at: indexPath)
        configureCellContent(cell, with: title)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.accessoryType = .checkmark
        
        selectedFiltering(at: indexPath.row)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.dismiss(animated: true)
        }
    }
}
