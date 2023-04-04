import UIKit
import CoreLocation

final class StartHelper {
    
    func setRootVC () -> UIViewController {
        let vc = WelcomeViewController()
        let router = WelcomeRouter(viewController: vc)
        let presenter = WelcomePresenter(delegate: vc, router: router)
        vc.presenter = presenter
        return vc
    }
}
