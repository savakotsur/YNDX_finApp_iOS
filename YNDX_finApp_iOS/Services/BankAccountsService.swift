//
//  BankAccountsService.swift
//  YNDX_finApp_iOS
//
//  Created by Савелий Коцур on 14.06.2025.
//

import Foundation

final class BankAccountsService {
    static var shared = BankAccountsService()
    
    private var account: BankAccount = BankAccount(
        id: 1,
        userId: 42,
        name: "Основной счёт",
        balance: Decimal(string: "10000.00")!,
        currency: "RUB",
        createdAt: ISO8601DateFormatter().date(from: "2025-01-01T00:00:00Z")!,
        updatedAt: ISO8601DateFormatter().date(from: "2025-01-01T00:00:00Z")!
    )
    
    func fetchAccount() async throws -> BankAccount {
        account
    }
    
    func updateAccount(_ updated: BankAccount) async throws {
        account = updated
    }
}
