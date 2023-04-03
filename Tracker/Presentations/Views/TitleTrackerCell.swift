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
    
    weak var delegateUpdateTitle: NewTitleTrackerCellDelegate?
    
    //MARK: - Helpers
    func configureCell(delegate: AddNewTrackerViewController) {
        backgroundColor = .clear
        selectionStyle = .none
        
        trackerTitleTextField.delegate = delegate
        trackerTitleTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
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
            cellStackView.topAnchor.constraint(
                equalTo: contentView.topAnchor,constant: 24
            ),
            cellStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 16
            ),
            cellStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -16
            ),
            cellStackView.heightAnchor.constraint(
                equalToConstant: 75
            ),
            cellStackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
            )
        ])
    }
    
    @objc private func textFieldDidChange() {
        if let text = trackerTitleTextField.text {
            delegateUpdateTitle?.updateTrackerTitle(text)
        }
    }
}

//MARK: - TitleTrackerCellDelegate
extension TitleTrackerCell: TitleTrackerCellDelegate {
    func updateCell(state: Bool) {
        showWarningStatus(state: state)
    }
}
