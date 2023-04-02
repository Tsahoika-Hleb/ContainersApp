//

import Foundation
import CoreLocation

protocol ScanViewControllerDelegate: AnyObject {
    func locationPermissionDenied()
}

protocol ScanPresenterProtocol: AnyObject {
    var delegate: ScanViewControllerDelegate? { get set }
    var router: ScanRouterSpec? { get set }
    
    func setUp()
    func performContainersList()
}

final class ScanPresenter: ScanPresenterProtocol {
    
    // MARK: - Properties
    weak var delegate: ScanViewControllerDelegate?
    var router: ScanRouterSpec?
    var locationManager: CLLocationManager?
    
    // MARK: - Private Properties
    private var currentEndpoint: String?
    private let defaults = UserDefaults.standard
    
    // MARK: - Initialization
    init(delegate: ScanViewControllerDelegate, router: ScanRouterSpec, locationManager: CLLocationManager) {
        self.delegate = delegate
        self.router = router
        self.locationManager = locationManager
    }
    
    // MARK: - Methods
    func setUp() {
        setCurrentEndpoint()
        checkLocationPermission()
    }
    
    func performContainersList() {
        router?.showContainersList()
    }
    
    // MARK: - Private Methods
    /**
     Takes the last added Enpoint to UserDefaults
     */
    private func setCurrentEndpoint() {
        if let myArray = defaults.array(forKey: S.UserDefaults.key) as? [String] {
            if let lastString = myArray.last {
                currentEndpoint = lastString
                print(lastString)
            }
        } else {
            print("Array not found in UserDefaults")
        }
    }
    
    private func checkLocationPermission() {
        switch locationManager?.authorizationStatus {
        case .notDetermined:
            locationManager?.requestWhenInUseAuthorization()
        case .denied:
            DispatchQueue.main.async {
                self.delegate?.locationPermissionDenied()
            }
        default:
            break
        }
    }
}
