import UIKit

final class StatisticsViewController: UIViewController {
    
    //MARK: - Properties
    private let defaultStackView: DefaultStackView = {
        let title = NSLocalizedString(
            "stackView.notStatistic.title", comment: ""
        )
        let stack = DefaultStackView(
            title: title, image: "statisticError"
        )
        return stack
    }()
    
    private let tableView = UITableView()
    private var subtitlesCell: [String] = []
    
    private let trackerStore: TrackerStoreProtocol
    
    private lazy var records = {
        try? self.trackerStore.fetchAllRecords()
    }()
    
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
        setTitlesCell()
        configureTableView()
        showScenario()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        records = try? trackerStore.fetchAllRecords()
        tableView.reloadData()
        showScenario()
    }
    
    //MARK: - Helpers
    private func configureNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        
        title = NSLocalizedString("statistic.title", comment: "")
    }
    
    private func configureView() {
        view.backgroundColor = .ypWhite
        
        view.addSubview(defaultStackView)
        view.addSubview(tableView)
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(StatisticCell.self, forCellReuseIdentifier: Constants.statisticCellIdentifier)
        
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setTitlesCell() {
        let bestPeriod = NSLocalizedString(
            "statistic.bestPeriod", comment: ""
        )
        let perfectDays = NSLocalizedString(
            "statistic.perfectDays", comment: ""
        )
        let completedTrackers = NSLocalizedString(
            "statistic.completedTrackers", comment: ""
        )
        let averageValue = NSLocalizedString(
            "statistic.averageValue", comment: ""
        )
        
        subtitlesCell.append(bestPeriod)
        subtitlesCell.append(perfectDays)
        subtitlesCell.append(completedTrackers)
        subtitlesCell.append(averageValue)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            defaultStackView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            defaultStackView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
            
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 16
            ),
            tableView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 77
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -16
            ),
            tableView.heightAnchor.constraint(
                equalToConstant: 408
            )
        ])
    }
    
    private func showScenario() {
        if records?.count == 0 {
            defaultStackView.isHidden = false
            tableView.isHidden = true
        } else {
            defaultStackView.isHidden = true
            tableView.isHidden = false
        }
    }
}

//MARK: - UITableViewDataSource, UITableViewDelegate
extension StatisticsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        subtitlesCell.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        102
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.statisticCellIdentifier, for: indexPath) as? StatisticCell else { return UITableViewCell() }
        
        var title = ""
        let subtitle = subtitlesCell[indexPath.row]
        
        if indexPath.row == 2 {
            title = "\(records?.count ?? 0)"
        } else {
            title = "0"
        }
                
        cell.configureCell(title, subtitle)
        
        return cell
    }
}
