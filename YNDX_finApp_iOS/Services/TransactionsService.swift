//
//  TransactionsService.swift
//  YNDX_finApp_iOS
//
//  Created by Савелий Коцур on 14.06.2025.
//

import Foundation

final class TransactionsService {
    static var shared = TransactionsService()
    
    private var transactions: [Transaction] = {
        var result: [Transaction] = []
        let now = Date()
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!

        let outcomeComments: [Int: [String]] = [
            1: ["Купил продукты в магазине", "Потратил на овощи и фрукты", "Закупка на неделю", "Купил мясо и молоко", "Сходил в супермаркет"],
            2: ["Заправил машину", "Купил билет на автобус", "Такси до дома", "Транспортная карта", "Поездка на метро"],
            3: ["Кино с друзьями", "Покупка новой игры", "Подписка на стриминг", "Посещение квеста", "Боулинг вечером"],
            4: ["Кофе с коллегами", "Завтрак в кафе", "Ужин с семьей", "Кофейня у дома", "Обед в ресторане"]
        ]

        var idCounter = 1
        for i in 0..<100 {
            let categoryId = (i % 4) + 1
            let baseDate = i < 50 ? yesterday : now
            let timeOffset = TimeInterval((i % 30) * 120)
            let date = baseDate.addingTimeInterval(-timeOffset)
            let comments = outcomeComments[categoryId]!
            let comment = comments[i % comments.count]
            let amount = Decimal(Double.random(in: 100...2000).rounded())

            result.append(Transaction(
                id: idCounter,
                accountId: (i % 3) + 1,
                categoryId: categoryId,
                amount: amount,
                transactionDate: date,
                comment: comment,
                createdAt: date,
                updatedAt: date
            ))
            idCounter += 1
        }

        let incomeComments = [
            5: ["Зарплата за месяц", "Премия на работе", "Аванс", "Доплата за переработки"],
            6: ["Подарок на день рождения", "Перевод от друга", "Подарок от родителей", "Праздничный бонус"]
        ]

        for i in 0..<20 {
            let categoryId = i < 10 ? 5 : 6
            let baseDate = i < 10 ? yesterday : now
            let timeOffset = TimeInterval((i % 10) * 120)
            let date = baseDate.addingTimeInterval(-timeOffset)
            let comments = incomeComments[categoryId]!
            let comment = comments[i % comments.count]
            let amount = Decimal(Double.random(in: 3000...10000).rounded())

            result.append(Transaction(
                id: idCounter,
                accountId: (i % 3) + 1,
                categoryId: categoryId,
                amount: amount,
                transactionDate: date,
                comment: comment,
                createdAt: date,
                updatedAt: date
            ))
            idCounter += 1
        }

        return result
    }()

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
