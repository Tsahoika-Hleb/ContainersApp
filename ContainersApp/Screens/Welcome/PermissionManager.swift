import UIKit
import CoreLocation
import AVFoundation

final class PermissionManager: NSObject, CLLocationManagerDelegate {
    
    // MARK: - variables
    static let shared: PermissionManager = .init()
    private let locationManager = CLLocationManager()
    private override init() {
        super.init()
        locationManager.delegate = self
    }
    
    // MARK: - permission request.
    func requestAllPermissions() {
        requestCameraPermission { [weak self] cameraGranted in
            self?.requestLocationPermission()
        }
    }
    private func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async { completion(granted) }
        }
    }
    
    private func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - permission status.
    func cameraPermissionStatus() -> AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: .video)
    }
    func locationPermissionStatus() -> CLAuthorizationStatus {
        return locationManager.authorizationStatus
    }
    
    // MARK: - setting alert
    /// - Returns: 'true' if alert showed and 'false' if all permissions granted
    func showAlertIfPermissionsDenied(viewController: UIViewController) -> Bool {
        guard cameraPermissionStatus() == .denied
                || locationPermissionStatus() == .denied else { return false }
        let alertController = UIAlertController(
            title: S.Screens.Welcome.allertTitle,
            message: S.Screens.Welcome.allertMessage,
            preferredStyle: .alert)
        let cancelAction = UIAlertAction.cancelAction
        let settingsAction = UIAlertAction.settingAction
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        viewController.present(alertController, animated: true, completion: nil)
        return true
    }
}
