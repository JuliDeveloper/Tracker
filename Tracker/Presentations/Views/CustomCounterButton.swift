import UIKit

final class CustomCounterButton: UIButton {
    
    //MARK: - Lifecycle
    init(imageTitle: String) {
        super.init(frame: .zero)
        let pointSize = UIImage.SymbolConfiguration(pointSize: 11)
        let image = UIImage(systemName: imageTitle, withConfiguration: pointSize)
        setImage(image, for: .normal)
        backgroundColor = .ypColorSection2
        tintColor = .ypWhite
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 34).isActive = true
        widthAnchor.constraint(equalToConstant: 34).isActive = true
        layer.cornerRadius = 34 / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
