import UIKit

final class AddNewTrackerCell: UICollectionViewCell {
    
    //MARK: - Properties
    let button = UIButton()
    
    //MARK: - Helpers
    func configureCell(for section: Int, title: String?, color: UIColor?) {
        contentView.addSubview(button)
        
        button.layer.cornerRadius = Constants.smallRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        let width: CGFloat = 40
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(
                equalTo: contentView.centerXAnchor
            ),
            button.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),
            button.heightAnchor.constraint(
                equalToConstant: width
            ),
            button.widthAnchor.constraint(
                equalToConstant: width
            )
        ])
        
        switch section {
        case 0:
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.ypFontBold32
        case 1:
            button.backgroundColor = color
        default:
            break
        }
    }
}
