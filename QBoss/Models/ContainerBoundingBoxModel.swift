import Foundation

struct ContainerBoundingBoxModel {
    enum CodingKeys: String, CaseIterable {
        case vertical
        case horizontal
        case ownerCode = "owner_code"
        case groupCode = "group_code"
        case registrationNumber = "registration_number"
        case checkDigit = "check_digit"
        case sizeTypeCode = "size_type_code"
    }
    
    private(set) var overlays: [CodingKeys: ObjectOverlay]
    
    var mainBox: ObjectOverlay? {
        return overlays[.horizontal] ?? overlays[.vertical]
    }
    
    var partialImageBoxes: [ObjectOverlay] {
        let keysToInclude: [CodingKeys] = [.ownerCode, .groupCode, .registrationNumber, .checkDigit, .sizeTypeCode]
        return keysToInclude.compactMap { overlays[$0] }
    }
    
    init(models: [ObjectOverlay]) {
        overlays = models.reduce(into: [CodingKeys: ObjectOverlay]()) { result, model in
            if let key = CodingKeys.allCases.first(where: { model.name.contains($0.rawValue) }) {
                result[key] = model
            }
        }
    }
    
    subscript(key: CodingKeys) -> ObjectOverlay? {
        return overlays[key]
    }
}
