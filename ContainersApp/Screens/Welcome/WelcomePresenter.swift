//

import Foundation
import CoreLocation

protocol WelcomeViewControllerDelegate: AnyObject {
    func urlValidationError()
}

protocol WelcomePresenterProtocol: AnyObject {
    var delegate: WelcomeViewControllerDelegate? { get set }
    var router: WelcomeRouterSpec? { get set }
    
    func urlReferenceValidate(_ url: String)
    func locationRequest()
}

final class WelcomePresenter: WelcomePresenterProtocol {
    
    // MARK: - Properties
    weak var delegate: WelcomeViewControllerDelegate?
    var router: WelcomeRouterSpec?
    private let locationManager: CLLocationManager!
    
    // MARK: - Initialization
    init(delegate: WelcomeViewControllerDelegate, router: WelcomeRouterSpec, locationManager: CLLocationManager) {
        self.delegate = delegate
        self.router = router
        self.locationManager = locationManager
    }
    
    // MARK: - Methods
    func urlReferenceValidate(_ urlString: String) {
        
        if urlString.validate(idCase: .url) {
            
            let defaults = UserDefaults.standard
            defaults.set([urlString], forKey: S.UserDefaults.key)
            defaults.synchronize()
            router?.showScanScreen(locationManager: locationManager)
        } else {
            delegate?.urlValidationError()
        }
    }
    
    func locationRequest() {
        locationManager.requestWhenInUseAuthorization()
    }
}
