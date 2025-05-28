import SwiftUI

struct SwipeBackEnabled: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(SwipeBackHelper())
    }
}

extension View {
    func enableSwipeBack() -> some View {
        self.modifier(SwipeBackEnabled())
    }
}

struct SwipeBackHelper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        DispatchQueue.main.async {
            guard let nav = uiViewController.navigationController else { return }
            guard let gesture = nav.interactivePopGestureRecognizer else { return }
            context.coordinator.set(gesture: gesture, navigationController: nav)
        }
    }

    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        private var swipeDelegate: SwipeBackDelegate?

        func set(gesture: UIGestureRecognizer, navigationController: UINavigationController) {
            let newDelegate = SwipeBackDelegate(navigationController: navigationController)
            self.swipeDelegate = newDelegate
            gesture.delegate = newDelegate
            gesture.isEnabled = true
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
}

class SwipeBackDelegate: NSObject, UIGestureRecognizerDelegate {
    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let nav = navigationController else { return true }
        let stackSize = nav.viewControllers.count
        let isEnabled = stackSize > 1
        return isEnabled
    }
}
