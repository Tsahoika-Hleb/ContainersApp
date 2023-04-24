import Foundation

struct Constansts {
    static let deviceID = UIDevice.current.identifierForVendor?.uuidString
    
    static var sessionId: Int = {
        let timestamp = Int(Date().timeIntervalSince1970)
        let randomNumber = Int.random(in: 1...100000)
        return timestamp * 100000 + randomNumber
    }()
}
