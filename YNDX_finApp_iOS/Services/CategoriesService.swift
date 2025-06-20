//
//  CategoriesService.swift
//  YNDX_finApp_iOS
//
//  Created by Савелий Коцур on 14.06.2025.
//

import Foundation

final class CategoriesService {
    static var shared = CategoriesService()
    
    private let mockCategories: [Category] = [
        Category(id: 1, name: "Продукты", icon: "🛒", direction: .outcome),
        Category(id: 2, name: "Транспорт", icon: "🚗", direction: .outcome),
        Category(id: 3, name: "Развлечения", icon: "🎮", direction: .outcome),
        Category(id: 4, name: "Кафе", icon: "☕️", direction: .outcome),
        Category(id: 5, name: "Зарплата", icon: "💰", direction: .income),
        Category(id: 6, name: "Подарки", icon: "🎁", direction: .income)
    ]
    
    func categories() async throws -> [Category] {
        mockCategories
    }
    
    func categories(direction: Direction) async throws -> [Category] {
        mockCategories.filter { $0.direction == direction }
    }
}
