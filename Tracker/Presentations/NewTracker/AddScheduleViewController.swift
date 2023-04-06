import UIKit

final class AddScheduleViewController: UIViewController {
    
    private let weekDayTableView = UITableView()
    private lazy var doneButton: CustomButton = {
        let button = CustomButton(title: "Готово")
        button.addTarget(self, action: #selector(saveSchedule), for: .touchUpInside)
        return button
    }()
    
    private let weekDay = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    private var schedule: [String] = []
    
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
        
        weekDayTableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.weekDayCellIdentifier)

        weekDayTableView.backgroundColor = .ypBackground
        weekDayTableView.layer.cornerRadius = Constants.bigRadius
        weekDayTableView.translatesAutoresizingMaskIntoConstraints = false
        weekDayTableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: weekDayTableView.bounds.width, height: 0))

        weekDayTableView.separatorStyle = .singleLine
        weekDayTableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
    
    @objc func switchToggled(_ sender: UISwitch) {
        if sender.isOn {
            switch sender.tag {
            case 0:
                schedule.append(WeekDayTitle.monday.rawValue)
            case 1:
                schedule.append(WeekDayTitle.tuesday.rawValue)
            case 2:
                schedule.append(WeekDayTitle.wednesday.rawValue)
            case 3:
                schedule.append(WeekDayTitle.thursday.rawValue)
            case 4:
                schedule.append(WeekDayTitle.friday.rawValue)
            case 5:
                schedule.append(WeekDayTitle.saturday.rawValue)
            case 6:
                schedule.append(WeekDayTitle.sunday.rawValue)
            default:
                break
            }
        } else {
            switch sender.tag {
            case 0:
                if let index = schedule.firstIndex(of: WeekDayTitle.monday.rawValue) {
                    schedule.remove(at: index)
                }
            case 1:
                if let index = schedule.firstIndex(of: WeekDayTitle.tuesday.rawValue) {
                    schedule.remove(at: index)
                }
            case 2:
                if let index = schedule.firstIndex(of: WeekDayTitle.wednesday.rawValue) {
                    schedule.remove(at: index)
                }
            case 3:
                if let index = schedule.firstIndex(of: WeekDayTitle.thursday.rawValue) {
                    schedule.remove(at: index)
                }
            case 4:
                if let index = schedule.firstIndex(of: WeekDayTitle.friday.rawValue) {
                    schedule.remove(at: index)
                }
            case 5:
                if let index = schedule.firstIndex(of: WeekDayTitle.saturday.rawValue) {
                    schedule.remove(at: index)
                }
            case 6:
                if let index = schedule.firstIndex(of: WeekDayTitle.sunday.rawValue) {
                    schedule.remove(at: index)
                }
            default:
                break
            }
        }
    }
        
        
    @objc private func saveSchedule() {
        print("done")
    }
}

extension AddScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weekDay.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.weekDayCellIdentifier, for: indexPath)
        
        let day = weekDay[indexPath.row]
        let lastIndex = weekDay.count - 1
        
        cell.backgroundColor = .ypBackground
        cell.selectionStyle = .none

        let switcher = UISwitch()
        switcher.onTintColor = .ypBlue
        switcher.tag = indexPath.row
        switcher.addTarget(self, action: #selector(switchToggled(_:)), for: .valueChanged)
        cell.accessoryView = switcher
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        if indexPath.row == lastIndex {
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
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
