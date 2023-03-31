import UIKit

final class TitleTrackerCell: UITableViewCell {
    //MARK: - Properties
    private let cellStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let trackerTitleTextField = CustomTextField(
        text: "Введите название трекера"
    )
    
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
    
    //MARK: - Helpers
    func configureCell(delegate: AddNewTrackerViewController) {
        backgroundColor = .clear
        selectionStyle = .none
                
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
            contentView.leadingAnchor.constraint(
                equalTo: leadingAnchor, constant: 16
            ),
            contentView.trailingAnchor.constraint(
                equalTo: trailingAnchor, constant: -16
            ),
            contentView.topAnchor.constraint(
                equalTo: topAnchor, constant: 24
            ),
            contentView.heightAnchor.constraint(
                equalToConstant: 75
            ),
            
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

//MARK: - TitleTrackerCellDelegate
extension TitleTrackerCell: TitleTrackerCellDelegate {
    func updateCell(state: Bool) {
        showWarningStatus(state: state)
    }
}
