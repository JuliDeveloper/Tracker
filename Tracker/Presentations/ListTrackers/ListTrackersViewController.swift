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
        let title = NSLocalizedString("trackers.title", comment: "")
        let label = UILabel()
        label.text = title
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
        picker.locale = Locale.current
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
        
        let placeholderTitle = NSLocalizedString(
            "textField.search.placeholder",
            comment: ""
        )
        let attributedPlaceholder = NSAttributedString(
            string: placeholderTitle,
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
        let title = NSLocalizedString("cancel", comment: "")
        button.setTitle(title, for: .normal)
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
    
    private var defaultStackView: DefaultStackView = {
        let title = NSLocalizedString(
            "stackView.startTracking.title",
            comment: ""
        )
        let stack =  DefaultStackView(
            title: title, image: "star"
        )
        return stack
    }()
    
    private let collectionView = UICollectionView(
        frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    private lazy var filterButton: UIButton = {
        let title = NSLocalizedString("filter.title", comment: "")
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
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
        smallLeftInset: nil,
        rightInset: 16,
        smallRightInset: nil,
        cellSpacing: 9,
        smallCellSpacing: nil,
        lineCellSpacing: nil,
        smallLineCellSpacing: nil
    )
    
    private lazy var trackerStore: TrackerStoreProtocol = TrackerStore(delegate: self)
    private let trackerCategoryStore: TrackerCategoryStoreProtocol = TrackerCategoryStore()
    private let trackerRecordStore: TrackerRecordsStoreProtocol = TrackerRecordsStore()
    
    private var categories: [TrackerCategory] = []
    private var currentDate: Date {
        getDate()
    }
       
    //MARK: - Lifecycle
    override func viewDidLoad() {
        categories = trackerCategoryStore.categories
        print(categories)
        getStartData()
        configureView()
        addElements()
        setupConstraints()
        configureCollectionView()
        showScenario()
        updateDateLabelTitle(with: currentDate)
    }
    
    //MARK: - Helpers
    private func configureView() {
        view.backgroundColor = .ypWhite
        searchTextField.delegate = self
        searchTextField.returnKeyType = .done
        filterButton.layer.zPosition = 2
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
    
    private func getStartData() {
        let calendar = Calendar.current
        let currentWeekDay = calendar.component(.weekday, from: currentDate)
        trackerStore.loadInitialData(date: String(currentWeekDay))
        collectionView.reloadData()
    }
    
    private func showScenario() {
        if trackerStore.numberOfSections == 0 {
            collectionView.isHidden = true
            filterButton.isHidden = true
            defaultStackView.isHidden = false
        } else {
            collectionView.isHidden = false
            filterButton.isHidden = false
            defaultStackView.isHidden = true
        }
    }
    
    private func changeScenario() {
        let newTitle = NSLocalizedString(
            "stackView.notFoundTrackers.title",
            comment: ""
        )
        
        if trackerStore.numberOfSections == 0 {
            collectionView.isHidden = true
            filterButton.isHidden = true
            defaultStackView.setValue(
                textLabel: newTitle,
                imageTitle: "errorSearch"
            )
            defaultStackView.isHidden = false
        } else {
            collectionView.isHidden = false
            filterButton.isHidden = false
            defaultStackView.isHidden = true
        }
    }
    
    private func formattedDate(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        let locale = Locale.current.identifier
        
        if locale.hasPrefix("ru") {
            dateFormatter.dateFormat = "dd.MM.yy"
        } else if locale.hasPrefix("zh") {
            dateFormatter.dateFormat = "yy/M/d"
        } else {
            dateFormatter.dateFormat = "MM/dd/yy"
        }
        
        return dateFormatter.string(from: date)
    }
    
    private func updateDateLabelTitle(with date: Date) {
        let dateString = formattedDate(from: date)
        dateLabel.text = dateString
    }
    
    private func updateSearchState() {
        searchTextField.text = ""
    }
    
    private func updateData() {
        collectionView.reloadData()
        changeScenario()
    }
    
    private func getDate() -> Date {
        let calendar = Calendar.current
        let selectedDate = datePicker.date
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        guard let currentDate = calendar.date(from: dateComponents) else { return Date()}
        return currentDate
    }
    
    private func showViewController(with array: [String], isIrregular: Bool, _ tracker: Tracker, _ category: TrackerCategory?, navBarTitle: String, isEditTracker: Bool) {
        let editTrackerVC = AddNewTrackerViewController()
        editTrackerVC.titlesCells = array
        editTrackerVC.isIrregular = isIrregular
        editTrackerVC.tracker = tracker
        editTrackerVC.category = category
        editTrackerVC.title = navBarTitle
        editTrackerVC.isEditTracker = isEditTracker
        let navBar = UINavigationController(rootViewController: editTrackerVC)
        present(navBar, animated: true)
    }
    
    private func editTracker(from indexPath: IndexPath) {
        guard
            let currentTracker = self.trackerStore.getTracker(at: indexPath)
        else {
            return
        }
        
        let currentCategory = self.categories[indexPath.section]
        
        let categoryTitle = NSLocalizedString("category.title", comment: "")
        let scheduleTitle = NSLocalizedString("schedule.title", comment: "")
        let editHabitTitle = NSLocalizedString("navBar.editHabit.title", comment: "")
        let editIrregularEventTitle = NSLocalizedString("navBar.editIrregularEvent.title", comment: "")

        if currentTracker.schedule == WeekDay.allCases {
            showViewController(
                with: [categoryTitle],
                isIrregular: true,
                currentTracker,
                currentCategory,
                navBarTitle: editIrregularEventTitle,
                isEditTracker: true
            )
        } else {
            showViewController(
                with: [categoryTitle, scheduleTitle],
                isIrregular: true,
                currentTracker,
                currentCategory,
                navBarTitle: editHabitTitle,
                isEditTracker: true
            )
        }
    }
    
    private func deleteTracker(from indexPath: IndexPath) {
        let deleteTitle = NSLocalizedString("delete", comment: "")
        let cancelTitle = NSLocalizedString("cancel", comment: "")
        let alertTitle = NSLocalizedString("alert.deleteTracker.title", comment: "")
        
        let deleteAction = UIAlertAction(title: deleteTitle, style: .destructive) { [weak self] _ in
            guard let self else { return }
            
            do {
                try self.trackerStore.deleteTracker(at: indexPath)
            } catch let error {
                print(error.localizedDescription)
            }
        }
        let cancelAction = UIAlertAction(title: cancelTitle, style: .default)
        
        showAlert(
            title: alertTitle,
            message: nil,
            preferredStyle: .actionSheet,
            actions: [deleteAction, cancelAction]
        )
    }

    private func saveTrackerRecord(for trackerId: UUID) {
        let trackerRecord = TrackerRecord(
            trackerId: trackerId,
            date: currentDate
        )
        try? trackerRecordStore.saveRecord(trackerRecord)
    }

    private func deleteTrackerRecord(for trackerId: UUID) {
        let trackerRecord = TrackerRecord(
            trackerId: trackerId,
            date: currentDate
        )
        try? trackerRecordStore.deleteRecord(trackerRecord)
    }
    
    @objc private func addTask() {
        let createTrackerVC = CreateTrackerViewController()
        createTrackerVC.updateDelegate = self
        let navVC = UINavigationController(rootViewController: createTrackerVC)
        present(navVC, animated: true)
    }
    
    @objc func datePickerValueChanged() {
        //updateDateLabelTitle(with: currentDate)
                        
        let calendar = Calendar.current
        let currentWeekDay = calendar.component(.weekday, from: currentDate)
        trackerStore.trackerFiltering(from: String(currentWeekDay), or: nil)
        updateData()
    }
    
    @objc private func searchTracker() {
        let searchText = searchTextField.text ?? ""
        trackerStore.trackerFiltering(from: nil, or: searchText)
        updateData()
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
        trackerStore.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.headerCellIdentifier, for: indexPath) as? HeaderSectionView else { return UICollectionReusableView() }
        
        let titleCategory = trackerStore.headerTitleSection(indexPath.section)

        if titleCategory != nil {
            view.configureHeader(title: titleCategory ?? "")
        }
        
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        trackerStore.numberOfRowsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.taskCellIdentifier, for: indexPath) as? TrackerCell else { return UICollectionViewCell() }
        
        guard let tracker = trackerStore.getTracker(at: indexPath) else { return UICollectionViewCell() }
        
        let trackerRecords = trackerStore.getRecords(for: indexPath)
        let isCompleted = completedTracker(tracker.id, trackerRecords)
        
        cell.configure(for: cell, tracker: tracker, trackerRecords, isCompleted: isCompleted)
        cell.delegate = self
        cell.interactionDelegate = self
        
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
    func updateButtonStateFromDate() -> Date {
        return datePicker.date
    }
    
    func completedTracker(_ trackerId: UUID, _ trackerRecords: Set<TrackerRecord>) -> Bool {
        let selectedDate = datePicker.date
        return trackerRecords.contains(where: { record in
            record.trackerId == trackerId && Calendar.current.isDate(record.date, inSameDayAs: selectedDate)
        })
    }
    
    func updateCompletedTrackers(cell: TrackerCell, _ tracker: Tracker) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        let trackerRecords = trackerStore.getRecords(for: indexPath)
        
        if completedTracker(tracker.id, trackerRecords) {
            deleteTrackerRecord(for: tracker.id)
        } else {
            saveTrackerRecord(for: tracker.id)
        }
        
        let updatedTrackerRecords = trackerStore.getRecords(for: indexPath)
        let isCompleted = completedTracker(tracker.id, updatedTrackerRecords)
        
        cell.updateTrackerState(isCompleted: isCompleted)
        
        collectionView.reloadItems(at: [indexPath])
    }
    
    func updateCollectionView() {
        collectionView.reloadData()
    }
}

