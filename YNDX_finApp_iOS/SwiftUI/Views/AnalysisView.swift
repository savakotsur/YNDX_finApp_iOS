//
//  AnalysisView.swift
//  YNDX_finApp_iOS
//
//  Created by Савелий Коцур on 11.07.2025.
//

import Foundation
import SwiftUI

struct AnalysisView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    let direction: Direction

    func makeUIViewController(context: Context) -> UINavigationController {
        let vc = AnalysisViewController(direction: direction)
        vc.onBack = {
            dismiss()
        }
        return UINavigationController(rootViewController: vc)
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}
