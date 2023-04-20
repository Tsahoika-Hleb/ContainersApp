import UIKit

protocol RouteHelperProtocol {
    var navController: UINavigationController? { get }

    init(window: UIWindow)
    func pushVC(_ viewController: UIViewController, animated: Bool)
    func popVC(animated: Bool)
    func popToVC(_ vc: UIViewController, animated: Bool)
    func presentVC(_ vc: UIViewController, animated: Bool, completion: (() -> Void)?)
    func popToRoot(animated: Bool)
    func setVC(_ viewController: UIViewController, animated: Bool)
    func dismissVC(animated: Bool, completion: (() -> Void)?)
    func popTo<T: UIViewController>(controllerType: T.Type, animated: Bool) -> Bool
}

/// Main app router for pushing, presenting, poping, dismissing
final class RouteHelper: RouteHelperProtocol {

    // MARK: - variables

    private(set) var navController: UINavigationController?

    // MARK: - initialization

    init(window: UIWindow) {
        UIApplication.shared.isIdleTimerDisabled = true
        let navigationController = UINavigationController()
        navigationController.navigationBar.isHidden = true
        navController = navigationController
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    // MARK: - Action methods (currently not used in app, but will be needed in case of navigation)

    func pushVC(_ viewController: UIViewController, animated: Bool = false) {
        if navController?.viewControllers.isEmpty == true {
            navController?.viewControllers = [viewController]
        } else {
            navController?.pushViewController(viewController, animated: animated)
        }
    }

    func popVC(animated: Bool) {
        navController?.popViewController(animated: animated)
    }

    @discardableResult
    func popTo<T: UIViewController>(controllerType: T.Type, animated: Bool) -> Bool {
        if let destinationVC = navController?.viewControllers.filter({ $0 is T }).first {
            popToVC(destinationVC, animated: animated)
            return true
        } else {
            return false
        }
    }

    func popToVC(_ vc: UIViewController, animated: Bool = true) {
        guard navController?.viewControllers.contains(vc) == true else {
            navController?.popToRootViewController(animated: animated)
            return
        }
        navController?.popToViewController(vc, animated: animated)
    }

    func presentVC(_ vc: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        navController?.present(vc, animated: animated, completion: completion)
    }

    func popToRoot(animated: Bool = true) {
        navController?.popToRootViewController(animated: animated)
    }

    func setVC(_ viewController: UIViewController, animated: Bool = false) {
        guard var currentViewControllers = navController?.viewControllers else { return }
        currentViewControllers.removeLast()
        currentViewControllers.append(viewController)
        navController?.setViewControllers(currentViewControllers, animated: animated)
    }

    func dismissVC(animated: Bool = false, completion: (() -> Void)? = nil) {
        navController?.dismiss(animated: animated, completion: { completion?() })
    }
}
