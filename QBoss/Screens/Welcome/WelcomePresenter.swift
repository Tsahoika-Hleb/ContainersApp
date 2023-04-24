import Foundation

protocol WelcomePresenterProtocol: AnyObject {
    var delegate: WelcomeViewControllerDelegate? { get set }
    
    func setUpPresenter()
    func startScanning(urlEstablished: Bool)
    func showContainers()
}

final class WelcomePresenter: WelcomePresenterProtocol {
    
    // MARK: - Properties
    weak var delegate: WelcomeViewControllerDelegate?
    
    // MARK: - Private Properties
    private var router: WelcomeRouterSpec?
    
    // MARK: - Initialization
    init(delegate: WelcomeViewControllerDelegate, router: WelcomeRouterSpec) {
        self.delegate = delegate
        self.router = router
    }
    
    // MARK: - Methods
    func setUpPresenter() {
        permissionRequest()
    }
    
    func permissionRequest() {
        PermissionManager.shared.requestAllPermissions()
    }
    
    func startScanning(urlEstablished: Bool) {
        guard let delegate,
              !PermissionManager.shared.showAlertIfPermissionsDenied(viewController: delegate) else { return }
        if urlEstablished {
            router?.showScanScreen()
        }
    }
    
    func showContainers() {
        router?.showContainersList()
    }
}
