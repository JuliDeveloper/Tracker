import UIKit

final class DefaultStackView: UIStackView {
    
    //MARK: - Properties
    private let imageView: UIImageView = {
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
        label.widthAnchor.constraint(equalToConstant: 240).isActive = true
        return label
    }()
    
    //MARK: - Lifecycle
    init(title: String, image: String) {
        super.init(frame: .zero)
        
        axis = .vertical
        distribution = .fill
        alignment = .center
        spacing = 8
        translatesAutoresizingMaskIntoConstraints = false
        isHidden = true
        
        addArrangedSubview(imageView)
        addArrangedSubview(label)
        
        imageView.image = UIImage(named: image)
        label.text = title
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    func setValue(textLabel: String, imageTitle: String) {
        label.text = textLabel
        imageView.image = UIImage(named: imageTitle)
    }
}
