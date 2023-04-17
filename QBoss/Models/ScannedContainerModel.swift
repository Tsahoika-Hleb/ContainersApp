import Foundation

struct ScannedContainerModel: Codable {
    let title: String
    let detectedTime: String
    var isScannedSuccessfully: Bool
    let latitude: Double
    let longitude: Double
    let isSentToServer: Bool
    let image: Data
    
    let session: Int
    let scunnedType: ScannedModelType
    let fullImage: Data
    
    var ownerCodeStr: String
    var groupCodeStr: String
    var rNumberCodeStr: String
    var checkCodeStr: String
    var sizeCodeStr: String
}
