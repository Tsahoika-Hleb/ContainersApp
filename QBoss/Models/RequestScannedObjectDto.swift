import Foundation

struct RequestScannedObjectDto: Codable {
    let deviceID: String?
    let title: String
    let session: Int
    let detectedTime: String
    var isScannedSuccessfully: Bool
    let location: String
    let scannedType: ScannedModelType
    
    let image: String
    let fullImage: String
    
    var ownerCodeStr: String
    var groupCodeStr: String
    var rNumberCodeStr: String
    var checkCodeStr: String
    var sizeCodeStr: String
}

enum ScannedModelType: String, Codable {
    case NONE, HORIZONTAL, VERTICAL
}
