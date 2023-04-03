import UIKit

protocol WelcomeViewControllerDelegate: AnyObject {
    func urlValidation(isSuccesful: Bool)
    func showLastEndpoint(_ endpoint: String)
}

protocol WelcomePresenterProtocol: AnyObject {
    var delegate: WelcomeViewControllerDelegate? { get set }
    var endpointsCount: Int { get }
    
    func setUpPresenter()
    func addEndpoint(_ url: String)
    func endpoint(for row: Int) -> String
    func startScanning(_ urlString: String)
}

final class WelcomePresenter: WelcomePresenterProtocol {
    
    // MARK: - Properties
    weak var delegate: WelcomeViewControllerDelegate?
    var endpointsCount: Int { return endpoints.count }
    
    // MARK: - Private Properties
    private var router: WelcomeRouterSpec?
    private var endpoints: [String] = []
    
    // MARK: - Initialization
    init(delegate: WelcomeViewControllerDelegate, router: WelcomeRouterSpec) {
        self.delegate = delegate
        self.router = router
    }
    
    // MARK: - Methods
    func setUpPresenter() {
        fetchEndpoints()
        permissionRequest()
    }
    
    func permissionRequest() {
        PermissionManager.shared.requestAllPermissions()
    }
    
    func addEndpoint(_ url: String) {
        guard url.validate(idCase: .url) else {
            delegate?.urlValidation(isSuccesful: false)
            return
        }
        
        guard !endpoints.contains(url) else {
            return
        }
        
        endpoints.append(url)
        UserDefaults.standard[.urls, default: []].append(contentsOf: endpoints)
        delegate?.urlValidation(isSuccesful: true)
    }
    
    func endpoint(for row: Int) -> String {
        endpoints[row]
    }
    
    func startScanning(_ urlString: String) {
        if endpoints.contains(urlString) {
            if let delegate, !PermissionManager.shared.showAlertIfPermissionsDenied(viewController: delegate as! UIViewController) {
                router?.showScanScreen(endpoint: urlString)
            }
        } else if urlString.validate(idCase: .url), let delegate,
           !PermissionManager.shared.showAlertIfPermissionsDenied(viewController: delegate as! UIViewController) {
            UserDefaults.standard[.urls, default: []].append(urlString)
            router?.showScanScreen(endpoint: urlString)
        } else {
            delegate?.urlValidation(isSuccesful: false)
        }
    }
    
    // MARK: - Private Methods
    private func fetchEndpoints() {
        endpoints = UserDefaults.standard[.urls, default: []]
        if !endpoints.isEmpty {
            delegate?.showLastEndpoint(endpoints.last!)
        }
    }
}
