import Foundation

protocol DataUpdateHelperSendable: AnyObject {
    func setActualData()
}

final class DataUpdateHelper {
    
    weak var delegate: DataUpdateHelperSendable?
    
    // MARK: - private variables
    private var localStorageManager: DataStoreManagerProtocol?
    private var networkManager: DataUploadManagerProtocol?
    private lazy var networkMonitor: NetworkMonitor = .init()
    private lazy var feedbackGenerator = UINotificationFeedbackGenerator()
    
    init(localStorageManager: DataStoreManagerProtocol? = nil, networkManager: DataUploadManagerProtocol? = nil) {
        self.localStorageManager = localStorageManager
        self.networkManager = networkManager
        startMonitoringNetworkConnection()
    }
    
    // MARK: - actions
    
    func fetchScannedContainers(onlyUnsent: Bool, completion: @escaping (_ results: [ScannedContainerModel]) -> Void) {
        localStorageManager?.fetchAllContainers(onlyUnsent: onlyUnsent) { result in
            completion(result)
        }
    }
    
    func sendAllUnsentContainers(completion: ((ScannedContainerModel, Bool) -> Void)? = nil) {
        fetchScannedContainers(onlyUnsent: true) { [weak self] result in
            for container in result {
                self?.sendToServer(containerModel: container) { result in
                    completion?(container, result)
                }
            }
        }
    }
    
    func sendToServer(at url: URL, containerModel: ScannedContainerModel, completion: ((Bool) -> Void)? = nil) {}
    
    func sendToServer(containerModel: ScannedContainerModel, completion: ((Bool) -> Void)? = nil) {
        networkManager?.upload(RequestScannedObjectDto(from: containerModel)) { [weak self] result in
            guard result else { return }
            self?.localStorageManager?.updateContainerSendFlag(model: containerModel) { result in
                DispatchQueue.main.async { completion?(result) }
            }
        }
    }
    
    func deleteContainer(_ container: ScannedContainerModel, completion: @escaping ((Bool) -> Void)) {
        localStorageManager?.deleteContainer(model: container) { result in
            completion(result)
        }
    }
    
    func deleteAllContainers(completion: @escaping ((Bool) -> Void)) {
        localStorageManager?.deleteAllContainers { result in
            if result {
                completion(true)
            }
        }
    }
    
    func saveContainer(_ container: ScannedContainerModel) {
        localStorageManager?.saveContainer(model: container) { [weak self] result in
            if result {
                self?.feedbackGenerator.notificationOccurred(container.isScannedSuccessfully ? .success : .error)
                self?.sendToServer(containerModel: container) { [weak self] result in
                    guard result else { return }
                    self?.delegate?.setActualData()
                }
            }
        }
    }
    
    private func startMonitoringNetworkConnection() {
        networkMonitor.startMonitoring()
        networkMonitor.monitor.pathUpdateHandler = { [weak self] path in
            guard path.status != .unsatisfied else { return }
            self?.sendAllUnsentContainers { [weak self] _,_ in
                self?.delegate?.setActualData()
            }
        }
    }
}
