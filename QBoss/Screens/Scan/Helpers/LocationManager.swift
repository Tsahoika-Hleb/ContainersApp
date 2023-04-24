import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    private var locationTimer: Timer?
    private var locationCompletionHandler: ((CLLocation?, Error?) -> Void)?
    
    var currentLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        startUpdatingLocation()
    }
    
    deinit {
        stopUpdatingLocation()
    }
    
    private func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        locationTimer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(updateLocation), userInfo: nil, repeats: true)
    }
    
    private func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        locationTimer?.invalidate()
        locationTimer = nil
    }
    
    @objc private func updateLocation() {
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        locationCompletionHandler?(location, nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationCompletionHandler?(nil, error)
    }
}
