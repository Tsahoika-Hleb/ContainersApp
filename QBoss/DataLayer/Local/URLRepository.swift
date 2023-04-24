import Foundation

final class URLRepository {
    
    var selectedUrl: String? { endpoints.last }
    
    var endpointsCount: Int { endpoints.count }
    
    func addEndpoint(_ url: String) -> Bool {
        
        guard url.validate(idCase: .url) else {
            return false
        }
        
        guard !endpoints.contains(url) else {
            setSelected(url)
            return true
        }
        
        endpoints.append(url)
        UserDefaults.standard[.urls, default: []].append(contentsOf: endpoints)
        return true
    }
    
    func setSelected(_ url: String) {
        endpoints.removeAll(where: { $0 == url })
        endpoints.append(url)
        UserDefaults.standard[.urls, default: []].removeAll()
        UserDefaults.standard[.urls, default: []].append(contentsOf: endpoints)
    }
    
    func endpoint(for row: Int) -> String {
        endpoints[row]
    }
    
    func fetchLastEndpoint() -> String {
        endpoints.last ?? ""
    }
    
    func deleteEndpoint(for row: Int) {
        //TODO:
        endpoints.remove(at: row)
        UserDefaults.standard[.urls, default: []].removeAll()
        UserDefaults.standard[.urls, default: []].append(contentsOf: endpoints)
    }
    
    private var endpoints = UserDefaults.standard[.urls, default: []]
}
