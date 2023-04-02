//

import UIKit

protocol ContainersListRouterProtocol {
    var viewController: UIViewController? { get set }
    
    func showScanScreen()
}

final class ContainersListRouter: ContainersListRouterProtocol {
    weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func showScanScreen() {
        guard let vc = viewController else {
            return
        }
        vc.dismiss(animated: true)
    }
}
