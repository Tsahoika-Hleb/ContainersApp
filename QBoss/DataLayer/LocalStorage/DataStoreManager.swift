import Foundation
import CoreData

protocol ContainerStoreProtocol {
    func saveContainer(_ container: ScannedContainerModel,
                       complitionHandler: @escaping (Swift.Result<Void, Error>) -> ())
    func fetchContainers( _ complitionHndler:  @escaping (Swift.Result<[ScannedContainerModel], Error>) -> ())
    func removeAll()
}

class DataStoreManager: ContainerStoreProtocol {
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "QBoss")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    lazy var viewContext = persistentContainer.viewContext
    lazy var backgroundContext = persistentContainer.newBackgroundContext()
    
    func saveContainer(_ container: ScannedContainerModel, complitionHandler: @escaping (Swift.Result<Void, Error>) -> ()) {
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        let containerToSave = Container(context: backgroundContext)
        
        containerToSave.tiltle = container.title
        
        backgroundContext.perform {
            do {
                
                containerToSave.isSent = container.isSentToServer
                
                try self.backgroundContext.save()
                complitionHandler(.success(()))
            } catch let error {
                complitionHandler(.failure(error))
            }
        }
    }
    
    func fetchContainers( _ complitionHndler:
                          @escaping (Swift.Result<[ScannedContainerModel], Error>) -> ()) {
        let containerFetch: NSFetchRequest<Container> = Container.fetchRequest()
        do {
            let results = try viewContext.fetch(containerFetch)
            
            var scunnedContainers: [ScannedContainerModel] = []
            for item in results {
                scunnedContainers.append(ScannedContainerModel(
                    title: item.tiltle,
                    detectedTime: DateFormatter().string(from: item.detectedTime),
                    isScannedSuccessfully: item.isScannedSuccessfully,
                    latitude: item.latitude,
                    longitude: item.longitude,
                    isSentToServer: item.isSent,
                    image: item.image,
                    session: Int(item.session),
                    scunnedType: item.type,
                    fullImage: item.fullImage,
                    ownerCodeStr: item.ownerCodeStr,
                    groupCodeStr: item.groupCodeStr,
                    rNumberCodeStr: item.rNumberCodeStr,
                    checkCodeStr: item.checkCodeStr,
                    sizeCodeStr: item.sizeCodeStr)
                )
            }
            
            complitionHndler(.success(scunnedContainers))
            
        } catch let error as NSError {
            complitionHndler(.failure(error))
        }
    }
    
    func removeAll() {
        let containerFetch: NSFetchRequest<Container> = Container.fetchRequest()
        do {
            let results = try viewContext.fetch(containerFetch)
            for item in results {
                viewContext.delete(item)
            }
            try viewContext.save()
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
    }
}

