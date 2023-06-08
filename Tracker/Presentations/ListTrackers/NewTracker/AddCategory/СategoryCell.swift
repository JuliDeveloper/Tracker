import UIKit

final class CategoryCell: UITableViewCell {
    
    //MARK: - Properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ypFontMedium17
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - Helpers
    func configure(_ title: String, _ indexPath: IndexPath, _ lastIndex: Int, _ selectedIndexPath: IndexPath) {
        backgroundColor = .ypBackground
        selectionStyle = .none
        separatorInset = UIEdgeInsets(
            top: 0, left: 16, bottom: 0, right: 16
        )
                
        if indexPath.row == lastIndex {
            separatorInset = UIEdgeInsets(
                top: 0, left: bounds.size.width, bottom: 0, right: 0
            )
            
            let maskLayer = CAShapeLayer()
            maskLayer.path = UIBezierPath(
                roundedRect: bounds,
                byRoundingCorners: [.bottomLeft, .bottomRight],
                cornerRadii: CGSize(width: 16, height: 16)
            ).cgPath
            layer.mask = maskLayer
        } else {
            layer.mask = nil
        }
        
        if indexPath == selectedIndexPath {
            accessoryType = .checkmark
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.text = title
        setConstraints()
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -41)
        ])
    }
}
