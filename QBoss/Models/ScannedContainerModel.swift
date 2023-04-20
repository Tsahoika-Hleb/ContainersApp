import Foundation

struct ScannedContainerModel: Codable {
    let title: String
    let detectedTime: Date
    let isScannedSuccessfully: Bool
    let latitude: Double
    let longitude: Double
    var isSentToServer: Bool
    let image: Data
    
    let scannedType: ContainerOrientationType
    let fullImage: Data
    
    var sizeCodeStr: String?
}
