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
    
    override var isSelected: Bool {
        didSet {
            updateSelectionState()
        }
    }
    
    private var buttonWidthConstraint: NSLayoutConstraint?
    private var buttonHeightConstraint: NSLayoutConstraint?
    
    private var section: Int = 0
    private var currentEmoji = String()
    private var currentColor = UIColor()
    
    weak var delegate: AddNewTrackerCellDelegate?

    
    //MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(button)
        contentView.insertSubview(selectedEmojiView, belowSubview: button)
        contentView.insertSubview(selectedColorBorderView, belowSubview: button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        selectedEmojiView.translatesAutoresizingMaskIntoConstraints = false
        selectedColorBorderView.translatesAutoresizingMaskIntoConstraints = false

        buttonWidthConstraint = button.widthAnchor.constraint(equalToConstant: 40)
        buttonHeightConstraint = button.heightAnchor.constraint(equalToConstant: 40)
        
        guard let buttonWidthConstraint, let buttonHeightConstraint else { return }
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(
                equalTo: contentView.centerXAnchor
            ),
            button.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),
            buttonWidthConstraint,
            buttonHeightConstraint,
            
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
        self.section = section
        
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
    
    func shrinkButton() {
        buttonWidthConstraint?.constant -= 4
        buttonHeightConstraint?.constant -= 4
    }
    
    func expandButton() {
        buttonWidthConstraint?.constant += 4
        buttonHeightConstraint?.constant += 4
    }
    
    private func updateSelectionState() {
        if section == 0 {
            selectedEmojiView.alpha = isSelected ? 1 : 0
        } else {
            selectedColorBorderView.layer.borderColor = currentColor.withAlphaComponent(0.3).cgColor
            selectedColorBorderView.alpha = isSelected ? 1 : 0
        }
    }

    @objc private func selectedEmoji() {
        delegate?.cellTapped(self)
    }

    @objc private func selectedColor() {
        delegate?.cellTapped(self)
    }
}
