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
    func transactions(from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        struct Query: Encodable {
            let from: String
            let to: String
        }
        let dateFormatter = ISO8601DateFormatter()
        let query = Query(from: dateFormatter.string(from: startDate), to: dateFormatter.string(from: endDate))
        let endpoint = "transactions?from=\(query.from)&to=\(query.to)"
        return try await networkClient.request(endpoint: endpoint, method: "GET", requestBody: Optional<Query>.none) as [Transaction]
    }

    // MARK: - Добавление транзакции
    func addTransaction(_ transaction: Transaction) async throws {
        let endpoint = "transactions"
        let _: Transaction = try await networkClient.request(endpoint: endpoint, method: "POST", requestBody: transaction)
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
