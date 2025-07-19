//
//  OperationViewModel.swift
//  YNDX_finApp_iOS
//
//  Created by Савелий Коцур on 12.07.2025.
//

import Foundation

@Observable
final class OperationViewModel {
    var selectedCategoryId: Int? = nil
    var amountString: String = ""
    var date: Date = Date()
    var comment: String = ""
    var accountId: Int?
    
    var showAlert: Bool = false
    var alertMessage: String = ""
    
    let mode: OperationMode
    let direction: Direction
    
    private var transactionId: Int? = nil
    
    var categories: [Category] = []
    
    init(mode: OperationMode = .create, transaction: Transaction? = nil, direction: Direction) {
        self.mode = mode
        self.direction = direction
        
        if let transaction = transaction {
            self.transactionId = transaction.id
            self.selectedCategoryId = transaction.categoryId
            self.amountString = "\(transaction.amount)"
            self.date = transaction.transactionDate
            self.comment = transaction.comment ?? ""
        }
        
        Task {
            await loadCategories()
            accountId = try await BankAccountsService.shared.fetchAccount(id: 1).id
        }
    }
    
    func loadCategories() async {
        do {
            let cats = try await CategoriesService.shared.categories(direction: direction)
            categories = cats
        } catch {
            print("Error: \(error)")
        }
    }
    
    func validate() -> Bool {
        guard selectedCategoryId != nil else { return false }
        guard !amountString.isEmpty else { return false }
        let normalized = amountString.replacingOccurrences(of: ",", with: ".")
        guard let amount = Decimal(string: normalized), amount > 0 else { return false }
        return true
    }
    
    func validationMessage() -> String {
        if selectedCategoryId == nil {
            return "Пожалуйста, выберите статью"
        }
        if amountString.isEmpty {
            return "Пожалуйста, введите сумму"
        }
        let normalized = amountString.replacingOccurrences(of: ",", with: ".")
        if Decimal(string: normalized) == nil || Decimal(string: normalized)! <= 0 {
            return "Сумма введена неверно"
        }
        return ""
    }
    
    func save() async {
        guard validate() else {
            alertMessage = validationMessage()
            showAlert = true
            return
        }
        showAlert = false
        
        let normalized = amountString.replacingOccurrences(of: ",", with: ".")
        let amount = Decimal(string: normalized) ?? 0
        let transaction = Transaction(
            id: transactionId ?? 0, // 0 для создания новой транзакции
            accountId: accountId ?? 1,
            categoryId: selectedCategoryId!,
            amount: amount,
            transactionDate: date,
            comment: comment.isEmpty ? nil : comment,
            createdAt: Date(timeIntervalSince1970: 0), // нулевая дата для создания
            updatedAt: Date(timeIntervalSince1970: 0)  // нулевая дата для создания
        )
        
        do {
            if mode == .create {
                try await TransactionsService.shared.addTransaction(transaction)
            } else {
                try await TransactionsService.shared.updateTransaction(transaction)
            }
        } catch {
            alertMessage = "Ошибка при сохранении: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    func delete() async {
        guard let id = transactionId else { return }
        do {
            try await TransactionsService.shared.deleteTransaction(id: id)
        } catch {
            alertMessage = "Ошибка при удалении: \(error.localizedDescription)"
            showAlert = true
        }
    }
}

enum OperationMode {
    case create
    case edit
}
