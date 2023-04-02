//

import UIKit

protocol ScanRouterSpec {
    var viewController: UIViewController? { get set }
    
    func showContainersList()
}


class ScanRouter: ScanRouterSpec {
    weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func showContainersList() {
        guard let vc = viewController else {
            return
        }
        
        let containerListVC = ContainersListViewController()
        let router = ContainersListRouter(viewController: vc)
        let presenter = ContainersListPresenter(delegate: containerListVC, router: router)
        containerListVC.presenter = presenter
        containerListVC.modalPresentationStyle = .fullScreen
        
        vc.present(containerListVC, animated: true)
    }
}
