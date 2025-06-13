//
//  TransactionTests.swift
//  YNDX_finApp_iOSTests
//
//  Created by Савелий Коцур on 14.06.2025.
//

import XCTest
@testable import YNDX_finApp_iOS

final class TransactionTests: XCTestCase {
    var date: Date!

    override func setUpWithError() throws {
        date = ISO8601DateFormatter().date(from: "2025-06-14T10:00:00Z")
    }

    // MARK: - Корректные случаи

    func testJsonObject_and_Parse_areSymmetric() {
        let original = Transaction(
            id: 123,
            accountId: 10,
            categoryId: 20,
            amount: Decimal(string: "999.99")!,
            transactionDate: date,
            comment: "Unit test transaction",
            createdAt: date,
            updatedAt: date
        )

        let json = original.jsonObject
        let parsed = Transaction.parse(jsonObject: json)

        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.id, original.id)
        XCTAssertEqual(parsed?.accountId, original.accountId)
        XCTAssertEqual(parsed?.categoryId, original.categoryId)
        XCTAssertEqual(parsed?.amount, original.amount)
        XCTAssertEqual(parsed?.transactionDate, original.transactionDate)
        XCTAssertEqual(parsed?.createdAt, original.createdAt)
        XCTAssertEqual(parsed?.updatedAt, original.updatedAt)
        XCTAssertEqual(parsed?.comment, original.comment)
    }

    func testJsonObject_and_Parse_withNilComment() {
        let original = Transaction(
            id: 456,
            accountId: 2,
            categoryId: 3,
            amount: Decimal(string: "0.01")!,
            transactionDate: date,
            comment: nil,
            createdAt: date,
            updatedAt: date
        )

        let json = original.jsonObject
        let parsed = Transaction.parse(jsonObject: json)

        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.comment, nil)
    }

    // MARK: - Ошибки: отсутствует одно из обязательных полей

    func testParse_missingId_returnsNil() {
        let json: [String: Any] = [
            "accountId": 1, "categoryId": 1, "amount": "1.0",
            "transactionDate": ISO8601DateFormatter().string(from: date),
            "createdAt": ISO8601DateFormatter().string(from: date),
            "updatedAt": ISO8601DateFormatter().string(from: date)
        ]
        XCTAssertNil(Transaction.parse(jsonObject: json))
    }

    func testParse_missingAmount_returnsNil() {
        let json: [String: Any] = [
            "id": 1, "accountId": 1, "categoryId": 1,
            "transactionDate": ISO8601DateFormatter().string(from: date),
            "createdAt": ISO8601DateFormatter().string(from: date),
            "updatedAt": ISO8601DateFormatter().string(from: date)
        ]
        XCTAssertNil(Transaction.parse(jsonObject: json))
    }

    func testParse_invalidAmountFormat_returnsNil() {
        let json: [String: Any] = [
            "id": 1, "accountId": 1, "categoryId": 1,
            "amount": "NOT_A_NUMBER",
            "transactionDate": ISO8601DateFormatter().string(from: date),
            "createdAt": ISO8601DateFormatter().string(from: date),
            "updatedAt": ISO8601DateFormatter().string(from: date)
        ]
        XCTAssertNil(Transaction.parse(jsonObject: json))
    }

    func testParse_invalidDateFormat_returnsNil() {
        let json: [String: Any] = [
            "id": 1, "accountId": 1, "categoryId": 1,
            "amount": "10.00",
            "transactionDate": "invalid-date",
            "createdAt": ISO8601DateFormatter().string(from: date),
            "updatedAt": ISO8601DateFormatter().string(from: date)
        ]
        XCTAssertNil(Transaction.parse(jsonObject: json))
    }
    
    func testJsonObject_isValidForJSONSerialization() {
        let transaction = Transaction(
            id: 999,
            accountId: 42,
            categoryId: 3,
            amount: Decimal(string: "321.00")!,
            transactionDate: date,
            comment: "Check serializability",
            createdAt: date,
            updatedAt: date
        )

        let json = transaction.jsonObject

        XCTAssertTrue(JSONSerialization.isValidJSONObject(json), "jsonObject must be valid for JSONSerialization")
    }
}
