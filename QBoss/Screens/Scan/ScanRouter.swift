import UIKit

protocol ScanRouterSpec {
    var viewController: UIViewController? { get set }
    
    func showContainersList(storageManager: DataStoreManagerProtocol, networkManager: DataUploadManagerProtocol)
}

class ScanRouter: ScanRouterSpec {
    internal weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func showContainersList(storageManager: DataStoreManagerProtocol, networkManager: DataUploadManagerProtocol) {
        guard let vc = viewController else {
            return
        }
        
        let containerListVC = ContainersListViewController()
        let router = ContainersListRouter(viewController: vc)
        let presenter = ContainersListPresenter(delegate: containerListVC,
                                                router: router,
                                                localStorageManager: storageManager,
                                                networkManager: networkManager)
        containerListVC.presenter = presenter
        containerListVC.modalPresentationStyle = .fullScreen
        vc.present(containerListVC, animated: true)
    }
}
