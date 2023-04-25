import Foundation

protocol DataUploadManagerProtocol {
    func upload(_ model: RequestScannedObjectDto, completionHandler: @escaping (Bool) -> ())
}

class DataUploadManager: DataUploadManagerProtocol {
    
    func upload(_ model: RequestScannedObjectDto, completionHandler: @escaping (Bool) -> ()) {
        guard let urlString = UserDefaults.standard[.urls, default: []].last, let url = URL(string: urlString) else {
            completionHandler(false)
            return
        }
        print(url)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        guard let jsonData = try? encoder.encode(model) else {
            return
        }
        
        request.httpBody = jsonData
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error {
                print("\(error.localizedDescription)")
                completionHandler(false)
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    completionHandler(true)
                }
            }
            
            if let data = data {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Server answer: \(responseString)")
                }
            }
            
            completionHandler(false)
        }
        task.resume()
    }
}
