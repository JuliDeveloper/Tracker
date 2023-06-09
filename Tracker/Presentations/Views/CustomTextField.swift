import UIKit

final class CustomTextField: UITextField {
    
    //MARK: - Lifecycle
    init(text: String) {
        super.init(frame: .zero)
        font = UIFont.ypFontMedium17
        textColor = .ypBlack
        backgroundColor = .ypBackground
        
        translatesAutoresizingMaskIntoConstraints = false
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
        
        heightAnchor.constraint(equalToConstant: 75).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
