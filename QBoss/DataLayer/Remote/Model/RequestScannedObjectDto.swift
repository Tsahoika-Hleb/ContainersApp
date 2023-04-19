import Foundation

struct RequestScannedObjectDto: Codable {
    let deviceID: String?
    let title: String
    //let session: Int
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

extension RequestScannedObjectDto {
    init(from container: ScannedContainerModel) {
        deviceID = nil
        title = container.title
        
        let dateFormater = DateFormatter()
        dateFormater.timeStyle = .full
        detectedTime = dateFormater.string(from: container.detectedTime)
        
        isScannedSuccessfully = container.isScannedSuccessfully
        location = "\(container.latitude) \(container.longitude)"
        scannedType = container.scannedType
        
        image = container.image.base64EncodedString()
        fullImage = container.fullImage.base64EncodedString()
        
        ownerCodeStr = String(container.title.prefix(3))
        groupCodeStr = String(container.title[container.title.index(container.title.startIndex, offsetBy: 3)])
        let range = 5...10
        rNumberCodeStr = String(container.title.prefix(range.upperBound).suffix(range.count))
        checkCodeStr = String(container.title[container.title.index(container.title.startIndex, offsetBy: 10)])
        
        if let sizeCode = container.sizeCodeStr {
            sizeCodeStr = sizeCode
        } else {
            sizeCodeStr = ""
        }
    }
}
