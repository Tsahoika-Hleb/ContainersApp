import Foundation
import CoreLocation

protocol ScanViewControllerDelegate: AnyObject {
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
    
    // MARK: - Private Properties
    internal var router: ScanRouterSpec?
    private var endpoint: String
    private let defaults = UserDefaults.standard
    
    // MARK: - Initialization
    init(delegate: ScanViewControllerDelegate, router: ScanRouterSpec, endpoint: String) {
        self.delegate = delegate
        self.router = router
        self.endpoint = endpoint
        print(endpoint)
    }
    
    // MARK: - Methods
    func setUp() {

    }
    
    func performContainersList() {
        router?.showContainersList()
    }
}
