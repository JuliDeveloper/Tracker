import UIKit

final class TaskCell: UICollectionViewCell {
    
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
        label.text = "🥳"
        label.font = UIFont.ypFontMedium16
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let taskTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Поливать растения"
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
    
    private let plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plusCell"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 34 / 2
        return button
    }()
    
    //MARK: - Helpers
    func configure(for cell: TaskCell, title: String, emoji: String, counter: String, color: UIColor) {
        addElements()
        setupConstraints()
        
        mainView.backgroundColor = color
        plusButton.backgroundColor = color
        
        taskTitleLabel.text = title
        emojiLabel.text = emoji
        counterDayLabel.text = counter
    }
    
    private func addElements() {
        addSubview(mainView)
        addSubview(stackView)
        
        mainView.addSubview(emojiLabel)
        mainView.addSubview(taskTitleLabel)
        
        stackView.addArrangedSubview(counterDayLabel)
        stackView.addArrangedSubview(plusButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainView.leadingAnchor.constraint(
                equalTo: leadingAnchor
            ),
            mainView.topAnchor.constraint(
                equalTo: topAnchor
            ),
            mainView.trailingAnchor.constraint(
                equalTo: trailingAnchor
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
}
