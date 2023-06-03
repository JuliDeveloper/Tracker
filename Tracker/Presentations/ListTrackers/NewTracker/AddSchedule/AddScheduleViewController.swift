import UIKit

final class AddScheduleViewController: UIViewController {
    
    //MARK: - Properties
    private let weekDayTableView = UITableView()
    private lazy var doneButton: CustomButton = {
        let title = NSLocalizedString("done", comment: "")
        let button = CustomButton(title: title)
        button.addTarget(
            self,
            action: #selector(saveSchedule),
            for: .touchUpInside
        )
        return button
    }()
    
    private let weekDays = WeekDay.allCases
    
    var schedule = [WeekDay]()
    lazy var switchStates: [Bool] = {
        weekDays.map { schedule.contains($0) }
    }()
    
    weak var delegate: UpdateSubtitleDelegate?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        title = NSLocalizedString("schedule.title", comment: "")
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.ypFontMedium16,
            .foregroundColor: UIColor.ypBlack
        ]
        
        addElements()
        configureWeekDayTableView()
        showScenario()
    }
    
    private func configureWeekDayTableView() {
        weekDayTableView.delegate = self
        weekDayTableView.dataSource = self
        
        weekDayTableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: Constants.weekDayCellIdentifier
        )
        
        weekDayTableView.backgroundColor = .ypBackground
        weekDayTableView.layer.cornerRadius = Constants.bigRadius
        weekDayTableView.translatesAutoresizingMaskIntoConstraints = false
        weekDayTableView.tableHeaderView = UIView(frame: CGRect(
            x: 0, y: 0, width: weekDayTableView.bounds.width, height: 0)
        )
        
        weekDayTableView.separatorStyle = .singleLine
        weekDayTableView.separatorInset = UIEdgeInsets(
            top: 0, left: 0, bottom: 0, right: 0
        )
        
        weekDayTableView.showsVerticalScrollIndicator = false
    }
    
    private func addElements() {
        view.addSubview(weekDayTableView)
        view.addSubview(doneButton)
    }
    
    private func setupConstraints() {
        weekDayTableView.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            weekDayTableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 16
            ),
            weekDayTableView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24
            ),
            weekDayTableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -16
            ),
            
            doneButton.leadingAnchor.constraint(
                equalTo: weekDayTableView.leadingAnchor
            ),
            doneButton.trailingAnchor.constraint(
                equalTo: weekDayTableView.trailingAnchor
            )
        ])
    }
    
    private func setupConstraintForDefaultScreen() {
        weekDayTableView.isScrollEnabled = false
        weekDayTableView.heightAnchor.constraint(
            equalToConstant: 525
        ).isActive = true
        doneButton.bottomAnchor.constraint(
            equalTo: view.bottomAnchor, constant: -50
        ).isActive = true
        
        setupConstraints()
    }
    
    private func setupConstraintsForSEScreen() {
        weekDayTableView.isScrollEnabled = true
        weekDayTableView.heightAnchor.constraint(
            equalToConstant: 525
        ).isActive = false
        weekDayTableView.bottomAnchor.constraint(
            equalTo: doneButton.topAnchor, constant: -39
        ).isActive = true
        doneButton.bottomAnchor.constraint(
            equalTo: view.bottomAnchor, constant: -24
        ).isActive = true
        
        setupConstraints()
    }
    
    private func showScenario() {
        if 568 <= UIScreen.main.bounds.size.height,
           UIScreen.main.bounds.size.height <= 667 {
            setupConstraintsForSEScreen()
        } else {
            setupConstraintForDefaultScreen()
        }
    }
    
    private func configureCellContent(_ cell: UITableViewCell, with text: String) {
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = text
            content.textProperties.font = UIFont.ypFontMedium17
            content.textProperties.color = .ypBlack
            content.secondaryTextProperties.font = UIFont.ypFontMedium17
            content.secondaryTextProperties.color = .ypGray
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = title
        }
    }
    
    private func createSwitcher(for indexPath: IndexPath) -> UISwitch {
        let switcher = UISwitch()
        switcher.onTintColor = .ypBlue
        switcher.tag = indexPath.row
        switcher.addTarget(
            self,
            action: #selector(switchToggled(_:)),
            for: .valueChanged
        )
        return switcher
    }

    private func configureSeparator(for cell: UITableViewCell, at indexPath: IndexPath) {
        let lastIndex = weekDays.count - 1
        let isLastCell = indexPath.row == lastIndex
        let leftInset = isLastCell ? cell.bounds.size.width : 16
        cell.separatorInset = UIEdgeInsets(
            top: 0,
            left: leftInset,
            bottom: 0,
            right: 16
        )
    }
    
    private func configureCell(_ cell: UITableViewCell, for indexPath: IndexPath) {
        let day = weekDays[indexPath.row].localizedName

        cell.backgroundColor = .ypBackground
        cell.selectionStyle = .none

        let switcher = createSwitcher(for: indexPath)
        cell.accessoryView = switcher

        switcher.isOn = switchStates[indexPath.row]

        configureSeparator(for: cell, at: indexPath)

        configureCellContent(cell, with: day)
    }
    
    private func removeWeekDay(_ weekDay: WeekDay) {
        if let index = schedule.firstIndex(of: weekDay) {
            schedule.remove(at: index)
        }
    }
    
    @objc private func switchToggled(_ sender: UISwitch) {
        let dayChanged = WeekDay.allCases[sender.tag]
        switchStates[sender.tag] = sender.isOn
        if sender.isOn {
            schedule.append(dayChanged)
        } else {
            removeWeekDay(dayChanged)
        }
    }
    
    @objc private func saveSchedule() {
        delegate?.updateScheduleSubtitle(from: schedule)
        dismiss(animated: true)
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension AddScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weekDays.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.weekDayCellIdentifier, for: indexPath)
        
        configureCell(cell, for: indexPath)
        
        return cell
    }
}
