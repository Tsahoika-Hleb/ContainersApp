import Network

class NetworkMonitor {
    let monitor = NWPathMonitor()
    var isMonitoring = false
    
    func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true
        monitor.start(queue: DispatchQueue.global())
    }
    
    func stopMonitoring() {
        guard isMonitoring else { return }
        isMonitoring = false
        monitor.cancel()
    }
}
