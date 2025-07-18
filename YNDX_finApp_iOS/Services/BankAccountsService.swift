//
//  BankAccountsService.swift
//  YNDX_finApp_iOS
//
//  Created by Савелий Коцур on 14.06.2025.
//

import Foundation

final class BankAccountsService {
    static let shared = BankAccountsService()
    private let networkClient = NetworkClient.shared
    
    func fetchAccount(id: Int) async throws -> BankAccount {
        let endpoint = "accounts/\(id)"
        return try await networkClient.request(endpoint: endpoint, method: "GET", requestBody: Optional<EmptyRequest>.none) as BankAccount
    }
    
    func updateAccount(_ updated: BankAccount) async throws {
        let endpoint = "accounts/\(updated.id)"
        let _: BankAccount = try await networkClient.request(endpoint: endpoint, method: "PUT", requestBody: updated)
    }
}

private struct EmptyRequest: Encodable {}
