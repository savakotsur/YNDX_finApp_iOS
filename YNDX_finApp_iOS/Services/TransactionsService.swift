//
//  TransactionsService.swift
//  YNDX_finApp_iOS
//
//  Created by Савелий Коцур on 14.06.2025.
//

import Foundation

final class TransactionsService {
    static let shared = TransactionsService()
    private let networkClient = NetworkClient.shared
    
    // MARK: - Получение транзакций за период
    func transactions(from startDate: Date, to endDate: Date, accountId: Int = 1) async throws -> [Transaction] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDateString = dateFormatter.string(from: startDate)
        let endDateString = dateFormatter.string(from: endDate)
        let path = "transactions/account/\(accountId)/period"
        let query = "startDate=\(startDateString)&endDate=\(endDateString)"
        let endpoint = "\(path)?\(query)"
        return try await networkClient.request(endpoint: endpoint, method: "GET", requestBody: Optional<EmptyRequest>.none) as [Transaction]
    }

    // MARK: - Добавление транзакции
    func addTransaction(_ transaction: Transaction) async throws {
        let endpoint = "transactions"
        
        // Создаем запрос в правильном формате для API
        let createRequest = CreateTransactionRequest(
            accountId: transaction.accountId,
            categoryId: transaction.categoryId,
            amount: String(format: "%.2f", NSDecimalNumber(decimal: transaction.amount).doubleValue),
            transactionDate: transaction.transactionDate,
            comment: transaction.comment
        )
        
        let _: Transaction = try await networkClient.request(endpoint: endpoint, method: "POST", requestBody: createRequest)
    }

    // MARK: - Обновление транзакции
    func updateTransaction(_ transaction: Transaction) async throws {
        let endpoint = "transactions/\(transaction.id)"
        let _: Transaction = try await networkClient.request(endpoint: endpoint, method: "PUT", requestBody: transaction)
    }

    // MARK: - Удаление транзакции
    func deleteTransaction(id: Int) async throws {
        let endpoint = "transactions/\(id)"
        let _: EmptyResponse = try await networkClient.request(endpoint: endpoint, method: "DELETE", requestBody: Optional<EmptyRequest>.none)
    }
}

// MARK: - Вспомогательные типы для пустых запросов/ответов
private struct EmptyRequest: Encodable {}
private struct EmptyResponse: Decodable {}
