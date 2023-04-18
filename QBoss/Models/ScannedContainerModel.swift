import Foundation

struct ScannedContainerModel: Codable {
    let title: String
    let detectedTime: Date
    var isScannedSuccessfully: Bool
    let latitude: Double
    let longitude: Double
    let isSentToServer: Bool
    let image: Data
    
    let scannedType: ScannedModelType
    let fullImage: Data
    
    var sizeCodeStr: String?
}
