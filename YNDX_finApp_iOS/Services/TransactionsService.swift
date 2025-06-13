//
//  TransactionsService.swift
//  YNDX_finApp_iOS
//
//  Created by Савелий Коцур on 14.06.2025.
//

import Foundation

final class TransactionsService {
    private var transactions: [Transaction] = [
        Transaction(
            id: 1,
            accountId: 1,
            categoryId: 2,
            amount: Decimal(string: "500.00")!,
            transactionDate: ISO8601DateFormatter().date(from: "2025-06-10T12:00:00Z")!,
            comment: "Продукты",
            createdAt: ISO8601DateFormatter().date(from: "2025-06-10T12:00:00Z")!,
            updatedAt: ISO8601DateFormatter().date(from: "2025-06-10T12:00:00Z")!
        )
    ]

    func transactions(from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        transactions.filter { $0.transactionDate >= startDate && $0.transactionDate <= endDate }
    }

    func addTransaction(_ transaction: Transaction) async throws {
        guard !transactions.contains(where: { $0.id == transaction.id }) else { return }
        transactions.append(transaction)
    }

    func updateTransaction(_ transaction: Transaction) async throws {
        guard let index = transactions.firstIndex(where: { $0.id == transaction.id }) else { return }
        transactions[index] = transaction
    }

    func deleteTransaction(id: Int) async throws {
        transactions.removeAll { $0.id == id }
    }
}
