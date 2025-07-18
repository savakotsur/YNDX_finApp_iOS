//
//  BankAccountModel.swift
//  YNDX_finApp_iOS
//
//  Created by Савелий Коцур on 13.06.2025.
//

import Foundation

struct BankAccount: Codable {
    let id: Int
    let userId: Int
    let name: String
    let balance: Decimal
    let currency: String
    let createdAt: Date
    let updatedAt: Date
}
