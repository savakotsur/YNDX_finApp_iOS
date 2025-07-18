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
        case id, name, icon, direction
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        let iconString = try container.decode(String.self, forKey: .icon)
        guard let firstChar = iconString.first else {
            throw DecodingError.dataCorruptedError(forKey: .icon, in: container, debugDescription: "Icon string is empty")
        }
        icon = firstChar
        direction = try container.decode(Direction.self, forKey: .direction)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(String(icon), forKey: .icon)
        try container.encode(direction, forKey: .direction)
    }
}
