import Foundation

enum ContainerListFilter {
    case all
    case notSend
    case notIdentified
}

protocol ContainersListPresenterSpec: AnyObject {
    var delegate: ContainerListViewDelegateProtocol? { get set }
    var scannedContainersCount: Int { get }
    
    func setUp()
    func changeFilter(to filter: ContainerListFilter)
    func container(for row: Int) -> ScannedContainerModel
    func deleteContainerForRow(for row: Int)
    func removeAllContainers()
    func sendToServer(for row: Int)
    func toScanPage(isUrlEstablished: Bool)
}

final class ContainersListPresenter: ContainersListPresenterSpec {
    
    // MARK: - Properties
    weak var delegate: ContainerListViewDelegateProtocol?
    var scannedContainersCount: Int { return filteredScannedContainers.count }
    
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
    }
    
    func changeFilter(to filter: ContainerListFilter) {
        currentFilter = filter
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
    
    func sendToServer(for row: Int) {
        dataUpdateHelper.sendToServer(containerModel: filteredScannedContainers[row]) { [weak self] result in
            self?.filteredScannedContainers[row].isSentToServer = result
            self?.delegate?.showContainersList()
        }
    }
    
    func toScanPage(isUrlEstablished: Bool) {
        guard let delegate,
              !PermissionManager.shared.showAlertIfPermissionsDenied(viewController: delegate) else { return }
        if isUrlEstablished {
            router?.showScanScreen()
        }
    }
    
    // MARK: - Private Methods
    private func fetchScannedContainers() {
        dataUpdateHelper.fetchScannedContainers(onlyUnsent: false) { [weak self] result in
            self?.allScannedContainers = result
            self?.setDataByCurrentFilter()
        }
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
