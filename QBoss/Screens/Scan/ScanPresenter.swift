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
    private var localStorageManager: ContainerStoreProtocol?
    
    // MARK: - Initialization
    init(delegate: ScanViewControllerDelegate, router: ScanRouterSpec,
         tfManager: TFManager, endpoint: String,
         localStorageManager: ContainerStoreProtocol) {
        self.delegate = delegate
        self.router = router
        self.tfManager = tfManager
        self.endpoint = endpoint
        self.localStorageManager = localStorageManager
        tfManager.delegate = self
    }
    
    // MARK: - Methods
    func setUp() {
    }
    
    func performContainersListScreen() {
        if let localStorageManager {
            router?.showContainersList(storageManager: localStorageManager)
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
        guard !detections.isEmpty, let viewBoundsRect = delegate?.view.bounds else {
            return
        }
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
                if let result = validator.handleResults(mainNumber: recognisedTextPairs.first, partialNumber: recognisedTextPairs.last) {
                    delegate?.setLabel(text: result.1, rightCheckDigit: result.2)
                    delegate?.setImage(image: result.0)
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
            return await group.compactMap { $0 }.reduce(into: [], { $0.append($1) })
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
            guard let image = boundingBoxCalculator.getBoundingBoxImage(cropRect: box.borderRect,
                                                                        viewBoundsRect: viewBoundsRect,
                                                                        pixelBuffer: pixelBuffer) else { continue }
            images.append(image)
        }
        return await imageToTextProcessor.process(images: images)
    }
}
