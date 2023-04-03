import UIKit

protocol ContainersListRouterProtocol {
    var viewController: UIViewController? { get set }
    
    func showScanScreen()
}

final class ContainersListRouter: ContainersListRouterProtocol {
    internal weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func showScanScreen() { // TODO: transfer endpoint
        guard let vc = viewController else {
            return
        }
        vc.dismiss(animated: true)
    }
}
