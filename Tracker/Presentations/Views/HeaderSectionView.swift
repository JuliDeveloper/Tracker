import UIKit

final class HeaderSectionView: UICollectionReusableView {
    
    //MARK: - Properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = UIFont.ypFontBold19
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - Helpers
    func configureHeader(title: String) {
        addSubview(titleLabel)
        titleLabel.text = title
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor, constant: 28
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: trailingAnchor, constant: -28
            )
        ])
    }
}
