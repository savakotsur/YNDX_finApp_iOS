//
//  TransactionsListViewModel.swift
//  YNDX_finApp_iOS
//
//  Created by Савелий Коцур on 18.06.2025.
//

import Foundation

@Observable
final class TransactionsViewModel {
    var transactions: [Transaction] = []
    var totalAmount: Decimal = 0.00
    
    var startDate: Date {
        didSet {
            if startDate > endDate {
                endDate = startDate
                return
            }
            Task {
                await loadTransactions()
                calculateTotal()
            }
        }
    }
    var endDate: Date {
        didSet {
            if endDate < startDate {
                startDate = endDate
                return
            }
            Task {
                await loadTransactions()
                calculateTotal()
            }
        }
    }
    
    private var matchingCategories: [Category] = []
    private let direction: Direction
    
    init(direction: Direction, startDate: Date, endDate: Date) {
        self.direction = direction
        self.startDate = startDate
        self.endDate = endDate
        Task {
            await loadTransactions()
            calculateTotal()
        }
    }
    
    private func loadTransactions() async {
        let calendar = Calendar.current
        
        let startOfDay = calendar.startOfDay(for: startDate)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: calendar.startOfDay(for: endDate)) ?? endDate
        
        do {
            let allTransactions = try await TransactionsService.shared.transactions(from: startOfDay, to: endOfDay)
            matchingCategories = try await CategoriesService.shared.categories(direction: direction)
            let matchingCategoryIds = Set(matchingCategories.map { $0.id })
            transactions = allTransactions.filter { matchingCategoryIds.contains($0.categoryId) }
        } catch {
            print("Failed to load transactions: \(error)")
        }
    }
    
    private func calculateTotal() {
        totalAmount = transactions.reduce(Decimal(0)) { $0 + $1.amount }
    }
    
    func getCategoryName(for categoryId: Int) -> String {
        let name = matchingCategories.first(where: { $0.id == categoryId })?.name ?? " "
        return name
    }
    
    func getEmoji(for categoryId: Int) -> String {
        let emoji = matchingCategories.first(where: { $0.id == categoryId })?.icon ?? " "
        return String(emoji)
    }
    
    func sortByDate(descending: Bool = true) {
        transactions.sort { (first: Transaction, second: Transaction) in
            if first.updatedAt == second.updatedAt {
                return first.id < second.id
            }
            return descending ? first.updatedAt > second.updatedAt : first.updatedAt < second.updatedAt
        }
    }

    func sortByAmount(descending: Bool = true) {
        transactions.sort { (first: Transaction, second: Transaction) in
            if first.amount == second.amount {
                return first.updatedAt > second.updatedAt
            }
            return descending ? first.amount > second.amount : first.amount < second.amount
        }
    }
}
