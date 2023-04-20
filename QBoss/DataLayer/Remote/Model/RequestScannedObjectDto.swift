import Foundation

struct RequestScannedObjectDto: Codable {
    let deviceID: String?
    let title: String
    //let session: Int
    let detectedTime: String
    var isScannedSuccessfully: Bool
    let location: String
    let scannedType: ContainerOrientationType
    
    let image: String
    let fullImage: String
    
    var ownerCodeStr: String
    var groupCodeStr: String
    var rNumberCodeStr: String
    var checkCodeStr: String
    var sizeCodeStr: String
}

extension RequestScannedObjectDto {
    init(from container: ScannedContainerModel) {
        deviceID = Constansts.deviceID
        title = container.title
        
        let dateFormater = DateFormatter()
        dateFormater.timeStyle = .long
        dateFormater.dateStyle = .full
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
