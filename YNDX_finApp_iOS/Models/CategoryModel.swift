//
//  CategoryModel.swift
//  YNDX_finApp_iOS
//
//  Created by Савелий Коцур on 13.06.2025.
//

import Foundation

enum Direction: String {
    case income
    case outcome
}

struct Category {
    let id: Int
    let name: String
    let icon: Character
    let direction: Direction
}
