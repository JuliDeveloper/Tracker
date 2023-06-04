import UIKit

final class TrackerFilteringViewController: UIViewController {
    //MARK: - Properties
    private let tableView = UITableView()
    
    private let userDefaults: StorageManager
    private let trackerStore: TrackerStoreProtocol
    
    private var titlesCell: [String] = []
    private var selectedIndexPath: IndexPath? = nil
    
    weak var delegate: ListTrackersViewControllerDelegate?
    
    //MARK: - Lifecycle
    init(trackerStore: TrackerStoreProtocol = TrackerStore(), userDefaults: StorageManager = StorageManager.shared) {
        self.trackerStore = trackerStore
        self.userDefaults = userDefaults
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        configureView()
        setTitles()
        configureTableView()
        setupConstraints()
        
    }
    
    //MARK: - Helpers
    private func configureNavBar() {
        title = NSLocalizedString("filter.title", comment: "")
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
    
    private func setTitles() {
        let allTrackers = NSLocalizedString("filter.allTrackers", comment: "")
        let trackersForToday = NSLocalizedString("filter.trackersForToday", comment: "")
        let completed = NSLocalizedString("filter.completed", comment: "")
        let notCompleted = NSLocalizedString("filter.notCompleted", comment: "")
        
        titlesCell.append(allTrackers)
        titlesCell.append(trackersForToday)
        titlesCell.append(completed)
        titlesCell.append(notCompleted)
    }
    
    private func filterAllTrackersFromSelectedDate() {
        guard let datePickerDate = delegate?.updateStateFromDate() else { return }
        let currentDate = Date()
        
        delegate?.resetDatePicker(currentDate)
        
        let calendar = Calendar.current
        let datePickerWeekDay = calendar.component(.weekday, from: datePickerDate)
        let currentWeekDay = calendar.component(.weekday, from: currentDate)
        
        if datePickerWeekDay == currentWeekDay {
            trackerStore.trackerFiltering(from: String(currentWeekDay), or: nil)
        }
    }
    
    private func filterTrackersForToday() {
        let currentDate = Date()
        delegate?.resetDatePicker(currentDate)
        
        guard let datePickerDate = delegate?.updateStateFromDate() else { return }
        
        let calendar = Calendar.current
        let datePickerWeekDay = calendar.component(.weekday, from: datePickerDate)
        let currentWeekDay = calendar.component(.weekday, from: currentDate)
        
        if datePickerWeekDay == currentWeekDay {
            trackerStore.trackerFiltering(from: String(currentWeekDay), or: nil)
        }
    }
    
    private func filterCompletedTrackers() {
        //: TODO
    }
    
    private func filterUncompletedTrackers() {
        //: TODO
    }
    
    private func selectedFiltering(at row: Int) {
        switch row {
        case 0: filterAllTrackersFromSelectedDate()
        case 1: filterTrackersForToday()
        case 2: filterCompletedTrackers()
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
        
        let selectedFilter = userDefaults.getCurrentFilteringCellFromIndex()
        selectedIndexPath = IndexPath(row: selectedFilter, section: 0)
        cell.accessoryType = indexPath.row == selectedFilter ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        if let previousSelectedIndexPath = selectedIndexPath,
           let previousSelectedCell = tableView.cellForRow(at: previousSelectedIndexPath) {
            previousSelectedCell.accessoryType = .none
        }
        
        selectedIndexPath = indexPath
        userDefaults.setIndexPathForFilteringCell(from: selectedIndexPath)
        cell.accessoryType = .checkmark
        
        selectedFiltering(at: selectedIndexPath?.row ?? 0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.dismiss(animated: true)
        }
    }
}
