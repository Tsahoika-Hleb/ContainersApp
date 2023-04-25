import Foundation

enum ContainerOrientationType: String, Codable {
    case none = "NONE"
    case horizontal = "HORIZONTAL"
    case vertical = "VERTICAL"
}

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
        let keysToInclude: [CodingKeys] = [.ownerCode, .groupCode, .registrationNumber]
        return keysToInclude.compactMap { overlays[$0] }
    }
    
    init(models: [ObjectOverlay]) {
        overlays = models.reduce(into: [CodingKeys: ObjectOverlay]()) { result, model in
            if let key = CodingKeys.allCases.first(where: { model.name.contains($0.rawValue) }) {
                result[key] = model
            }
        }
    }
    
    func getContainerOrientation() -> ContainerOrientationType {
        let isContainsVertical: Bool = overlays.contains(where: { $0.key == .vertical })
        let isContainsHorizontal: Bool = overlays.contains(where: { $0.key == .horizontal })
        switch (isContainsVertical, isContainsHorizontal) {
        case (true, false):
            return .vertical
        case (false, true):
            return .horizontal
        default:
            return .none
        }
    }
    
    subscript(key: CodingKeys) -> ObjectOverlay? {
        return overlays[key]
    }
}
