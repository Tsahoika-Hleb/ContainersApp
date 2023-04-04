import UIKit

protocol ContainersListRouterProtocol {
    var viewController: UIViewController? { get set }
    
    func showScanScreen(_ endpoint: String)
}

final class ContainersListRouter: ContainersListRouterProtocol {
    internal weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func showScanScreen(_ endpoint: String) { // TODO: transfer endpoint
        guard let vc = viewController else {
            return
        }
        vc.dismiss(animated: true)
        
//        let scanVC = ScanViewController()
//        let router = ScanRouter(viewController: scanVC)
//        let presenter = ScanPresenter(delegate: scanVC, router: router, endpoint: endpoint)
//        scanVC.presenter = presenter
//        scanVC.modalPresentationStyle = .fullScreen
//
//        vc.present(scanVC, animated: true)
    }
}
