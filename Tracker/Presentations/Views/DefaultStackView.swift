import UIKit

final class DefaultStackView: UIStackView {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "star")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.ypFontMedium12
        label.textColor = .ypBlack
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 160).isActive = true
        return label
    }()
    
    init(title: String) {
        super.init(frame: .zero)
        
        axis = .vertical
        distribution = .fill
        alignment = .center
        spacing = 8
        translatesAutoresizingMaskIntoConstraints = false
        isHidden = true
        
        addArrangedSubview(imageView)
        addArrangedSubview(label)
        
        label.text = title
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
