import Foundation
import CoreData

@objc(Container)
public class Container: NSManagedObject {
    
}

extension Container {
    var type: ContainerOrientationType {
        get {
            return ContainerOrientationType(rawValue: self.scannedType) ?? .none
        }
        set {
            self.scannedType = newValue.rawValue
        }
    }
}
