//
//  AnalysisViewController.swift
//  YNDX_finApp_iOS
//
//  Created by Савелий Коцур on 11.07.2025.
//

import Foundation
import UIKit

class AnalysisViewController: UIViewController {
    let direction: Direction
    var onBack: (() -> Void)?
    // MARK: - UI
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    // Header UI
    private let sortControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["По дате", "По сумме"])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    // MARK: - Data
    private var allTransactions: [Transaction] = []
    private var filteredTransactions: [Transaction] = []
    private var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    private var endDate: Date = Date()
    private var sortType: SortType = .date
    private var categories: [Category] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        configureNavigationBar()
        setupTableView()
        loadData()
    }

    init(direction: Direction) {
        self.direction = direction
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .systemGroupedBackground
        tableView.register(OperationCell.self, forCellReuseIdentifier: "OperationCell")
        tableView.register(DatePickerCell.self, forCellReuseIdentifier: "DatePickerCell")
        tableView.register(SumCell.self, forCellReuseIdentifier: "SumCell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func configureNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.prefersLargeTitles = true
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemGroupedBackground
        navigationController?.navigationBar.standardAppearance = appearance

        title = "Анализ"
        navigationItem.largeTitleDisplayMode = .always

        navigationController?.navigationBar.tintColor = UIColor(named: "toolbarAccent")
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.setTitle("Назад", for: .normal)
        backButton.setTitleColor(UIColor(named: "toolbarAccent"), for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        backButton.semanticContentAttribute = .forceLeftToRight
        backButton.tintColor = UIColor(named: "toolbarAccent")
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    // MARK: - Data Loading & Logic
    private func loadData() {
        Task {
            do {
                let categories = try await CategoriesService.shared.categories(direction: direction)
                self.categories = categories
                let categoryIds = Set(categories.map { $0.id })
                let all = try await TransactionsService.shared.transactions(from: startDate, to: endDate)
                let filtered = all.filter { categoryIds.contains($0.categoryId) }
                self.allTransactions = filtered
                self.applyFiltersAndSort()
            } catch {
                print("Ошибка при загрузке транзакций: \(error)")
            }
        }
    }
    
    private func category(for id: Int) -> Category? {
        categories.first { $0.id == id }
    }
    
    private func applyFiltersAndSort() {
        // Фильтрация по датам
        filteredTransactions = allTransactions.filter { $0.transactionDate >= startDate && $0.transactionDate <= endDate }
        // Сортировка
        switch sortType {
        case .date:
            filteredTransactions.sort { $0.transactionDate > $1.transactionDate }
        case .amount:
            filteredTransactions.sort { $0.amount > $1.amount }
        }
        tableView.reloadData()
    }
    
    @objc private func sortChanged() {
        sortType = sortControl.selectedSegmentIndex == 0 ? .date : .amount
        applyFiltersAndSort()
    }
    
    @objc private func backButtonTapped() {
        onBack?()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension AnalysisViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4 // start, end, sort, sum
        } else {
            return filteredTransactions.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                // Start date
                let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
                cell.configure(title: "Период: начало", date: startDate)
                cell.dateChanged = { [weak self] newDate in
                    guard let self = self else { return }
                    self.startDate = newDate
                    if self.startDate > self.endDate {
                        self.endDate = self.startDate
                    }
                    self.applyFiltersAndSort()
                }
                return cell
            } else if indexPath.row == 1 {
                // End date
                let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
                cell.configure(title: "Период: конец", date: endDate)
                cell.dateChanged = { [weak self] newDate in
                    guard let self = self else { return }
                    self.endDate = newDate
                    if self.endDate < self.startDate {
                        self.startDate = self.endDate
                    }
                    self.applyFiltersAndSort()
                }
                return cell
            } else if indexPath.row == 2 {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "SortCell")
                cell.selectionStyle = .none
                cell.backgroundColor = .secondarySystemGroupedBackground

                let titleLabel = UILabel()
                titleLabel.text = "Сортировка:"
                titleLabel.font = UIFont.systemFont(ofSize: 17)
                titleLabel.translatesAutoresizingMaskIntoConstraints = false

                sortControl.removeFromSuperview()
                sortControl.addTarget(self, action: #selector(sortChanged), for: .valueChanged)
                sortControl.translatesAutoresizingMaskIntoConstraints = false

                cell.contentView.addSubview(titleLabel)
                cell.contentView.addSubview(sortControl)

                NSLayoutConstraint.activate([
                    titleLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                    titleLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),

                    sortControl.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                    sortControl.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),

                    sortControl.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8),
                    cell.contentView.heightAnchor.constraint(equalToConstant: 48)
                ])

                return cell
            } else {
                // Sum
                let cell = tableView.dequeueReusableCell(withIdentifier: "SumCell", for: indexPath) as! SumCell
                let sum = filteredTransactions.reduce(0) { $0 + $1.amount }
                cell.configure(sum: sum)
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OperationCell", for: indexPath) as! OperationCell
            let transaction = filteredTransactions[indexPath.row]
            let sum = filteredTransactions.reduce(0) { $0 + $1.amount }
            let percent = sum > 0 ? (transaction.amount as NSDecimalNumber).doubleValue / (sum as NSDecimalNumber).doubleValue : 0
            if let category = category(for: transaction.categoryId) {
                cell.configure(with: transaction, categoryName: category.name, emoji: category.icon, percentage: percent)
            } else {
                cell.configure(with: transaction, categoryName: "Unknown", emoji: " ", percentage: percent)
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        }
        if section == 1 {
            return "Операции"
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
}

private enum SortType {
    case date
    case amount
}

// MARK: - DatePickerCell
class DatePickerCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let datePicker = UIDatePicker()
    var dateChanged: ((Date) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        titleLabel.font = .systemFont(ofSize: 17)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        datePicker.backgroundColor = .lightGreen.withAlphaComponent(0.8)
        datePicker.layer.cornerRadius = 8
        datePicker.clipsToBounds = true

        contentView.addSubview(titleLabel)
        contentView.addSubview(datePicker)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            datePicker.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    @objc private func datePickerChanged() {
        dateChanged?(datePicker.date)
    }

    func configure(title: String, date: Date) {
        titleLabel.text = title
        datePicker.date = date
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - SumCell
class SumCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let amountLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        titleLabel.font = .systemFont(ofSize: 17)
        titleLabel.text = "Сумма:"
        amountLabel.font = .systemFont(ofSize: 17)
        amountLabel.textAlignment = .right

        let stack = UIStackView(arrangedSubviews: [titleLabel, amountLabel])
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(sum: Decimal) {
        amountLabel.text = "\(sum.groupedString) ₽"
    }
}

//MARK: OperationCell
class OperationCell: UITableViewCell {
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    private let commentLabel = UILabel()
    private let amountLabel = UILabel()
    private let percentLabel = UILabel()
    private let chevronImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        emojiLabel.font = UIFont.systemFont(ofSize: 14)
        emojiLabel.textAlignment = .center
        emojiLabel.layer.cornerRadius = 14
        emojiLabel.clipsToBounds = true
        emojiLabel.backgroundColor = UIColor(named: "lightGreen")
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        commentLabel.font = UIFont.systemFont(ofSize: 13)
        commentLabel.textColor = UIColor.systemGray
        commentLabel.translatesAutoresizingMaskIntoConstraints = false

        amountLabel.font = UIFont.systemFont(ofSize: 17)
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.setContentHuggingPriority(.required, for: .horizontal)
        amountLabel.textAlignment = .right

        percentLabel.font = UIFont.systemFont(ofSize: 13)
        percentLabel.textColor = UIColor.systemGray
        percentLabel.translatesAutoresizingMaskIntoConstraints = false

        chevronImageView.image = UIImage(systemName: "chevron.right")
        chevronImageView.tintColor = UIColor.systemGray
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(emojiLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(commentLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(percentLabel)
        contentView.addSubview(chevronImageView)

        NSLayoutConstraint.activate([
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emojiLabel.widthAnchor.constraint(equalToConstant: 28),
            emojiLabel.heightAnchor.constraint(equalToConstant: 28),

            titleLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -8),

            commentLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            commentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            commentLabel.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -8),

            amountLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            amountLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),

            percentLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 2),
            percentLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),

            chevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 10),
            chevronImageView.heightAnchor.constraint(equalToConstant: 16),
        ])
        contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
    }

    func configure(with transaction: Transaction, categoryName: String, emoji: Character, percentage: Double) {
        emojiLabel.text = String(emoji)
        titleLabel.text = categoryName
        commentLabel.text = transaction.comment
        amountLabel.text = "\(transaction.amount.groupedString) ₽"
        percentLabel.text = String(format: "%.1f%%", percentage * 100)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
