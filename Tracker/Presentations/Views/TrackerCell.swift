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
    
    private var currentDate: Date? = nil
    private var isCompletedTrackerToday = Bool()
    private var tracker = Tracker(
        id: UUID(),
        title: "",
        color: UIColor(),
        emoji: "",
        schedule: [],
        countRecords: 0
    )
    
    weak var delegate: ListTrackersViewControllerDelegate?
    weak var interactionDelegate: TrackerCellDelegate?
    
    //MARK: - Helpers
    func configure(for cell: TrackerCell, tracker: Tracker, _ trackerRecords: Set<TrackerRecord>, isCompleted: Bool) {
        addElements()
        setupConstraints()
        
        isCompletedTrackerToday = isCompleted
        
        mainView.backgroundColor = tracker.color
        plusButton.backgroundColor = tracker.color
        
        self.tracker = tracker
        
        let dayCounter = trackerRecords.count
        counterDayLabel.text = pluralizeDays(dayCounter)
        
        taskTitleLabel.text = tracker.title
        emojiLabel.text = tracker.emoji
        
        checkDate()
        updateTrackerState(isCompleted: isCompletedTrackerToday)
        
        let contextMenuInteraction = UIContextMenuInteraction(delegate: self)
        mainView.addInteraction(contextMenuInteraction)
    }
    
    func updateTrackerState(isCompleted: Bool) {
        if isCompleted {
            setupButton(isCompleted: isCompletedTrackerToday)
        } else {
            setupButton(isCompleted: isCompletedTrackerToday)
        }
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
    
    private func pluralizeDays(_ countOfDays: Int) -> String {
        let daysString = String.localizedStringWithFormat(
            NSLocalizedString("amountOfDay", comment: ""), countOfDays
        )
        
        return daysString
    }
    
    private func checkDate() {
        let selectedDate = delegate?.updateButtonStateFromDate() ?? Date()

        if selectedDate > currentDate ?? Date() {
            setupButton(isCompleted: isCompletedTrackerToday)
            plusButton.isEnabled = false
        } else if selectedDate <= currentDate ?? Date() {
            setupButton(isCompleted: isCompletedTrackerToday)
            plusButton.isEnabled = true
        }
    }
    
    private func configureButton(image: UIImage, value: Float, isCompleted: Bool) {
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
    
    private func setupButton(isCompleted: Bool) {
        let image = isCompleted ? UIImage(named: "doneButton") ?? UIImage() : setDefaultImage()
        let value: Float = isCompleted ? 0.3 : 1
        configureButton(image: image, value: value, isCompleted: isCompleted)
    }
    
    @objc private func addDay() {
        isCompletedTrackerToday.toggle()
        setupButton(isCompleted: isCompletedTrackerToday)
        delegate?.updateCompletedTrackers(cell: self, tracker)
    }
}

//MARK: - UIContextMenuInteractionDelegate
extension TrackerCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        interactionDelegate?.contextMenuNeeded(forCell: self)
    }
}
