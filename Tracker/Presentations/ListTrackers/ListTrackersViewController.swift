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
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .ypBackgroundDatePicker
        label.font = UIFont.ypFontMedium17
        label.textAlignment = .center
        label.textColor = .ypDefaultBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.layer.cornerRadius = Constants.smallRadius
        label.layer.zPosition = 10
        return label
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "ru_Ru")
        picker.calendar.firstWeekday = 2
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.clipsToBounds = true
        picker.layer.cornerRadius = Constants.smallRadius
        picker.tintColor = .ypBlue
        picker.addTarget(
            self,
            action: #selector(datePickerValueChanged),
            for: .valueChanged
        )
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
    
    private lazy var searchTextField: UISearchTextField = {
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
        
        textField.addTarget(
            self,
            action: #selector(searchTracker),
            for: .editingChanged
        )
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
    
    private let params = GeometricParams(
        cellCount: 2,
        leftInset: 16,
        rightInset: 16,
        cellSpacing: 9
    )
    
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate: Date? = nil
    
    private var isSearching: Bool {
        return !(searchTextField.text?.isEmpty ?? false)
    }
    private var isCheckDate: Bool {
        return datePicker.date == currentDate
    }
    private var isFiltering: Bool {
        return isSearching || isCheckDate
    }
    
    private let dataManager = DataManager.shared
   
    //MARK: - Lifecycle
    override func viewDidLoad() {
        getData()
        configureView()
        addElements()
        setupConstraints()
        configureCollectionView()
        changeScenario()
        updateDateLabelTitle(with: Date())
    }
    
    //MARK: - Helpers
    private func configureView() {
        view.backgroundColor = .ypWhite
        searchTextField.delegate = self
        searchTextField.returnKeyType = .done
        filterButton.layer.zPosition = 2
    }
    
    private func getData() {
        categories = dataManager.getCategories()
    }
    
    private func addElements() {
        view.addSubview(headerView)
        view.addSubview(defaultStackView)
        view.addSubview(collectionView)
        view.addSubview(filterButton)
        
        headerView.addSubview(plusButton)
        headerView.addSubview(titleHeader)
        headerView.addSubview(dateLabel)
        headerView.addSubview(datePicker)
        headerView.addSubview(searchStackView)
        searchStackView.addArrangedSubview(searchTextField)
        searchStackView.addArrangedSubview(cancelButton)
    }
    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(
            TrackerCell.self,
            forCellWithReuseIdentifier: Constants.taskCellIdentifier
        )
        collectionView.register(
            HeaderSectionView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: Constants.headerCellIdentifier
        )
        
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
            
            dateLabel.trailingAnchor.constraint(
                equalTo: headerView.trailingAnchor
            ),
            dateLabel.centerYAnchor.constraint(
                equalTo: titleHeader.centerYAnchor
            ),
            dateLabel.widthAnchor.constraint(
                equalToConstant: 77
            ),
            dateLabel.heightAnchor.constraint(
                equalToConstant: 34
            ),
            
            datePicker.trailingAnchor.constraint(
                equalTo: headerView.trailingAnchor
            ),
            datePicker.centerYAnchor.constraint(
                equalTo: titleHeader.centerYAnchor
            ),
            datePicker.widthAnchor.constraint(
                equalToConstant: 77
            ),
            datePicker.heightAnchor.constraint(
                equalToConstant: 34
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
                equalTo: headerView.bottomAnchor,
                constant: 24
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
        if categories.isEmpty {
            collectionView.isHidden = true
            defaultStackView.isHidden = false
        } else {
            collectionView.isHidden = false
            filterButton.isHidden = false
            defaultStackView.isHidden = true
        }
    }
    
    private func formattedDate(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        return dateFormatter.string(from: date)
    }
    
    private func updateDateLabelTitle(with date: Date) {
        let dateString = formattedDate(from: date)
        dateLabel.text = dateString
    }
    
    private func updateSearchState() {
        searchTextField.text = ""
        visibleCategories.removeAll()
    }
    
    private func checkScenario() {
        if isFiltering {
            checkVisibleCategories()
        }
    }
    
    private func checkVisibleCategories() {
        if !visibleCategories.isEmpty {
            defaultStackView.isHidden = true
        } else {
            defaultStackView.isHidden = false
        }
    }
    
    @objc private func addTask() {
        let createTrackerVC = CreateTrackerViewController()
        createTrackerVC.updateDelegate = self
        let navVC = UINavigationController(rootViewController: createTrackerVC)
        present(navVC, animated: true)
    }
    
    @objc func datePickerValueChanged() {
        currentDate = datePicker.date
        updateDateLabelTitle(with: currentDate ?? Date())
                
        let calendar = Calendar.current
        let currentWeekDay = calendar.component(.weekday, from: currentDate ?? Date())
        
        visibleCategories = categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                let containsCurrentWeekDay = tracker.schedule?.contains(where: { weekDay in
                    return weekDay.numberValue == currentWeekDay
                }) ?? false
                return containsCurrentWeekDay
            }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        
        collectionView.reloadData()
        checkScenario()
    }
    
    @objc private func searchTracker() {
        let searchText = searchTextField.text ?? ""
     
        visibleCategories = categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                return tracker.title.lowercased().contains(searchText.lowercased())
            }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }.filter { $0.trackers.count > 0 }
        
        collectionView.reloadData()
        checkScenario()
    }

    @objc private func cancelSearch() {
        closeButton(state: true)
        searchTextField.resignFirstResponder()
        updateSearchState()
    }
    
    @objc private func selectFilter() {
        print("Tapped filter")
    }
}

//MARK: - UITextFieldDelegate
extension ListTrackersViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
        return isFiltering ? visibleCategories.count : categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.headerCellIdentifier, for: indexPath) as? HeaderSectionView else { return UICollectionReusableView() }
        
        let titleCategory = isFiltering
            ? visibleCategories[indexPath.row].title
            : categories[indexPath.row].title
        view.configureHeader(title: titleCategory)
        
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let trackers = isFiltering
            ? visibleCategories[section].trackers
            : categories[section].trackers
        return trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.taskCellIdentifier, for: indexPath) as? TrackerCell else { return UICollectionViewCell() }
        
        let cellData = isFiltering ? visibleCategories : categories
        let tracker = cellData[indexPath.section].trackers[indexPath.row]
        
        cell.delegate = self
        cell.configure(
            for: cell,
            tracker: tracker,
            title: tracker.title,
            emoji: tracker.emoji,
            color: tracker.color
        )
        
        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension ListTrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth =  availableWidth / CGFloat(params.cellCount)
        
        return CGSize(width: cellWidth, height: 132)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: params.leftInset, bottom: 32, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        params.leftInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        params.cellSpacing
    }
}

extension ListTrackersViewController: ListTrackersViewControllerDelegate {
    func updateCollectionView() {
        getData()
        collectionView.reloadData()
    }
    
    func updateButtonStateFromDate() -> Date {
        return datePicker.date
    }
    
    func updateCompletedTrackers(tracker: Tracker) {
        currentDate = datePicker.date
        
        if let index = completedTrackers.firstIndex(where: { $0.trackerId == tracker.id && $0.date == currentDate }) {
            completedTrackers.remove(at: index)
        } else {
            let trackerRecord = TrackerRecord(
                trackerId: tracker.id, date: currentDate ?? Date()
            )
            completedTrackers.append(trackerRecord)
        }
    }
}
