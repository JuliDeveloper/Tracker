import UIKit

final class TrackerCell: UICollectionViewCell {

    //MARK: - Properties
    private let mainView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.bigRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .ypDefaultWhite.withAlphaComponent(0.3)
        label.clipsToBounds = true
        label.layer.cornerRadius = 24 / 2
        label.font = UIFont.ypFontMedium16
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let taskTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypDefaultWhite
        label.font = UIFont.ypFontMedium12
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let counterDayLabel: UILabel = {
        let label = UILabel()
        label.text = "Поливать растения"
        label.textColor = .ypBlack
        label.font = UIFont.ypFontMedium12
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var plusButton: UIButton = {
        let button = UIButton(type: .system)
        let pointSize = UIImage.SymbolConfiguration(pointSize: 11)
        let image = UIImage(systemName: "plus", withConfiguration: pointSize)
        button.tintColor = .ypWhite
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 34 / 2
        button.addTarget(self, action: #selector(addDay), for: .touchUpInside)
        return button
    }()
    
    private var counter = 0
    private var isCompletedTrackerToday = false
    let currentDate: Date? = nil
    var tracker = Tracker(
        id: UUID(),
        title: "",
        color: UIColor(),
        emoji: "",
        schedule: [],
        countRecords: 0
    )
    
    weak var delegate: ListTrackersViewControllerDelegate?
    
    //MARK: - Helpers
    func configure(for cell: TrackerCell, tracker: Tracker, title: String, emoji: String, color: UIColor) {
        addElements()
        setupConstraints()
        
        mainView.backgroundColor = color
        plusButton.backgroundColor = color
        
        self.tracker = tracker
        
        let wordDay = pluralizeDays(counter)
        
        taskTitleLabel.text = title
        emojiLabel.text = emoji
        counterDayLabel.text = "\(wordDay)"
        
        checkDate()
    }
    
    private func addElements() {
        contentView.addSubview(mainView)
        contentView.addSubview(stackView)
        
        mainView.addSubview(emojiLabel)
        mainView.addSubview(taskTitleLabel)
        
        stackView.addArrangedSubview(counterDayLabel)
        stackView.addArrangedSubview(plusButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            mainView.topAnchor.constraint(
                equalTo: contentView.topAnchor
            ),
            mainView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            mainView.heightAnchor.constraint(
                equalToConstant: 90
            ),
            
            emojiLabel.leadingAnchor.constraint(
                equalTo: mainView.leadingAnchor,
                constant: 12
            ),
            emojiLabel.topAnchor.constraint(
                equalTo: mainView.topAnchor,
                constant: 12
            ),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            taskTitleLabel.leadingAnchor.constraint(
                equalTo: emojiLabel.leadingAnchor
            ),
            taskTitleLabel.bottomAnchor.constraint(
                equalTo: mainView.bottomAnchor,
                constant: -12
            ),
            taskTitleLabel.trailingAnchor.constraint(
                equalTo: mainView.trailingAnchor,
                constant: -12
            ),
            
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            
            stackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 12
            ),
            stackView.topAnchor.constraint(
                equalTo: mainView.bottomAnchor,
                constant: 8
            ),
            stackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -12
            )
        ])
    }
    
    private func pluralizeDays(_ count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100

        if remainder10 == 1 && remainder100 != 11 {
            return "\(count) день"
        } else if remainder10 >= 2 && remainder10 <= 4 && (remainder100 < 10 || remainder100 >= 20) {
            return "\(count) дня"
        } else {
            return "\(count) дней"
        }
    }
    
    private func checkDate() {
        let selectedDate = delegate?.updateButtonStateFromDate() ?? Date()
        
        if selectedDate > currentDate ?? Date() {
            isCompletedTrackerToday = false
            configureButton(image: setDefaultImage(), value: 1)
            plusButton.isEnabled = false
        } else if selectedDate <= currentDate ?? Date() {
            isCompletedTrackerToday = false
            configureButton(image: setDefaultImage(), value: 1)
            plusButton.isEnabled = true
        }
    }
    
    private func configureButton(image: UIImage, value: Float) {
        let newDayCont = pluralizeDays(counter)
        counterDayLabel.text = "\(newDayCont)"
        plusButton.setImage(image, for: .normal)
        plusButton.layer.opacity = value
    }
    
    private func setDefaultImage() -> UIImage {
        let pointSize = UIImage.SymbolConfiguration(pointSize: 11)
        let image = UIImage(
            systemName: "plus",
            withConfiguration: pointSize
        ) ?? UIImage()
        return image
    }
    
    @objc private func addDay() {
        isCompletedTrackerToday.toggle()

        if isCompletedTrackerToday {
            counter += 1
            configureButton(
                image: UIImage(named: "doneButton") ?? UIImage(),
                value: 0.3
            )
            delegate?.updateCompletedTrackers(
                tracker: tracker
            )
        } else {
            counter -= 1
            configureButton(
                image: setDefaultImage(),
                value: 1
            )
            delegate?.updateCompletedTrackers(
                tracker: tracker
            )
        }
    }
}
