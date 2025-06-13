//
//  TransactionsFileCache.swift
//  YNDX_finApp_iOS
//
//  Created by Савелий Коцур on 14.06.2025.
//

import Foundation

final class TransactionsFileCache {
    public private(set) var transactions: [Transaction] = []
    
    public func add(_ transaction: Transaction) {
        guard !transactions.contains(where: { $0.id == transaction.id }) else { return }
        transactions.append(transaction)
    }
    
    public func remove(byId id: Int) {
        transactions.removeAll { $0.id == id }
    }
    
    public func save(to fileURL: URL) throws {
        let objects = transactions.map { $0.jsonObject }
        let data = try JSONSerialization.data(withJSONObject: objects)
        try data.write(to: fileURL, options: .atomic)
    }
    
    public func load(from fileURL: URL) throws {
        let data = try Data(contentsOf: fileURL)
        let rawArray = try JSONSerialization.jsonObject(with: data) as? [Any] ?? []
        
        for obj in rawArray {
            if let transaction = Transaction.parse(jsonObject: obj) {
                add(transaction)
            }
        }
    }
}
