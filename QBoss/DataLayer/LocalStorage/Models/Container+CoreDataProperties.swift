import Foundation
import CoreData


extension Container {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Container> {
        return NSFetchRequest<Container>(entityName: "Container")
    }

    @NSManaged public var checkCodeStr: String
    @NSManaged public var detectedTime: Date
    @NSManaged public var fullImage: Data
    @NSManaged public var groupCodeStr: String
    @NSManaged public var image: Data
    @NSManaged public var isScannedSuccessfully: Bool
    @NSManaged public var isSent: Bool
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var ownerCodeStr: String
    @NSManaged public var rNumberCodeStr: String
    @NSManaged public var scannedType: String
    @NSManaged public var session: Int16
    @NSManaged public var sizeCodeStr: String
    @NSManaged public var tiltle: String

}


