import UIKit

final class CustomTextField: UITextField {
    init(text: String) {
        super.init(frame: .zero)
        font = UIFont.ypFontMedium17
        textColor = .ypBlack
        backgroundColor = .ypBackground
        
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 75).isActive = true
        layer.cornerRadius = Constants.bigRadius
        
        let spacer = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 75))
        leftView = spacer
        leftViewMode = .always
        
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.ypGray
        ]
        let attributedPlaceholder = NSAttributedString(
            string: text,
            attributes: attributes
        )
        self.attributedPlaceholder = attributedPlaceholder
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