// MARK: - TrackerStoreDelegate
extension ListTrackersViewController: TrackerStoreDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        changeScenario()
        collectionView.performBatchUpdates {
            collectionView.insertSections(update.insertedSections)
            collectionView.insertItems(at: update.insertedIndexes)
            collectionView.deleteSections(update.deletedSections)
            collectionView.deleteItems(at: update.deletedIndexPaths)
            collectionView.reloadSections(update.updateSections)
            collectionView.reloadItems(at: update.updateIndexPaths)
        }
    }
}

//MARK: - TrackerCellDelegate
extension ListTrackersViewController: TrackerCellDelegate {
    func contextMenuNeeded(forCell cell: TrackerCell) -> UIContextMenuConfiguration? {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return nil
        }
        
        let pinTitle = NSLocalizedString("pin", comment: "")
        let unpinTitle = NSLocalizedString("unpin", comment: "")
        let editTitle = NSLocalizedString("edit", comment: "")
        let deleteTitle = NSLocalizedString("delete", comment: "")
        
        let pinAction = UIAction(title: pinTitle) { _ in
            print("! pin !")
        }
        
        let unpinAction = UIAction(title: unpinTitle) { _ in
            print("!! unpin !!")
        }
        
        let editAction = UIAction(title: editTitle) { [weak self] _ in
            guard let self else { return }
            self.editTracker(from: indexPath)
        }
        
        let deleteAction = UIAction(title: deleteTitle, attributes: .destructive) { [weak self] _ in
            guard let self else { return }
            self.deleteTracker(from: indexPath)
        }
        
        return UIContextMenuConfiguration(actionProvider: { _ in
            return UIMenu(children: [pinAction, editAction, deleteAction])
        })
    }
}
