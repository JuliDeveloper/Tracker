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
    
    private let defaultStackView = DefaultStackView(
        title: "Что будем отслеживать?"
    )
    private let collectionView = UICollectionView(
        frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Фильтры", for: .normal)
        button.backgroundColor = .ypBlue
        button.titleLabel?.font = UIFont.ypFontMedium17
        button.tintColor = .ypDefaultWhite
        button.addTarget(
            self,
            action: #selector(selectFilter),
            for: .touchUpInside
        )
        button.layer.cornerRadius = Constants.bigRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    private var tasksList: [String] = []
    private let params = GeometricParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 9)
   
    //MARK: - Lifecycle
    override func viewDidLoad() {
        configureView()
        addElements()
        setupConstraints()
        configureCollectionView()
        changeScenario()
    }
    
    //MARK: - Helpers
    private func configureView() {
        view.backgroundColor = .ypWhite
        searchTextField.delegate = self
        filterButton.layer.zPosition = 2
    }
    
    private func addElements() {
        view.addSubview(headerView)
        view.addSubview(defaultStackView)
        view.addSubview(collectionView)
        view.addSubview(filterButton)
        
        headerView.addSubview(plusButton)
        headerView.addSubview(titleHeader)
        headerView.addSubview(datePicker)
        headerView.addSubview(searchStackView)
        searchStackView.addArrangedSubview(searchTextField)
        searchStackView.addArrangedSubview(cancelButton)
    }
    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(TaskCell.self, forCellWithReuseIdentifier: Constants.taskCellIdentifier)
        collectionView.register(HeaderSectionView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.headerCellIdentifier)
        
        collectionView.backgroundColor = .clear
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
                equalTo: headerView.bottomAnchor,
                constant: 220
            ),
            
            collectionView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            collectionView.topAnchor.constraint(
                equalTo: headerView.bottomAnchor
            ),
            collectionView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            collectionView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),
            
            filterButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -17
            ),
            filterButton.heightAnchor.constraint(
                equalToConstant: 50
            ),
            filterButton.widthAnchor.constraint(
                equalToConstant: 114
            ),
            filterButton.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            )
        ])
    }
    
    private func closeButton(state: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.cancelButton.isHidden = state
        }
    }
    
    private func changeScenario() {
        if tasksList.isEmpty {
            collectionView.isHidden = true
            defaultStackView.isHidden = false
        } else {
            collectionView.isHidden = false
            filterButton.isHidden = false
            defaultStackView.isHidden = true
        }
    }
    
    @objc private func addTask() {
        let createTrackerVC = CreateTrackerViewController()
        let navVC = UINavigationController(rootViewController: createTrackerVC)
        present(navVC, animated: true)
    }

    @objc private func cancelSearch() {
        closeButton(state: true)
        searchTextField.resignFirstResponder()
    }
    
    @objc private func selectFilter() {
        print("Tapped filter")
    }
}

//MARK: - UITextFieldDelegate
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

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension ListTrackersViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
       4
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.headerCellIdentifier, for: indexPath) as? HeaderSectionView else { return UICollectionReusableView() }
        
        view.configureHeader(title: "Домашний уют")
        
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.taskCellIdentifier, for: indexPath) as? TaskCell else { return UICollectionViewCell() }
        
        cell.configure(for: cell, title: "Кошка заслонила камеру на созвоне", emoji: "😻", counter: "5 дней", color: .ypColorSection2)
        
        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension ListTrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let size = CGSize(width: collectionView.frame.width, height: 49)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth =  availableWidth / CGFloat(params.cellCount)
        
        return CGSize(width: cellWidth, height: 132)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: params.leftInset, bottom: 0, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        params.leftInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        params.cellSpacing
    }
}
