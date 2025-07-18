//
//  CategoriesService.swift
//  YNDX_finApp_iOS
//
//  Created by Савелий Коцур on 14.06.2025.
//

import Foundation

final class CategoriesService {
    static let shared = CategoriesService()
    private let networkClient = NetworkClient.shared
    
    func categories() async throws -> [Category] {
        let endpoint = "categories"
        return try await networkClient.request(endpoint: endpoint, method: "GET", requestBody: Optional<EmptyRequest>.none) as [Category]
    }
    
    func categories(direction: Direction) async throws -> [Category] {
        let all = try await categories()
        return all.filter { $0.direction == direction }
    }
}

private struct EmptyRequest: Encodable {}
