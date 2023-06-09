import Foundation

enum ContainerListFilter {
    case all
    case notSend
    case notIdentified
}

protocol ContainersListPresenterSpec: AnyObject {
    var delegate: ContainerListViewDelegateProtocol? { get set }
    var scunnedContainersCount: Int { get }
    var endpointsCount: Int { get }
    
    func setUp()
    func changeFilter(to filter: ContainerListFilter)
    func addEndpoint(_ url: String)
    func container(for row: Int) -> ScannedContainerModel
    func deleteContainerForRow(for row: Int)
    func endpoint(for row: Int) -> String
    func sendToServer()
    func returnToScanPage(urlString: String)
}

final class ContainersListPresenter: ContainersListPresenterSpec {
    
    // MARK: - Properties
    weak var delegate: ContainerListViewDelegateProtocol?
    var scunnedContainersCount: Int { return filteredScannedContainers.count }
    var endpointsCount: Int { return endpoints.count }
    
    // MARK: - Private Properties
    private var router: ContainersListRouterProtocol?
    
    private var allScunnedContainers: [ScannedContainerModel] = [
        ScannedContainerModel(scanTimestamp: "30.3.2023 12:53",
                              latitude: 37.987,
                              longitude: -71.433,
                              serialNumber: "ABCU123567",
                              isIdentified: true,
                              isSentToServer: false),
        ScannedContainerModel(scanTimestamp: "30.3.2023 12:54",
                              latitude: 37.987,
                              longitude: -71.433,
                              serialNumber: "Not Identified",
                              isIdentified: false,
                              isSentToServer: false),
        ScannedContainerModel(scanTimestamp: "30.3.2023 12:55",
                              latitude: 37.987,
                              longitude: -71.433,
                              serialNumber: "ABCU123567",
                              isIdentified: true,
                              isSentToServer: true),
        ScannedContainerModel(scanTimestamp: "30.3.2023 12:56",
                              latitude: 37.987,
                              longitude: -71.433,
                              serialNumber: "ABCU123567",
                              isIdentified: true,
                              isSentToServer: false),
        ScannedContainerModel(scanTimestamp: "30.3.2023 12:57",
                              latitude: 37.987,
                              longitude: -71.433,
                              serialNumber: "Not Identified",
                              isIdentified: false,
                              isSentToServer: false),
        ScannedContainerModel(scanTimestamp: "30.3.2023 12:58",
                              latitude: 37.987,
                              longitude: -71.433,
                              serialNumber: "ABCU123567984387",
                              isIdentified: true,
                              isSentToServer: true)
    ]
    private var filteredScannedContainers: [ScannedContainerModel] = []
    
    private var currentFilter: ContainerListFilter = .all {
        didSet {
            setFilterFilter(currentFilter)
        }
    }
    
    private var endpoints: [String] = []
    
    // MARK: - Initialization
    init(delegate: ContainerListViewDelegateProtocol, router: ContainersListRouterProtocol) {
        self.delegate = delegate
        self.router = router
    }
    
    // MARK: - Methods
    func setUp() {
        currentFilter = .all
        
        fetchScunnedContainers()
        fetchEndpoints()
    }
    
    func changeFilter(to filter: ContainerListFilter) {
        currentFilter = filter
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
    
    func container(for row: Int) -> ScannedContainerModel {
        return filteredScannedContainers[row]
    }
    
    func deleteContainerForRow(for row: Int) {
        let filter = currentFilter
        allScunnedContainers.remove(at: row)
        currentFilter = filter
    }
    
    func endpoint(for row: Int) -> String {
        endpoints[row]
    }
    
    func sendToServer() {
        // TODO: send to server
        print("Send")
    }
    
    func returnToScanPage(urlString: String) {
        //TODO: check established endpoint
        guard let delegate,
                      !PermissionManager.shared.showAlertIfPermissionsDenied(viewController: delegate) else { return }
                if endpoints.contains(urlString) {
                    router?.showScanScreen(urlString)
                } else if urlString.validate(idCase: .url) {
                    UserDefaults.standard[.urls, default: []].append(urlString)
                    router?.showScanScreen(urlString)
                } else {
                    delegate.urlValidation(isSuccesful: false)
        }
    }
    
    // MARK: - Private Methods
    private func fetchScunnedContainers() {
        // TODO: fetch from core data
    }
    
    private func fetchEndpoints() {
        endpoints = UserDefaults.standard[.urls, default: []]
        delegate?.showLastEndpoint(endpoints.last ?? "")
    }
    
    private func setFilterFilter(_ filter: ContainerListFilter) {
        switch filter {
        case .all:
            filteredScannedContainers = allScunnedContainers
        case .notSend:
            filteredScannedContainers = allScunnedContainers.filter { !$0.isSentToServer }
        case .notIdentified:
            filteredScannedContainers = allScunnedContainers.filter { !$0.isIdentified }
        }
        delegate?.showContainersList()
    }
}
