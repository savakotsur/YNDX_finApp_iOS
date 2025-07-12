//
//  AnalysisView.swift
//  YNDX_finApp_iOS
//
//  Created by Савелий Коцур on 11.07.2025.
//

import Foundation
import SwiftUI

struct AnalysisView: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    @Environment(\.dismiss) var dismiss
    let direction: Direction

    func makeUIViewController(context: Context) -> UINavigationController {
        let vc = AnalysisViewController(direction: direction)
        let nav = UINavigationController(rootViewController: vc)

        vc.onBack = {
            dismiss()
        }
        vc.onSelectTransaction = { transaction in
            let operationVC = UIHostingController(
                rootView: OperationView(
                    direction: direction,
                    transaction: transaction,
                    onDismiss: {
                        vc.loadData()
                    }
                )
            )
            operationVC.modalPresentationStyle = .fullScreen
            nav.present(operationVC, animated: true)
        }

        return nav
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}

    class Coordinator: NSObject, UIAdaptivePresentationControllerDelegate {
        var onDismiss: (() -> Void)?

        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            onDismiss?()
        }
    }
}
