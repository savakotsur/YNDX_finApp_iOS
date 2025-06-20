//
//  TransactionModel.swift
//  YNDX_finApp_iOS
//
//  Created by Савелий Коцур on 13.06.2025.
//

import Foundation

struct Transaction {
    let id: Int
    let accountId: Int
    let categoryId: Int
    let amount: Decimal
    let transactionDate: Date
    let comment: String?
    let createdAt: Date
    let updatedAt: Date
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
