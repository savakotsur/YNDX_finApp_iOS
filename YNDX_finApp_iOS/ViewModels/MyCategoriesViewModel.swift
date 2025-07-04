//
//  MyCategoriesViewModel.swift
//  YNDX_finApp_iOS
//
//  Created by Савелий Коцур on 04.07.2025.
//

import Foundation

@Observable
class MyCategoriesViewModel {
    var categories: [Category] = []
    var searchText: String = ""

    init() {
        Task {
            do {
                self.categories = try await CategoriesService.shared.categories()
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    private func levenshtein(_ lhs: String, _ rhs: String) -> Int {
        let lhs = Array(lhs)
        let rhs = Array(rhs)
        let empty = [Int](repeating:0, count: rhs.count + 1)
        var last = [Int](0...rhs.count)
        for (i, l) in lhs.enumerated() {
            var cur = [i + 1] + empty
            for (j, r) in rhs.enumerated() {
                cur[j + 1] = l == r ? last[j] : min(last[j], last[j + 1], cur[j]) + 1
            }
            last = cur
        }
        return last.last!
    }
    
    var filteredCategories: [Category] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return categories
        }
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let threshold = 1
        let filteredWithMeta: [(Category, Int, Int)] = categories.compactMap { category in
            let name = category.name.lowercased()
            if query.count <= 2 {
                if name.hasPrefix(query) {
                    return (category, 0, 0) 
                } else {
                    return nil
                }
            }
            if name.count >= query.count {
                let prefix = String(name.prefix(query.count))
                let distance = levenshtein(prefix, query)
                let matches = zip(prefix, query).filter { $0 == $1 }.count
                if name.hasPrefix(query) {
                    return (category, 0, 0) 
                }
                if distance <= threshold && matches >= query.count / 2 {
                    return (category, 1, distance) 
                }
            }
            return nil
        }
        return filteredWithMeta
            .sorted { lhs, rhs in
                if lhs.1 != rhs.1 { return lhs.1 < rhs.1 }
                if lhs.2 != rhs.2 { return lhs.2 < rhs.2 }
                return lhs.0.name < rhs.0.name
            }
            .map { $0.0 }
    }
}
