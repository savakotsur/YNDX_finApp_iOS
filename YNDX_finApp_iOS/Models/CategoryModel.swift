//
//  CategoryModel.swift
//  YNDX_finApp_iOS
//
//  Created by Савелий Коцур on 13.06.2025.
//

import Foundation

enum Direction: String, Codable {
    case income
    case outcome
}

struct Category: Codable {
    let id: Int
    let name: String
    let icon: Character
    let direction: Direction

    enum CodingKeys: String, CodingKey {
        case id, name, emoji, isIncome
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        let emojiString = try container.decode(String.self, forKey: .emoji)
        guard let firstChar = emojiString.first else {
            throw DecodingError.dataCorruptedError(forKey: .emoji, in: container, debugDescription: "Emoji string is empty")
        }
        icon = firstChar
        let isIncome = try container.decode(Bool.self, forKey: .isIncome)
        direction = isIncome ? .income : .outcome
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(String(icon), forKey: .emoji)
        try container.encode(direction == .income, forKey: .isIncome)
    }
}
