//

import UIKit
import CoreLocation

final class StartHelper {
    
    private let defaults = UserDefaults.standard
    
    func setRootVC () -> UIViewController {
        if defaults.array(forKey: S.UserDefaults.key) is [String] {
            let vc = ScanViewController()
            let router = ScanRouter(viewController: vc)
            let presenter = ScanPresenter(delegate: vc, router: router, locationManager: CLLocationManager())
            vc.presenter = presenter
            return vc
            
        } else {
            let vc = WelcomeViewController()
            let router = WelcomeRouter(viewController: vc)
            let presenter = WelcomePresenter(delegate: vc, router: router, locationManager: CLLocationManager())
            vc.presenter = presenter
            return vc
        }
    }
}
