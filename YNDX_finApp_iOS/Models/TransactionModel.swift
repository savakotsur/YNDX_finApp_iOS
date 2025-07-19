//
//  TransactionModel.swift
//  YNDX_finApp_iOS
//
//  Created by Савелий Коцур on 13.06.2025.
//

import Foundation

struct Transaction: Codable {
    let id: Int
    let accountId: Int
    let categoryId: Int
    let amount: Decimal
    let transactionDate: Date
    let comment: String?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, account, category, amount, transactionDate, comment, createdAt, updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        
        // Обработка amount как строки
        if let amountString = try? container.decode(String.self, forKey: .amount) {
            amount = Decimal(string: amountString) ?? 0
        } else {
            amount = try container.decode(Decimal.self, forKey: .amount)
        }
        
        // Обработка дат как строк
        if let transactionDateString = try? container.decode(String.self, forKey: .transactionDate) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            transactionDate = formatter.date(from: transactionDateString) ?? Date()
        } else {
            transactionDate = try container.decode(Date.self, forKey: .transactionDate)
        }
        
        comment = try container.decodeIfPresent(String.self, forKey: .comment)
        
        if let createdAtString = try? container.decode(String.self, forKey: .createdAt) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            createdAt = formatter.date(from: createdAtString) ?? Date()
        } else {
            createdAt = try container.decode(Date.self, forKey: .createdAt)
        }
        
        if let updatedAtString = try? container.decode(String.self, forKey: .updatedAt) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            updatedAt = formatter.date(from: updatedAtString) ?? Date()
        } else {
            updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        }
        
        // Извлекаем accountId из вложенного объекта account
        let accountContainer = try container.nestedContainer(keyedBy: AccountCodingKeys.self, forKey: .account)
        accountId = try accountContainer.decode(Int.self, forKey: .id)
        
        // Извлекаем categoryId из вложенного объекта category
        let categoryContainer = try container.nestedContainer(keyedBy: CategoryCodingKeys.self, forKey: .category)
        categoryId = try categoryContainer.decode(Int.self, forKey: .id)
    }
    
    private enum AccountCodingKeys: String, CodingKey {
        case id
    }
    
    private enum CategoryCodingKeys: String, CodingKey {
        case id
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(amount, forKey: .amount)
        try container.encode(transactionDate, forKey: .transactionDate)
        try container.encodeIfPresent(comment, forKey: .comment)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        
        // Кодируем accountId как вложенный объект account
        var accountContainer = container.nestedContainer(keyedBy: AccountCodingKeys.self, forKey: .account)
        try accountContainer.encode(accountId, forKey: .id)
        
        // Кодируем categoryId как вложенный объект category
        var categoryContainer = container.nestedContainer(keyedBy: CategoryCodingKeys.self, forKey: .category)
        try categoryContainer.encode(categoryId, forKey: .id)
    }
    
    init(id: Int, accountId: Int, categoryId: Int, amount: Decimal, transactionDate: Date, comment: String?, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.accountId = accountId
        self.categoryId = categoryId
        self.amount = amount
        self.transactionDate = transactionDate
        self.comment = comment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension Transaction {
    static func parse(jsonObject: Any) -> Transaction? {
        guard let dict = jsonObject as? [String: Any] else { return nil }
        let isoFormatter = ISO8601DateFormatter()
        guard
            let id = dict["id"] as? Int,
            let accountId = dict["accountId"] as? Int,
            let categoryId = dict["categoryId"] as? Int,
            let amountString = dict["amount"] as? String,
            let amount = Decimal(string: amountString),
            let transactionDateString = dict["transactionDate"] as? String,
            let createdAtString = dict["createdAt"] as? String,
            let updatedAtString = dict["updatedAt"] as? String,
            let transactionDate = isoFormatter.date(from: transactionDateString),
            let createdAt = isoFormatter.date(from: createdAtString),
            let updatedAt = isoFormatter.date(from: updatedAtString)
        else {
            return nil
        }
        
        let comment = dict["comment"] as? String
        
        return Transaction(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    var jsonObject: Any {
        let isoFormatter = ISO8601DateFormatter()
        var dict: [String: Any] = [
            "id": id,
            "accountId": accountId,
            "categoryId": categoryId,
            "amount": "\(amount)",
            "transactionDate": isoFormatter.string(from: transactionDate),
            "createdAt": isoFormatter.string(from: createdAt),
            "updatedAt": isoFormatter.string(from: updatedAt)
        ]
        
        if let comment = comment {
            dict["comment"] = comment
        }
        
        return dict
    }
}

extension Transaction {
    var csvString: String {
        let isoFormatter = ISO8601DateFormatter()
        return [
            "\(id)",
            "\(accountId)",
            "\(categoryId)",
            "\(amount)",
            isoFormatter.string(from: transactionDate),
            comment != nil ? "\"\(comment!)\"" : "",
            isoFormatter.string(from: createdAt),
            isoFormatter.string(from: updatedAt)
        ].joined(separator: ",")
    }
    
    static func fromCSV(_ line: String) -> Transaction? {
        let isoFormatter = ISO8601DateFormatter()
        let components = line.split(separator: ",", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "\"", with: "") }
        
        guard components.count >= 8,
              let id = Int(components[0]),
              let accountId = Int(components[1]),
              let categoryId = Int(components[2]),
              let amount = Decimal(string: components[3]),
              let transactionDate = isoFormatter.date(from: components[4]),
              let createdAt = isoFormatter.date(from: components[6]),
              let updatedAt = isoFormatter.date(from: components[7])
        else {
            return nil
        }
        
        let comment = components[5].isEmpty ? nil : components[5]
        
        return Transaction(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension Transaction: Identifiable {}

extension Transaction: Equatable {}

// Модель для создания транзакции
struct CreateTransactionRequest: Codable {
    let accountId: Int
    let categoryId: Int
    let amount: String
    let transactionDate: Date
    let comment: String?
}
