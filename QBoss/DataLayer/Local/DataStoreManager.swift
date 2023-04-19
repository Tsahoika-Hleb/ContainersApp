import CoreData
import UIKit

protocol DataStoreManagerProtocol {
    func fetchAllContainers(completion: @escaping ([ScannedContainerModel]) -> Void)
    func saveContainer(model: ScannedContainerModel, completion: @escaping (Bool) -> Void)
    func deleteContainer(model: ScannedContainerModel, completion: @escaping (Bool) -> Void)
    func deleteAllContainers(completion: @escaping (Bool) -> Void)
    func updateContainerSendFlag(model: ScannedContainerModel, completion: @escaping (Bool) -> Void)
}
class DataStoreManager: DataStoreManagerProtocol {
        
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "QBoss")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
    
    func fetchAllContainers(completion: @escaping ([ScannedContainerModel]) -> Void) {
        let fetchRequest: NSFetchRequest<Container> = Container.fetchRequest()
        performBackgroundTask { context in
            do {
                let containers = try context.fetch(fetchRequest)
                let models = containers.map { ScannedContainerModel(from: $0) }
                DispatchQueue.main.async {
                    completion(models)
                }
            } catch {
                print("Error fetching containers: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
    
    func saveContainer(model: ScannedContainerModel, completion: @escaping (Bool) -> Void) {
        performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<Container> = Container.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "title == %@", model.title)
            
            do {
                let existingContainers = try context.fetch(fetchRequest)
                if existingContainers.isEmpty {
                    let newContainer = Container(model: model, context: context)
                    try context.save()
                    DispatchQueue.main.async {
                        completion(true) }
                } else {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            } catch {
                print("Error saving container: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    func deleteContainer(model: ScannedContainerModel, completion: @escaping (Bool) -> Void) {
        performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<Container> = Container.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "title == %@", model.title)
            
            do {
                let containers = try context.fetch(fetchRequest)
                guard let container = containers.first else {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                    return }
                context.delete(container)
                try context.save()
                DispatchQueue.main.async {
                    completion(true)
                }
            } catch {
                print("Error deleting container: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    func deleteAllContainers(completion: @escaping (Bool) -> Void) {
        performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<Container> = Container.fetchRequest()
            do {
                let containers = try context.fetch(fetchRequest)
                for container in containers {
                    context.delete(container)
                }
                try context.save()
                DispatchQueue.main.async {
                    completion(true)
                }
            } catch {
                print("Error deleting all containers: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    func updateContainerSendFlag(model: ScannedContainerModel, completion: @escaping (Bool) -> Void) {
        performBackgroundTask{ context in
            let fetchRequest: NSFetchRequest<Container> = Container.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "title == %@", model.title)
            
            do {
                let results = try? context.fetch(fetchRequest)
                guard let container = results?.first else {
                    completion(false)
                    return
                }
                container.isSent = true
                try context.save()
                completion(true)
            } catch {
                completion(false)
            }
        }
    }
}

                                            
extension ScannedContainerModel {
    init(from container: Container) {
        title = container.title
        detectedTime = container.detectedTime
        isScannedSuccessfully = container.isScannedSuccessfully
        latitude = container.latitude
        longitude = container.longitude
        isSentToServer = container.isSent
        image = container.image
        scannedType = container.type
        fullImage = container.fullImage
        sizeCodeStr = container.sizeCodeStr
    }
}
                                             
extension Container {
    convenience init(model: ScannedContainerModel, context: NSManagedObjectContext) {
        self.init(context: context)
        title = model.title
        detectedTime = model.detectedTime
        isScannedSuccessfully = model.isScannedSuccessfully
        latitude = model.latitude
        longitude = model.longitude
        isSent = model.isSentToServer
        image = model.image
        type = model.scannedType
        fullImage = model.fullImage
        sizeCodeStr = model.sizeCodeStr
    }
}
