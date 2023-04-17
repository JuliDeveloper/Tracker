import UIKit

final class AddNewTrackerCell: UICollectionViewCell {
    
    //MARK: - Properties
    private let button = UIButton()
    
    private let selectedEmojiView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypLightGray
        view.clipsToBounds = true
        view.layer.cornerRadius = Constants.bigRadius
        view.alpha = 0
        return view
    }()
    
    private let selectedColorBorderView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = Constants.mediumRadius
        view.layer.borderWidth = 3
        view.alpha = 0
        return view
    }()
    
    private var isSelectedEmoji = false
    private var isSelectedColor = false
    private var currentEmoji = String()
    private var currentColor = UIColor()
    
    //MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(button)
        contentView.insertSubview(selectedEmojiView, belowSubview: button)
        contentView.insertSubview(selectedColorBorderView, belowSubview: button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        selectedEmojiView.translatesAutoresizingMaskIntoConstraints = false
        selectedColorBorderView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(
                equalTo: contentView.centerXAnchor
            ),
            button.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),
            button.heightAnchor.constraint(
                equalToConstant: 40
            ),
            button.widthAnchor.constraint(
                equalToConstant: 40
            ),
            
            selectedEmojiView.centerXAnchor.constraint(
                equalTo: contentView.centerXAnchor
            ),
            selectedEmojiView.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),
            selectedEmojiView.widthAnchor.constraint(equalToConstant: 52),
            selectedEmojiView.heightAnchor.constraint(equalToConstant: 52),
            
            selectedColorBorderView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: -3
            ),
            selectedColorBorderView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: 3
            ),
            selectedColorBorderView.topAnchor.constraint(
                equalTo: contentView.topAnchor, constant: -3
            ),
            selectedColorBorderView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor, constant: 3
            )
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    func configureCell(for section: Int, title: String?, color: UIColor?) {
        switch section {
        case 0:
            currentEmoji = title ?? ""
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.ypFontBold32
            button.addTarget(
                self,
                action: #selector(selectedEmoji),
                for: .touchUpInside
            )
        case 1:
            currentColor = color ?? UIColor()
            button.backgroundColor = color
            button.clipsToBounds = true
            button.layer.cornerRadius = Constants.smallRadius
            button.addTarget(
                self,
                action: #selector(selectedColor),
                for: .touchUpInside
            )
        default:
            break
        }
    }

    @objc private func selectedEmoji() {
        isSelectedEmoji.toggle()
        selectedEmojiView.alpha = isSelectedEmoji ? 1 : 0
    }

    @objc private func selectedColor() {
        isSelectedColor.toggle()
        selectedColorBorderView.layer.borderColor = currentColor.withAlphaComponent(0.3).cgColor
        selectedColorBorderView.alpha = isSelectedColor ? 1 : 0
    }
}
