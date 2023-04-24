import Foundation

struct RequestScannedObjectDto: Codable {
    let deviceID: String?
    let title: String
    let session: Int
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

struct CISParts {
    var ownerCodeStr: String
    var groupCodeStr: String
    var rNumberCodeStr: String
    var checkCodeStr: String
    var sizeCodeStr: String
    
    init(from serialNumber: String) {
        ownerCodeStr = String(serialNumber.prefix(3))
        groupCodeStr = String(serialNumber[serialNumber.index(serialNumber.startIndex, offsetBy: 3)])
        
        let range = 5...10
        rNumberCodeStr = String(serialNumber.prefix(range.upperBound).suffix(range.count))
        checkCodeStr = String(serialNumber[serialNumber.index(serialNumber.startIndex, offsetBy: 10)])
        
        if serialNumber.count > 11 {
            let range = 11...15
            sizeCodeStr = String(serialNumber.prefix(range.upperBound).suffix(range.count))
        } else {
            sizeCodeStr = ""
        }
    }
}

extension RequestScannedObjectDto {
    init(from container: ScannedContainerModel) {
        deviceID = Constansts.deviceID
        title = container.title
        session = container.session
        
        detectedTime = container.detectedTime.dateToString()
        
        isScannedSuccessfully = container.isScannedSuccessfully
        location = "\(container.latitude) \(container.longitude)"
        scannedType = container.scannedType
        
        image = container.image.base64EncodedString()
        fullImage = container.fullImage.base64EncodedString()
        
        let parts = CISParts(from: (title + (container.sizeCodeStr ?? "")))
        ownerCodeStr = parts.ownerCodeStr
        groupCodeStr = parts.groupCodeStr
        rNumberCodeStr = parts.rNumberCodeStr
        checkCodeStr = parts.checkCodeStr
        sizeCodeStr = parts.sizeCodeStr
    }
}
