import UIKit

final class AddScheduleViewController: UIViewController {
    
    //MARK: - Properties
    private let weekDayTableView = UITableView()
    private lazy var doneButton: CustomButton = {
        let button = CustomButton(title: "Готово")
        button.addTarget(
            self,
            action: #selector(saveSchedule),
            for: .touchUpInside
        )
        return button
    }()
    
    private let weekDay = WeekDay.allCases
    
    var schedule = [WeekDay]()
    var switchStates = [Int: Bool]()
    weak var delegate: UpdateSubtitleDelegate?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        title = "Расписание"
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.ypFontMedium16,
            .foregroundColor: UIColor.ypBlack
        ]
        
        configureWeekDayTableView()
        addElements()
        setupConstraints()
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
        weekDayTableView.isScrollEnabled = false
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
            weekDayTableView.heightAnchor.constraint(
                equalToConstant: 525
            ),
            
            doneButton.leadingAnchor.constraint(
                equalTo: weekDayTableView.leadingAnchor
            ),
            doneButton.trailingAnchor.constraint(
                equalTo: weekDayTableView.trailingAnchor
            ),
            doneButton.bottomAnchor.constraint(
                equalTo: view.bottomAnchor, constant: -50
            )
        ])
    }
    
    private func removeWeekDay(_ weekDay: WeekDay) {
        if let index = schedule.firstIndex(of: weekDay) {
            schedule.remove(at: index)
        }
    }
    
    @objc func switchToggled(_ sender: UISwitch) {
        if sender.isOn {
            switchStates[sender.tag] = true
            switch sender.tag {
            case 0:
                schedule.append(WeekDay.monday)
            case 1:
                schedule.append(WeekDay.tuesday)
            case 2:
                schedule.append(WeekDay.wednesday)
            case 3:
                schedule.append(WeekDay.thursday)
            case 4:
                schedule.append(WeekDay.friday)
            case 5:
                schedule.append(WeekDay.saturday)
            case 6:
                schedule.append(WeekDay.sunday)
            default:
                break
            }
        } else {
            switchStates[sender.tag] = false
            switch sender.tag {
            case 0:
                removeWeekDay(WeekDay.monday)
            case 1:
                removeWeekDay(WeekDay.tuesday)
            case 2:
                removeWeekDay(WeekDay.wednesday)
            case 3:
                removeWeekDay(WeekDay.thursday)
            case 4:
                removeWeekDay(WeekDay.friday)
            case 5:
                removeWeekDay(WeekDay.saturday)
            case 6:
                removeWeekDay(WeekDay.sunday)
            default:
                break
            }
        }
    }
    
    @objc private func saveSchedule() {
        delegate?.updateScheduleSubtitle(from: schedule, and: switchStates)
        dismiss(animated: true)
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension AddScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weekDay.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.weekDayCellIdentifier, for: indexPath)
        
        let day = weekDay[indexPath.row].rawValue
        let lastIndex = weekDay.count - 1
        
        cell.backgroundColor = .ypBackground
        cell.selectionStyle = .none
        
        let switcher = UISwitch()
        switcher.onTintColor = .ypBlue
        switcher.tag = indexPath.row
        switcher.addTarget(
            self,
            action: #selector(switchToggled(_:)),
            for: .valueChanged
        )
        cell.accessoryView = switcher
        
        if let switchState = switchStates[indexPath.row] {
            switcher.setOn(switchState, animated: false)
        } else {
            switcher.setOn(false, animated: false)
        }
        
        cell.separatorInset = UIEdgeInsets(
            top: 0, left: 16, bottom: 0, right: 16
        )
        
        if indexPath.row == lastIndex {
            cell.separatorInset = UIEdgeInsets(
                top: 0, left: cell.bounds.size.width, bottom: 0, right: 0
            )
        }
        
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            
            content.text = day
            
            content.textProperties.font = UIFont.ypFontMedium17
            content.textProperties.color = .ypBlack
            content.secondaryTextProperties.font = UIFont.ypFontMedium17
            content.secondaryTextProperties.color = .ypGray
            
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = title
        }
        
        return cell
    }
}
