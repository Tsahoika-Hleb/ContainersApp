import UIKit
import CoreLocation

protocol WelcomeRouterSpec {
    var viewController: UIViewController? { get set }
    
    func showScanScreen(endpoint: String)
}

final class WelcomeRouter: WelcomeRouterSpec {
    internal weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func showScanScreen(endpoint: String) {
        guard let vc = viewController else {
            return
        }
        
        let scanVC = ScanViewController()
        let router = ScanRouter(viewController: scanVC)
        let presenter = ScanPresenter(delegate: scanVC, router: router, tfManager: TFManager(), endpoint: endpoint)
        scanVC.presenter = presenter
        scanVC.modalPresentationStyle = .fullScreen
        
        vc.present(scanVC, animated: true)
    }
}
