import UIKit

final class AddNewTrackerViewController: UIViewController {
    
    //MARK: - Properties
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var cancelButton: CustomButton = {
        let button = CustomButton(title: S.cancel)
        button.backgroundColor = .ypWhite
        button.setTitleColor(.ypRed, for: .normal)
        button.clipsToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton: CustomButton = {
        let button = CustomButton(title: S.create)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypGray
        button.isEnabled = false
        button.addTarget(self, action: #selector(create), for: .touchUpInside)
        return button
    }()
    
    private let titleStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let trackerTitleTextField: CustomTextField = {
        let textField = CustomTextField(
            text: S.TextField.NewHabit.placeholder
        )
        return textField
    }()
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.text = S.WarningMessage.title
        label.font = UIFont.ypFontMedium17
        label.textColor = .ypRed
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let counterStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let counterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ypFontBold32
        label.textColor = .ypBlack
        label.textAlignment = .center
        return label
    }()
    
    private lazy var minusButton: CustomCounterButton = {
        let button = CustomCounterButton(imageTitle: "minus")
        button.addTarget(self, action: #selector(subtractDay), for: .touchUpInside)
        return button
    }()
    
    private lazy var plusButton: CustomCounterButton = {
        let button = CustomCounterButton(imageTitle: "plus")
        button.addTarget(self, action: #selector(addDay), for: .touchUpInside)
        return button
    }()
        
    private let tableView = UITableView()
    
    private let collectionView = UICollectionView(
        frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()
    )
    private let params = GeometricParams(
        cellCount: 6,
        leftInset: 25,
        smallLeftInset: 20,
        rightInset: 25,
        smallRightInset: 20,
        cellSpacing: 17,
        smallCellSpacing: 8,
        lineCellSpacing: 12,
        smallLineCellSpacing: 8
    )
    
    private let emojis = Constants.emojis
    private let colors = Constants.colors
    
    private let trackerStore: TrackerStoreProtocol = TrackerStore()
    private var viewModel: AddCategoryViewModel
    
    private let uiColorMarshalling = UIColorMarshalling()
    
    private var trackerTitle = ""
    private var categorySubtitle = ""
    private var currentIndexCategory: IndexPath?
    private var setSchedule = [WeekDay]()
    private var selectedIndexPathsInSection: [Int: IndexPath] = [:]
    private var currentEmoji = String()
    private var currentColor: UIColor? = nil
    private var counterDays = 0
    
    var tracker: Tracker?
    var category: TrackerCategory?
    var titlesCells: [String] = []
    var isIrregular = Bool()
    var isEditTracker = Bool()
    var isCompletedTrackerToday = Bool()
    
    weak var updateDelegate: ListTrackersViewControllerDelegate?
    
    //MARK: - Lifecycle
    init(viewModel: AddCategoryViewModel = AddCategoryViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        configureNavBar()
        addElements()
        configureScrollView()
        configureTableView()
        configureTextField()
        configureCollectionView()
        showScenario()
        
        if isIrregular {
            setSchedule = []
            WeekDay.allCases.forEach { setSchedule.append($0) }
        }
        
        checkTracker()
        checkDate()
        updateCreateButton()
        
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeight(for: collectionView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateDelegate?.updateCollectionView()
    }
    
    //MARK: - Helpers
    private func addElements() {
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        
        if isEditTracker {
            contentView.addSubview(counterStackView)
            
            counterStackView.addArrangedSubview(minusButton)
            counterStackView.addArrangedSubview(counterLabel)
            counterStackView.addArrangedSubview(plusButton)
        }
        
        contentView.addSubview(titleStackView)
        contentView.addSubview(tableView)
        contentView.addSubview(collectionView)
        contentView.addSubview(buttonsStackView)
        
        titleStackView.addArrangedSubview(trackerTitleTextField)
        
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(createButton)
    }
    
    private func configureNavBar() {
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.ypFontMedium16,
            .foregroundColor: UIColor.ypBlack
        ]
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    private func configureScrollView() {
        scrollView.frame = view.bounds
        scrollView.contentSize = CGSize(width: view.bounds.width, height: view.bounds.height)
        scrollView.isScrollEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .ypWhite
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.delegate = self
        scrollView.addGestureRecognizer(tapGesture)
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellIdentifier)
        
        tableView.separatorStyle = .singleLine
        
        tableView.backgroundColor = .ypBackground
        tableView.layer.cornerRadius = Constants.bigRadius
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureTextField() {
        trackerTitleTextField.delegate = self
        trackerTitleTextField.returnKeyType = .done
        trackerTitleTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.allowsMultipleSelection = true
        collectionView.backgroundColor = .clear
        collectionView.register(AddNewTrackerCell.self, forCellWithReuseIdentifier: Constants.cellCollectionView)
        
        collectionView.register(
            HeaderSectionView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: Constants.headerCellIdentifier
        )
        
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func updateHeight(for view: UIView) {
        if let collectionView = view as? UICollectionView {
            collectionView.layoutIfNeeded()
            let height = collectionView.contentSize.height
            collectionView.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    private func setupConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        if isEditTracker {
            NSLayoutConstraint.activate([
                counterStackView.topAnchor.constraint(
                    equalTo: contentView.topAnchor, constant: 24
                ),
                counterStackView.centerXAnchor.constraint(
                    equalTo: contentView.centerXAnchor
                ),
                
                titleStackView.topAnchor.constraint(
                    equalTo: counterStackView.bottomAnchor, constant: 40
                )
            ])
        } else {
            NSLayoutConstraint.activate([
                titleStackView.topAnchor.constraint(
                    equalTo: contentView.topAnchor, constant: 24
                )
            ])
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            scrollView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            scrollView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            
            contentView.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor
            ),
            contentView.leadingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.leadingAnchor
            ),
            contentView.trailingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.trailingAnchor
            ),
            contentView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor
            ),
            contentView.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor
            ),
            
            titleStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 16
            ),
            titleStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -16
            ),
            
            tableView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 16
            ),
            tableView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -16
            ),
            tableView.topAnchor.constraint(
                equalTo: titleStackView.bottomAnchor, constant: 24
            ),
            
            collectionView.topAnchor.constraint(
                equalTo: tableView.bottomAnchor, constant: 32
            ),
            collectionView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            collectionView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            
            buttonsStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 16
            ),
            buttonsStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -16
            ),
            buttonsStackView.topAnchor.constraint(
                equalTo: collectionView.bottomAnchor
            ),
            buttonsStackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
            )
        ])
        
        if titlesCells.count == 1 {
            tableView.heightAnchor.constraint(
                equalToConstant: 75
            ).isActive = true
            tableView.separatorStyle = .none
        } else {
            tableView.heightAnchor.constraint(
                equalToConstant: 150
            ).isActive = true
        }
    }
    
    private func showScenario() {
        if 568 <= UIScreen.main.bounds.size.height,
           UIScreen.main.bounds.size.height <= 667 {
            setupConstraintsForSEScreen()
        } else {
            setupConstraintForDefaultScreen()
        }
    }
    
    private func setupConstraintForDefaultScreen() {
        scrollView.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor
        ).isActive = true
        
        setupConstraints()
    }
    
    private func setupConstraintsForSEScreen() {
        scrollView.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant:  -24
        ).isActive = true
        
        setupConstraints()
    }
    
    private func showViewController(_ viewController: UIViewController) {
        let viewController = viewController
        let navVC = UINavigationController(rootViewController: viewController)
        present(navVC, animated: true)
    }
    
    private func pluralizeDays(_ countOfDays: Int) -> String {
        let daysString = String.localizedStringWithFormat(
            NSLocalizedString("amountOfDay", comment: ""), countOfDays
        )
        
        return daysString
    }
    
    private func checkTracker() {
        if tracker != nil {
            trackerTitleTextField.text = tracker?.title
            setSchedule = tracker?.schedule ?? [WeekDay]()
            categorySubtitle = category?.title ?? ""
            currentEmoji = tracker?.emoji ?? ""
            currentColor = tracker?.color
            counterDays = tracker?.countRecords ?? 0
            counterLabel.text = pluralizeDays(counterDays)
        }
    }
    
    private func saveNewTracker() {
        guard let newCategory = viewModel.getCategory(at: currentIndexCategory ?? IndexPath()) else { return }
        
        let newTracker = Tracker(
            id: UUID(),
            title: trackerTitle,
            color: currentColor ?? UIColor(),
            emoji: currentEmoji,
            schedule: setSchedule,
            countRecords: 0
        )
        
        do {
            try trackerStore.addNewTracker(from: newTracker, and: newCategory)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func updateTracker() {
        guard let tracker else { return }
        let newCategory = currentIndexCategory == nil ? self.category : viewModel.getCategory(at: currentIndexCategory ?? IndexPath())
        
        if isEditTracker {
            updateDelegate?.updateCompletedTrackers(tracker, counterDays)
        }
        
        do {
            try trackerStore.editTracker(
                tracker,
                trackerTitleTextField.text,
                newCategory,
                setSchedule,
                currentEmoji,
                currentColor,
                counterDays
            )
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    
    private func saveOrUpdateTracker() {
        if tracker == nil {
            saveNewTracker()
        } else {
            updateTracker()
        }
    }
    
    private func showWarningLabel(state: Bool) {
        UIView.animate(withDuration: 0.3) {
            if state {
                self.titleStackView.addArrangedSubview(self.warningLabel)
                self.warningLabel.alpha = 1
            } else {
                self.warningLabel.alpha = 0
                self.titleStackView.removeArrangedSubview(self.warningLabel)
                self.warningLabel.removeFromSuperview()
            }
        }
    }
    
    private func getSchedule(from array: [WeekDay]) -> String {
        let scheduleSubtitle = array.compactMap { $0.abbreviationValue }.joined(separator: ", ")
        return scheduleSubtitle
    }
    
    private func updateCreateButton() {
        if tracker != nil {
            createButton.setTitle(S.save, for: .normal)
            createButton.isEnabled = true
            createButton.backgroundColor = .ypBlack
        } else {
            if !trackerTitle.isEmpty && !categorySubtitle.isEmpty && currentColor != nil && !currentEmoji.isEmpty {
                createButton.isEnabled = true
                createButton.backgroundColor = .ypBlack
            } else {
                createButton.isEnabled = false
                createButton.backgroundColor = .ypGray
            }
        }
    }
    
    private func checkDate() {
        let calendar = Calendar.current
        let currentDate = calendar.startOfDay(
            for: Date()
        )
        let selectedDate = calendar.startOfDay(
            for: updateDelegate?.updateStateFromDate() ?? Date()
        )

        if selectedDate > currentDate {
            setupCounterButtons(isCompleted: isCompletedTrackerToday)
            plusButton.isEnabled = false
            minusButton.isEnabled = false
        } else if selectedDate <= currentDate {
            setupCounterButtons(isCompleted: isCompletedTrackerToday)
            plusButton.isEnabled = true
            minusButton.isEnabled = true
        }
    }
    
    private func setupCounterButtons(isCompleted: Bool) {
        if isCompleted {
            plusButton.layer.opacity = 0.3
            minusButton.layer.opacity = 1
            plusButton.isEnabled = false
            minusButton.isEnabled = true
        } else {
            plusButton.layer.opacity = 1
            minusButton.layer.opacity = 0.3
            plusButton.isEnabled = true
            minusButton.isEnabled = false
        }
    }
    
    private func setCounterDaysTracker(_ countDays: Int) {
        isCompletedTrackerToday.toggle()
        counterLabel.text = pluralizeDays(countDays)
        setupCounterButtons(isCompleted: isCompletedTrackerToday)
    }
    
    @objc func hideKeyboard() {
        scrollView.endEditing(true)
    }
    
    @objc private func textFieldDidChange() {
        if let text = trackerTitleTextField.text {
            trackerTitle = text
        }
    }
    
    @objc private func subtractDay() {
        counterDays -= 1
        setCounterDaysTracker(counterDays)
        
    }
    
    @objc private func addDay() {
        counterDays += 1
        setCounterDaysTracker(counterDays)
    }
    
    @objc private func cancel() {
        dismiss(animated: true)
    }
    
    @objc private func create() {
        saveOrUpdateTracker()
        dismiss(animated: true)
        presentingViewController?.dismiss(animated: true)
    }
}

//MARK: - UITextFieldDelegate
extension AddNewTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if newText.count >= 1 {
            updateCreateButton()
        } else {
            updateCreateButton()
        }
        
        if newText.count > 38 {
            showWarningLabel(state: true)
        } else {
            showWarningLabel(state: false)
        }
        
        return newText.count <= 38
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension AddNewTrackerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        titlesCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.cellIdentifier, for: indexPath
        )
        
        let title = titlesCells[indexPath.row]
        
        cell.backgroundColor = .ypBackground
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
                
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            
            content.text = title
            
            if indexPath.row == 0 {
                content.secondaryText = categorySubtitle
            } else {
                if setSchedule.count == 7 {
                    content.secondaryText = S.everyDay
                } else {
                    content.secondaryText = getSchedule(from: setSchedule)
                }
            }
            
            content.textProperties.font = UIFont.ypFontMedium17
            content.textProperties.color = .ypBlack
            content.secondaryTextProperties.font = UIFont.ypFontMedium17
            content.secondaryTextProperties.color = .ypGray
            
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = title
            
            if indexPath.row == 0 {
                cell.detailTextLabel?.text = categorySubtitle
            } else {
                if setSchedule == WeekDay.allCases {
                    cell.detailTextLabel?.text = S.everyDay
                } else {
                    cell.detailTextLabel?.text = getSchedule(from: setSchedule)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let vc = AddCategoryViewController(viewModel: viewModel)
            vc.delegate = self
            viewModel.getSelectedCategory(from: currentIndexCategory)
            showViewController(vc)
        } else {
            let vc = AddScheduleViewController()
            vc.delegate = self
            vc.schedule = setSchedule
            showViewController(vc)
        }
    }
}

//MARK: - UICollectionViewDelegateFlowLayout, UICollectionViewDataSource
extension AddNewTrackerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return Constants.emojis.count
        case 1:
            return Constants.colors.count
        default:
            break
        }
        
        return Int()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.headerCellIdentifier, for: indexPath) as? HeaderSectionView else { return UICollectionReusableView() }
        
        var title = ""
        switch indexPath.section {
        case 0:
            title = S.Emoji.title
        case 1:
            title = S.Color.title
        default:
            break
        }
        
        view.configureHeader(title: title)
        
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellCollectionView, for: indexPath) as? AddNewTrackerCell else { return UICollectionViewCell() }
        
        cell.delegate = self
        
        let emoji = emojis[indexPath.item]
        let color = colors[indexPath.item]
        
        switch indexPath.section {
        case 0: cell.configureCell(for: 0, title: emoji, color: nil)
        case 1: cell.configureCell(for: 1, title: nil, color: color)
        default: break
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? AddNewTrackerCell else { return }

        let emoji = emojis[indexPath.item]
        let color = colors[indexPath.item]

        guard let currentColor else { return }

        if tracker != nil {
            switch indexPath.section {
            case 0:
                cell.isSelected = emoji == currentEmoji
            case 1:
                cell.isSelected = uiColorMarshalling.toHexString(color:color) == uiColorMarshalling.toHexString(color: currentColor)
            default: break
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth =  availableWidth / CGFloat(params.cellCount)
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if 568 <= UIScreen.main.bounds.size.height,
           UIScreen.main.bounds.size.height <= 667 {
            return UIEdgeInsets(
                top: 30,
                left: params.smallLeftInset ?? 0,
                bottom: 46,
                right: params.smallRightInset ?? 0
            )
        } else {
            return UIEdgeInsets(
                top: 30,
                left: params.leftInset,
                bottom: 46,
                right: params.rightInset
            )
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if 568 <= UIScreen.main.bounds.size.height,
           UIScreen.main.bounds.size.height <= 667 {
            return params.smallLineCellSpacing ?? 0
        } else {
            return params.lineCellSpacing ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if 568 <= UIScreen.main.bounds.size.height,
           UIScreen.main.bounds.size.height <= 667 {
            return params.smallCellSpacing ?? 0
        } else {
            return params.cellSpacing
        }
    }
}

//MARK: - UpdateSubtitleDelegate
extension AddNewTrackerViewController: UpdateSubtitleDelegate {
    func updateCategorySubtitle(from string: String?, and indexPath: IndexPath?) {
        category = viewModel.getCategory(at: indexPath)
        
        categorySubtitle = string ?? ""
        currentIndexCategory = indexPath
        
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.reloadRows(at: [indexPath], with: .none)
        
        updateCreateButton()
    }
    
    func updateScheduleSubtitle(from weekDays: [WeekDay]?) {
        setSchedule = weekDays ?? []
        
        let indexPath = IndexPath(row: 1, section: 0)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

extension AddNewTrackerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view, view.isDescendant(of: tableView) {
            return false
        }
        return true
    }
}

extension AddNewTrackerViewController: AddNewTrackerCellDelegate {
    func cellTapped(_ cell: AddNewTrackerCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        let currentSection = indexPath.section
        
        if let previousSelectedIndexPath = selectedIndexPathsInSection[currentSection] {
            if let previousCell = collectionView.cellForItem(at: previousSelectedIndexPath) as? AddNewTrackerCell {
                previousCell.expandButton()
            }
            collectionView.deselectItem(at: previousSelectedIndexPath, animated: true)
        }
        
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        cell.shrinkButton()
        
        selectedIndexPathsInSection[currentSection] = indexPath
        
        if currentSection == 0 {
            currentEmoji = emojis[indexPath.item]
            updateCreateButton()
        } else {
            currentColor = colors[indexPath.item]
            updateCreateButton()
        }
    }
}
