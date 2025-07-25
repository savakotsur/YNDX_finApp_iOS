//
//  AccountViewModel.swift
//  YNDX_finApp_iOS
//
//  Created by Савелий Коцур on 27.06.2025.
//

import Foundation
import SwiftUI

enum Currency: String, CaseIterable, Identifiable {
    case rub = "₽"
    case usd = "$"
    case eur = "€"
    
    var id: String { self.rawValue }
    var title: String {
        switch self {
        case .rub: return "Российский рубль ₽"
        case .usd: return "Американский доллар $"
        case .eur: return "Евро €"
        }
    }
    
    static func from(code: String) -> Currency {
        switch code.uppercased() {
        case "RUB": return .rub
        case "USD": return .usd
        case "EUR": return .eur
        default: return .rub
        }
    }
}

@Observable
class AccountViewModel {
    var balance: Decimal = 670000
    var currency: Currency = .rub
    var isEditing: Bool = false
    var showCurrencyPicker: Bool = false
    var isBalanceHidden: Bool = false
    var balanceInput: String = ""
    var accountId: Int = 1
    var chartData: [ChartData] = []
    
    var currencies: [Currency] { Currency.allCases }
    
    func selectCurrency(_ newCurrency: Currency) {
        guard newCurrency != currency else { return }
        currency = newCurrency
    }
    
    func stopEditing() {
        isEditing = false
    }
    
    func save() async {
        if let value = Int(balanceInput) {
            balance = Decimal(value)
        }
        
        // Отправляем обновление на сервер
        do {
            let updatedAccount = BankAccount(
                id: accountId,
                name: "Main Account",
                balance: balance,
                currency: currency.rawValue,
                createdAt: Date(),
                updatedAt: Date()
            )
            try await BankAccountsService.shared.updateAccount(updatedAccount)
        } catch {
            print("Ошибка обновления аккаунта: \(error)")
        }
    }
    
    func startEditing() {
        balanceInput = balance.groupedString
        isEditing = true
    }
    
    func showBalance() {
        withAnimation {
            isBalanceHidden = false
        }
    }
    
    func toggleBalanceHidden() {
        withAnimation {
            isBalanceHidden.toggle()
        }
    }
    
    func pasteBalance(_ text: String) {
        let filtered = text.filter { "0123456789.,-".contains($0) }
        balanceInput = filtered.replacingOccurrences(of: ",", with: ".")
    }
    
    func updateBalanceInput(_ text: String) {
        let filtered = text.filter { "0123456789.,-".contains($0) }
        balanceInput = filtered.replacingOccurrences(of: ",", with: ".")
    }
    
    func refresh() {
        Task {
            await loadAccount()
            await loadChartData()
        }
    }
    
    func loadAccount(id: Int? = nil) async {
        await MainActor.run {
                LoadingOverlay.shared.show()
        }

        defer {
            Task { @MainActor in
                LoadingOverlay.shared.hide()
            }
        }

        do {
            guard let account = try await BankAccountsService.shared.fetchAccount().first else {
                print("Аккаунт не найден")
                return
            }
            self.balance = account.balance
            self.currency = Currency.from(code: account.currency)
            self.accountId = account.id
        } catch {
            print("Ошибка загрузки аккаунта: \(error)")
        }
    }
    
    func loadChartData() async {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -29, to: today) else { return }

        do {
            let categories = try await CategoriesService.shared.categories()
            let transactions = try await TransactionsService.shared.transactions(from: startDate, to: today, accountId: accountId)

            var grouped: [Date: Decimal] = [:]

            for transaction in transactions {
                guard let category = categories.first(where: { $0.id == transaction.categoryId }) else { continue }
                let date = calendar.startOfDay(for: transaction.createdAt)
                let signedAmount = category.direction == .income ? -transaction.amount : transaction.amount
                grouped[date, default: 0] += signedAmount
            }

            var result: [ChartData] = []
            var runningBalance = balance

            for offset in (0..<30).reversed() {
                guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
                result.append(ChartData(date: date, balance: runningBalance))
                runningBalance -= grouped[date, default: 0]
            }

            let safeResult = result
            await MainActor.run {
                self.chartData = safeResult
            }
        } catch {
            print("Ошибка загрузки данных графика: \(error)")
        }
    }
}

struct ChartData: Identifiable {
    let id = UUID()
    let date: Date
    let balance: Decimal
}
