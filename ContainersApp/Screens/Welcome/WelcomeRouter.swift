//

import UIKit
import CoreLocation

protocol WelcomeRouterSpec {
    var viewController: UIViewController? { get set }
    
    func showScanScreen(locationManager: CLLocationManager)
}

final class WelcomeRouter: WelcomeRouterSpec {
    weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func showScanScreen(locationManager: CLLocationManager) {
        guard let vc = viewController else {
            return
        }
        
        let scanVC = ScanViewController()
        let router = ScanRouter(viewController: scanVC)
        let presenter = ScanPresenter(delegate: scanVC, router: router, locationManager: locationManager)
        scanVC.presenter = presenter
        scanVC.modalPresentationStyle = .fullScreen
        
        vc.present(scanVC, animated: true)
    }
}
