import UIKit

final class CustomViewController: UIViewController {
    
    //MARK: - Properties
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ypFontBold32
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    //MARK: - Lifecycle
    init(imageTitle: String, textLabel: String) {
        super.init(nibName: nil, bundle: nil)
        imageView.image = UIImage(named: imageTitle)
        titleLabel.text = textLabel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addElements()
        setConstraint()
    }
    
    private func addElements() {
        view.addSubview(imageView)
        view.addSubview(titleLabel)
    }
    
    private func setConstraint() {
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            imageView.topAnchor.constraint(
                equalTo: view.topAnchor
            ),
            imageView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            imageView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),
            
            titleLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,constant: 16
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -16
            ),
            titleLabel.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -291
            )
        ])
    }
}
