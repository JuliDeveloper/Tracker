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
    
    private lazy var openListTrackerButton: UIButton = {
        let button = CustomButton(title: "Вот это технологии!")
        button.addTarget(
            self,
            action: #selector(openTrackers),
            for: .touchUpInside
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        view.addSubview(openListTrackerButton)
    }
    
    private func setConstraint() {
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            openListTrackerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            openListTrackerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            openListTrackerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -71),
            
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: openListTrackerButton.topAnchor, constant: -105)
        ])
    }
    
    @objc private func openTrackers() {
        let tabBarVC = TabBarController()
        
        let window = UIApplication.shared.windows.first
        window?.rootViewController = tabBarVC
        window?.makeKeyAndVisible()
    }
}
