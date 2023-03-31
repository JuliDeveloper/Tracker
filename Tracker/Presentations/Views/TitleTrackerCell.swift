import UIKit

protocol TitleTrackerCellDelegate: AnyObject {
    func updateCell(state: Bool)
}

final class TitleTrackerCell: UITableViewCell {
    
    private let cellStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let trackerTitleTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.ypFontMedium17
        textField.textColor = .ypBlack
        textField.backgroundColor = .ypBackground
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.cornerRadius = Constants.bigRadius
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 75))
        textField.leftView = leftView
        textField.leftViewMode = .always
        
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.ypGray
        ]
        let attributedPlaceholder = NSAttributedString(
            string: "Введите название трекера",
            attributes: attributes
        )
        textField.attributedPlaceholder = attributedPlaceholder
        
        return textField
    }()
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.font = UIFont.ypFontMedium17
        label.textColor = .ypRed
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func configureCell(delegate: AddNewTrackerViewController) {
        backgroundColor = .clear
        selectionStyle = .none
                
        contentView.backgroundColor = .ypBackground
        contentView.layer.cornerRadius = Constants.bigRadius
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        trackerTitleTextField.delegate = delegate
        
        addElements()
        setupConstraint()
    }
    
    func showWarningStatus(state: Bool) {
        warningLabel.isHidden = state
    }
    
    private func addElements() {
        contentView.addSubview(cellStackView)
        cellStackView.addArrangedSubview(trackerTitleTextField)
        cellStackView.addArrangedSubview(warningLabel)
        
    }
    
    private func setupConstraint() {
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            contentView.heightAnchor.constraint(equalToConstant: 75),
            
            cellStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            cellStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            cellStackView.heightAnchor.constraint(
                equalToConstant: 75
            ),
            cellStackView.centerXAnchor.constraint(
                equalTo: contentView.centerXAnchor
            )
        ])
    }
}

extension TitleTrackerCell: TitleTrackerCellDelegate {
    func updateCell(state: Bool) {
        showWarningStatus(state: state)
    }
}
