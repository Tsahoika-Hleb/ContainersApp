import Foundation
import TensorFlowLiteTaskVision

final class ScanPresenter: ScanPresenterProtocol {
    
    // MARK: - Properties
    weak var delegate: ScanViewControllerDelegate?
    var tfManager: TFManager?
    let imageToTextProcessor: ImageToTextProcessor = .init()
    let boundingBoxCalculator = BoundingBoxCalculator()
    let validator = CISValidator()
    
    // MARK: - Private Properties
    internal var router: ScanRouterSpec?
    private var endpoint: String
    private let defaults = UserDefaults.standard
    private var localStorageManager: DataStoreManagerProtocol?
    private var networkManager: DataUploadManagerProtocol?
    
    // MARK: - Initialization
    init(delegate: ScanViewControllerDelegate, router: ScanRouterSpec,
         tfManager: TFManager, endpoint: String,
         localStorageManager: DataStoreManagerProtocol, networkManager: DataUploadManagerProtocol) {
        self.delegate = delegate
        self.router = router
        self.tfManager = tfManager
        self.endpoint = endpoint
        self.localStorageManager = localStorageManager
        self.networkManager = networkManager
        tfManager.delegate = self
    }
    
    // MARK: - Methods
    func setUp() {
    }
    
    func performContainersListScreen() {
        if let localStorageManager, let networkManager {
            router?.showContainersList(storageManager: localStorageManager, networkManager: networkManager)
        }
    }
    
    func detect(pixelBuffer: CVPixelBuffer) {
        tfManager?.detect(pixelBuffer: pixelBuffer)
    }
}

    // MARK: - TFManagerDelegateProtocol
extension ScanPresenter: TFManagerDelegateProtocol {
    func drawAfterPerformingCalculations(onDetections detections: [Detection],
                                         withImageSize imageSize: CGSize,
                                         pixelBuffer: CVPixelBuffer) {
        
        delegate?.cleanOverlays()
        
        guard !detections.isEmpty,
              let viewBoundsRect = delegate?.view.bounds else { return }
        var objectOverlays: [ObjectOverlay] = []
        objectOverlays = DetectionProcessorHelper()
            .processDetections(detections, imageSize: imageSize, viewBoundsRect: viewBoundsRect)
        delegate?.drawOverlays(objectOverlays: objectOverlays)
        
        let boundingBoxModel = ContainerBoundingBoxModel(models: objectOverlays)
        

        Task {
            let recognisedTextPairs = await getRecognisedTexts(boundingBoxModel: boundingBoxModel,
                                                               pixelBuffer: pixelBuffer,
                                                               viewBoundsRect: viewBoundsRect)
            
            Task { @MainActor in
                guard recognisedTextPairs.count > 0 else { return }
                if let result = validator.handleResults(mainNumber: recognisedTextPairs.first,
                                                        partialNumber: recognisedTextPairs.last) {
                    delegate?.setLabel(text: result.1, rightCheckDigit: result.2)
                    delegate?.setImage(image: result.0)
                    
                    var type: ScannedModelType = .NONE
                    if let mainBox = boundingBoxModel.mainBox {
                        if mainBox.name.contains("vertical") {
                            type = .VERTICAL
                        } else if mainBox.name.contains("horizontal") {
                            type = .HORIZONTAL
                        } else {
                            type = .NONE
                        }
                    }
                    
                    var imageData: Data?
                    switch type {
                    case .NONE:
                        imageData = result.0.pngData()
                    case .HORIZONTAL, .VERTICAL:
                        imageData = boundingBoxCalculator.getBoundingBoxImage(cropRect: boundingBoxModel.mainBox!.borderRect,
                                                                              viewBoundsRect: viewBoundsRect,
                                                                              pixelBuffer: pixelBuffer)?.pngData()
                    }
                    
                    saveContainer(serialNumber: result.1,
                                  isScannedSuccessfully: result.2,
                                  image: imageData,
                                  pixelBuffer: pixelBuffer,
                                  scannedType: type)
                }
            }
        }
    }
    
    private func getRecognisedTexts(boundingBoxModel: ContainerBoundingBoxModel,
                                    pixelBuffer: CVPixelBuffer,
                                    viewBoundsRect: CGRect) async -> [ProcessedImageResult] {
        return await withTaskGroup(of: Optional<ProcessedImageResult>.self,
                                   returning: [ProcessedImageResult].self) { [weak self] group in
            guard let self else { return [] }
            group.addTask {
                return await self.getRecognisedTextForImage(boundingBoxModel: boundingBoxModel,
                                                            pixelBuffer: pixelBuffer,
                                                            viewBoundsRect: viewBoundsRect)
            }
            group.addTask {
                return await self.getRecognisedTextForImages(boundingBoxModel: boundingBoxModel,
                                                             pixelBuffer: pixelBuffer,
                                                             viewBoundsRect: viewBoundsRect)
            }
            return await group
                .compactMap { $0 }
                .reduce(into: [], { $0.append($1) })
        }
    }
    
    private func getRecognisedTextForImage(boundingBoxModel: ContainerBoundingBoxModel,
                                           pixelBuffer: CVPixelBuffer,
                                           viewBoundsRect: CGRect) async -> ProcessedImageResult? {
        
        guard let mainBox = boundingBoxModel.mainBox,
              let image = boundingBoxCalculator.getBoundingBoxImage(cropRect: mainBox.borderRect,
                                                                    viewBoundsRect: viewBoundsRect,
                                                                    pixelBuffer: pixelBuffer) else { return nil }
        
        return await imageToTextProcessor.process(image: image)
    }
    
    private func getRecognisedTextForImages(boundingBoxModel: ContainerBoundingBoxModel,
                                            pixelBuffer: CVPixelBuffer,
                                            viewBoundsRect: CGRect) async -> ProcessedImageResult? {
        
        var images: [UIImage] = []
        for box in boundingBoxModel.partialImageBoxes {
            guard let image = boundingBoxCalculator.getBoundingBoxImage(
                cropRect: box.borderRect,
                viewBoundsRect: viewBoundsRect,
                pixelBuffer: pixelBuffer) else { continue }
            images.append(image)
        }
        return await imageToTextProcessor.process(images: images)
    }
    
}


// MARK: - Send&Save containers
extension ScanPresenter {
    private func saveContainer(serialNumber: String,
                               isScannedSuccessfully: Bool,
                               image: Data?,
                               pixelBuffer: CVPixelBuffer,
                               scannedType: ScannedModelType) {
        
        let title = String(serialNumber.prefix(11))
        var sizeCode: String?
        serialNumber.count > 11 ? (sizeCode = String(serialNumber.suffix(4))) : (sizeCode = nil)
        
        // Convert pixelBuffer to CIImage
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(ciImage, from: CGRect(x: 0,
                                                                     y: 0,
                                                                     width: CVPixelBufferGetWidth(pixelBuffer),
                                                                     height: CVPixelBufferGetHeight(pixelBuffer))),
           let fullImage = UIImage(cgImage: cgImage).pngData(),
           let image {
            
            var container = ScannedContainerModel(
                title: title,
                detectedTime: Date(),
                isScannedSuccessfully: isScannedSuccessfully,
                latitude: 0.1,
                longitude: 42.1,
                isSentToServer: false,
                image: image,
                scannedType: scannedType,
                fullImage: fullImage,
                sizeCodeStr: sizeCode)
            
            networkManager?.upload(RequestScannedObjectDto(from: container)) { result in
                container.isSentToServer = result
                self.localStorageManager?.saveContainer(model: container) { result in
                    print("save: \(result)")
                }
            }
        } else {
            print("error can't save")
        }
    }
}
