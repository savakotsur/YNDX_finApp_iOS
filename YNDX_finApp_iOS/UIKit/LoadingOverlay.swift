//
//  LoadinOverlay.swift
//  YNDX_finApp_iOS
//
//  Created by Савелий Коцур on 24.07.2025.
//

import UIKit

final class LoadingOverlay {
    static let shared = LoadingOverlay()

    private var overlayView = UIView()
    private var activityIndicator = UIActivityIndicatorView(style: .medium)

    private init() {
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        overlayView.alpha = 0
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(activityIndicator)
    }

    func show() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }

        guard overlayView.superview == nil else { return }

        overlayView.frame = window.bounds
        window.addSubview(overlayView)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor)
        ])

        activityIndicator.startAnimating()

        UIView.animate(withDuration: 0.25) {
            self.overlayView.alpha = 1
        }
    }

    func hide() {
        UIView.animate(withDuration: 0.25, animations: {
            self.overlayView.alpha = 0
        }) { _ in
            self.activityIndicator.stopAnimating()
            self.overlayView.removeFromSuperview()
        }
    }
}
