//
//  BackSwipeModifier.swift
//  GameSearch
//
//  Created by Ацамаз on 21.05.2025.
//

import SwiftUI

struct SwipeBackEnabled: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(SwipeBackHelper())
    }

    // Внутренний хелпер для доступа к UINavigationController
    struct SwipeBackHelper: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> UIViewController {
            let controller = UIViewController()
            DispatchQueue.main.async {
                if let nav = controller.navigationController {
                    nav.interactivePopGestureRecognizer?.delegate = nil
                    nav.interactivePopGestureRecognizer?.isEnabled = true
                }
            }
            return controller
        }

        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    }
}

extension View {
    func enableSwipeBack() -> some View {
        self.modifier(SwipeBackEnabled())
    }
}
