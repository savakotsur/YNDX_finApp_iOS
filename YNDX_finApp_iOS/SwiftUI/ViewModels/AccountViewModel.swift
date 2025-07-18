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
    
    var currencies: [Currency] { Currency.allCases }
    
    func selectCurrency(_ newCurrency: Currency) {
        guard newCurrency != currency else { return }
        currency = newCurrency
    }
    
    func save() {
        if let value = Int(balanceInput) {
            balance = Decimal(value)
        }
        isEditing = false
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
        let filtered = text.filter { "0123456789.,".contains($0) }
        balanceInput = filtered.replacingOccurrences(of: ",", with: ".")
    }
    
    func updateBalanceInput(_ text: String) {
        let filtered = text.filter { "0123456789.,".contains($0) }
        balanceInput = filtered.replacingOccurrences(of: ",", with: ".")
    }
    
    func refresh() {
        Task {
            await loadAccount()
        }
    }
    
    func loadAccount(id: Int? = nil) async {
        let idToLoad = id ?? accountId
        do {
            let account = try await BankAccountsService.shared.fetchAccount(id: idToLoad)
            self.balance = account.balance
            self.currency = Currency.from(code: account.currency)
            self.accountId = account.id
        } catch {
            print("Ошибка загрузки аккаунта: \(error)")
        }
    }
}
