import UIKit

final class CustomButton: UIButton {
    
    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        backgroundColor = .ypBlack
        setTitleColor(.ypWhite, for: .normal)
        titleLabel?.font = UIFont.ypFontMedium16
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 60).isActive = true
        layer.cornerRadius = Constants.bigRadius
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
