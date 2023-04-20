import Foundation

enum ContainerListFilter {
    case all
    case notSend
    case notIdentified
}

protocol ContainersListPresenterSpec: AnyObject {
    var delegate: ContainerListViewDelegateProtocol? { get set }
    var scannedContainersCount: Int { get }
    var endpointsCount: Int { get }
    
    func setUp()
    func changeFilter(to filter: ContainerListFilter)
    func addEndpoint(_ url: String)
    func container(for row: Int) -> ScannedContainerModel
    func deleteContainerForRow(for row: Int)
    func removeAllContainers()
    func endpoint(for row: Int) -> String
    func sendToServer(for row: Int)
    func returnToScanPage(urlString: String)
}

final class ContainersListPresenter: ContainersListPresenterSpec {
    
    // MARK: - Properties
    weak var delegate: ContainerListViewDelegateProtocol?
    var scannedContainersCount: Int { return filteredScannedContainers.count }
    var endpointsCount: Int { return endpoints.count }
    
    // MARK: - Private Properties
    private var router: ContainersListRouterProtocol?
    private var dataUpdateHelper: DataUpdateHelper
    
    private var allScannedContainers: [ScannedContainerModel] = []
    private var filteredScannedContainers: [ScannedContainerModel] = []
    
    private var currentFilter: ContainerListFilter = .all {
        didSet {
            setDataByCurrentFilter()
        }
    }
    
    private var endpoints: [String] = []
    
    // MARK: - Initialization
    init(delegate: ContainerListViewDelegateProtocol, router: ContainersListRouterProtocol, dataUpdateHelper: DataUpdateHelper) {
        self.delegate = delegate
        self.router = router
        self.dataUpdateHelper = dataUpdateHelper
        dataUpdateHelper.delegate = self
    }
    
    // MARK: - Methods
    func setUp() {
        fetchScannedContainers()
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
        let itemToDelete = filteredScannedContainers[row]
        dataUpdateHelper.deleteContainer(itemToDelete) { [weak self] result in
            self?.allScannedContainers.removeAll(where: { $0.title == itemToDelete.title })
            self?.setDataByCurrentFilter()
        }
    }
    
    func removeAllContainers() {
        dataUpdateHelper.deleteAllContainers { [weak self] result in
            if result {
                self?.allScannedContainers = []
                self?.filteredScannedContainers = []
                self?.setDataByCurrentFilter()
            }
        }
    }
    
    func endpoint(for row: Int) -> String {
        endpoints[row]
    }
    
    func sendToServer(for row: Int) {
        dataUpdateHelper.sendToServer(containerModel: filteredScannedContainers[row]) { [weak self] result in
            self?.filteredScannedContainers[row].isSentToServer = result
            self?.delegate?.showContainersList()
        }
    }
    
    func returnToScanPage(urlString: String) {
        //TODO: check established endpoint
        guard let delegate,
              !PermissionManager.shared.showAlertIfPermissionsDenied(viewController: delegate) else { return }
        if endpoints.contains(urlString) {
            router?.showScanScreen()
        } else if urlString.validate(idCase: .url) {
            UserDefaults.standard[.urls, default: []].append(urlString)
            router?.showScanScreen()
        } else {
            delegate.urlValidation(isSuccesful: false)
        }
    }
    
    // MARK: - Private Methods
    private func fetchScannedContainers() {
        dataUpdateHelper.fetchScannedContainers(onlyUnsent: false) { [weak self] result in
            self?.allScannedContainers = result
            self?.setDataByCurrentFilter()
        }
    }
    
    private func fetchEndpoints() {
        endpoints = UserDefaults.standard[.urls, default: []]
        delegate?.showLastEndpoint(endpoints.last ?? "")
    }
    
    private func setDataByCurrentFilter() {
        switch currentFilter {
        case .all:
            filteredScannedContainers = allScannedContainers
        case .notSend:
            filteredScannedContainers = allScannedContainers.filter { !$0.isSentToServer }
        case .notIdentified:
            filteredScannedContainers = allScannedContainers.filter { !$0.isScannedSuccessfully }
        }
        filteredScannedContainers = filteredScannedContainers.sorted { $0.detectedTime > $1.detectedTime }
        delegate?.showContainersList()
    }
}

extension ContainersListPresenter: DataUpdateHelperSendable {
    func setActualData() { fetchScannedContainers() }
}
