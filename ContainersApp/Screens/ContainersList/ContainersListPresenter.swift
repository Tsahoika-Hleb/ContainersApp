//

import Foundation

enum ContainerListFilter {
    case all
    case notSend
    case notIdentified
}

protocol ContainerListViewDelegateProtocol: AnyObject {
    func showContainersList()
    func urlValidationError()
    func urlValidationSucces()
}

protocol ContainersListPresenterSpec {
    var delegate: ContainerListViewDelegateProtocol? { get set }
    var scunnedContainersCount: Int { get }
    var endpointsCount: Int { get }
    
    func setUp()
    func changeFilter(to filter: ContainerListFilter)
    func addEndpoint(_ url: String)
    func getContainerForRow(for row: Int) -> ScannedContainerModel
    func deleteContainerForRow(for row: Int)
    func getEndpointForRow(for row: Int) -> String
    func sendToServer()
    func returnToScanPage()
}

final class ContainersListPresenter: ContainersListPresenterSpec {
    
    // MARK: - Properties
    weak var delegate: ContainerListViewDelegateProtocol?
    var router: ContainersListRouterProtocol?
    var scunnedContainersCount: Int { return filteredScannedContainers.count }
    var endpointsCount: Int { return endpoints.count }
    
    // MARK: - Private Properties
    private let defaults = UserDefaults.standard
    
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
            switch currentFilter {
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
    
    private var endpoints: [String] = []
    
    // MARK: - Initialization
    init(delegate: ContainerListViewDelegateProtocol, router: ContainersListRouterProtocol) {
        self.delegate = delegate
        self.router = router
    }
    
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
            delegate?.urlValidationError()
            return
        }
        
        guard !endpoints.contains(url) else {
            return
        }
        
        endpoints.append(url)
        defaults.set(endpoints, forKey: S.UserDefaults.key)
        delegate?.urlValidationSucces()
    }
    
    func getContainerForRow(for row: Int) -> ScannedContainerModel {
        filteredScannedContainers[row]
    }
    
    func deleteContainerForRow(for row: Int) {
        let filter = currentFilter
        allScunnedContainers.remove(at: row)
        currentFilter = filter
    }
    
    func getEndpointForRow(for row: Int) -> String {
        endpoints[row]
    }
    
    func sendToServer() {
        // TODO: send to server
        print("Send")
    }
    
    func returnToScanPage() {
        //TODO: check established endpoint
        
        router?.showScanScreen()
    }
    
    // MARK: - Private Methods
    private func fetchScunnedContainers() {
        // TODO: fetch from core data
    }
    
    private func fetchEndpoints() {
        if let myArray = defaults.array(forKey: S.UserDefaults.key) as? [String] {
            endpoints = myArray
        } else {
            print("Error: can't get endpoints")
        }
    }
}
