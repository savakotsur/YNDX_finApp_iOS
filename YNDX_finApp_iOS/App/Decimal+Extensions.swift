//
//  Decimal+Extensions.swift
//  YNDX_finApp_iOS
//
//  Created by Савелий Коцур on 19.06.2025.
//

import Foundation

extension Decimal {
    var groupedString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale.current
        return formatter.string(from: self as NSDecimalNumber) ?? ""
    }
}
