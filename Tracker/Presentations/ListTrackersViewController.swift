import UIKit

final class ListTrackersViewController: UIViewController {
    //MARK: - Properties
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plusListTracker"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addTask), for: .touchUpInside)
        return button
    }()
    
    private let titleHeader: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.textColor = .ypBlack
        label.font = UIFont.ypFontBold34
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.locale = Locale(identifier: "ru_RU")
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.clipsToBounds = true
        picker.layer.cornerRadius = Constants.smallRadius
        picker.tintColor = .ypBlue
        picker.setValue(UIColor.ypBlack, forKeyPath: "textColor")
        return picker
    }()
    
    private let searchStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let searchTextField: UISearchTextField = {
        let textField = UISearchTextField()
        textField.backgroundColor = .ypBackground
        textField.textColor = .ypBlack
        textField.font = UIFont.ypFontMedium17
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.cornerRadius = Constants.mediumRadius
        textField.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.ypGray
        ]
        let attributedPlaceholder = NSAttributedString(
            string: "Поиск",
            attributes: attributes
        )
        textField.attributedPlaceholder = attributedPlaceholder
        
        return textField
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.addTarget(
            self,
            action: #selector(cancelSearch),
            for: .touchUpInside
        )
        button.tintColor = .ypBlue
        button.titleLabel?.font = UIFont.ypFontMedium17
        button.isHidden = true
        return button
    }()
    
    private let defaultStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let defaultImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "star")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        return imageView
    }()
    
    private let defaultLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.ypFontMedium12
        label.textColor = .ypBlack
        return label
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        configureView()
        addElements()
        setupConstraints()
        
        searchTextField.delegate = self
    }
    
    //MARK: - Helpers
    private func configureView() {
        view.backgroundColor = .ypWhite
    }
    
    private func addElements() {
        view.addSubview(headerView)
        view.addSubview(defaultStackView)
                
        headerView.addSubview(plusButton)
        headerView.addSubview(titleHeader)
        headerView.addSubview(datePicker)
        headerView.addSubview(searchStackView)
        searchStackView.addArrangedSubview(searchTextField)
        searchStackView.addArrangedSubview(cancelButton)
        
        defaultStackView.addArrangedSubview(defaultImage)
        defaultStackView.addArrangedSubview(defaultLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 16
            ),
            headerView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 13
            ),
            headerView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -16
            ),
            headerView.heightAnchor.constraint(equalToConstant: 138),
            
            plusButton.leadingAnchor.constraint(
                equalTo: headerView.leadingAnchor,
                constant: 2
            ),
            plusButton.topAnchor.constraint(
                equalTo: headerView.topAnchor
            ),
            
            titleHeader.leadingAnchor.constraint(
                equalTo: headerView.leadingAnchor
            ),
            titleHeader.topAnchor.constraint(
                equalTo: plusButton.bottomAnchor,
                constant: 21
            ),
            
            datePicker.trailingAnchor.constraint(
                equalTo: headerView.trailingAnchor
            ),
            datePicker.centerYAnchor.constraint(
                equalTo: titleHeader.centerYAnchor
            ),
            datePicker.widthAnchor.constraint(
                equalToConstant: 100
            ),
    
            searchStackView.leadingAnchor.constraint(
                equalTo: headerView.leadingAnchor
            ),
            searchStackView.bottomAnchor.constraint(
                equalTo: headerView.bottomAnchor,
                constant: -10
            ),
            searchStackView.trailingAnchor.constraint(
                equalTo: headerView.trailingAnchor
            ),
            
            defaultStackView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            defaultStackView.topAnchor.constraint(
                equalTo: headerView.bottomAnchor, constant: 220
            )
        ])
    }
    
    private func closeButton(state: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.cancelButton.isHidden = state
        }
    }
    
    @objc private func addTask() {
        print("Tapped plus")
    }

    @objc private func cancelSearch() {
        closeButton(state: true)
        searchTextField.resignFirstResponder()
    }
}

extension ListTrackersViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        closeButton(state: false)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        closeButton(state: true)
    }
}
