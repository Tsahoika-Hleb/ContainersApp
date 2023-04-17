import Foundation
import CoreData

@objc(Container)
public class Container: NSManagedObject {

}

extension Container {
    var type: ScannedModelType {
        get {
            return ScannedModelType(rawValue: self.scannedType) ?? .NONE
        }
        set {
            self.scannedType = newValue.rawValue
        }
    }
}
