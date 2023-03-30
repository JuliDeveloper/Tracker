import UIKit

final class AddNewTrackerViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    
    private let buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var cancelButton: CustomButton = {
        let button = CustomButton(title: "Отменить")
        button.backgroundColor = .ypWhite
        button.setTitleColor(.ypRed, for: .normal)
        button.clipsToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton: CustomButton = {
        let button = CustomButton(title: "Создать")
        button.setTitleColor(.ypDefaultWhite, for: .normal)
        button.backgroundColor = .ypGray
        button.addTarget(self, action: #selector(create), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        configureNavBar()
        configureScrollView()
        addElements()
        setupConstraints()
    }
    
    private func configureNavBar() {
        title = "Новая привычка"
        
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.ypFontMedium16,
            .foregroundColor: UIColor.ypBlack
        ]
    }
    
    private func configureScrollView() {
        scrollView.frame = CGRect(
            x: 0, y: 0,
            width: view.bounds.width, height: view.bounds.height
        )
        scrollView.contentSize.width = view.bounds.size.width
        scrollView.contentSize.height = view.bounds.size.height
        scrollView.isScrollEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = true
        
        scrollView.backgroundColor = .red
        scrollView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func addElements() {
        view.addSubview(buttonsStackView)
        view.addSubview(scrollView)
        
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(createButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonsStackView.safeAreaLayoutGuide.topAnchor, constant: -10)
        ])
    }
    
    @objc private func cancel() {
        dismiss(animated: true)
    }
    
    @objc private func create() {
        dismiss(animated: true)
    }
}
