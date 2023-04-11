import Foundation
import TensorFlowLiteTaskVision

final class ScanPresenter: ScanPresenterProtocol {
    
    // MARK: - Properties
    weak var delegate: ScanViewControllerDelegate?
    var tfManager: TFManager?
    let imageToTextProcessor: ImageToTextProcessor = .init()
    
    let boundingBoxCalculator = BoundingBoxCalculator()
    
    // MARK: - Private Properties
    internal var router: ScanRouterSpec?
    private var endpoint: String
    private let defaults = UserDefaults.standard
    
    // MARK: - Initialization
    init(delegate: ScanViewControllerDelegate, router: ScanRouterSpec, tfManager: TFManager, endpoint: String) {
        self.delegate = delegate
        self.router = router
        self.tfManager = tfManager
        self.endpoint = endpoint
        tfManager.delegate = self
        print(endpoint)
    }
    
    // MARK: - Methods
    func setUp() {
        
    }
    
    func performContainersListScreen() {
        router?.showContainersList()
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
            let recognisedTextPair = await getRecognisedTextForImage(boundingBoxModel: boundingBoxModel,
                                                           pixelBuffer: pixelBuffer,
                                                           viewBoundsRect: viewBoundsRect)
            Task() { @MainActor in
                // Check 1 длинна >= 10
                
                // Модификация убираешь лишние символы, отсавляешь только буквы и цифры.
                // Добавляешь чек диджит если пропущен
                // заменяешь символы если они где-то не должны быть
                // при модификации если больше 11 но меньше 15 то берешь суффикс 11
                // если больше 15 то берешь суфикс 15
                if let text = recognisedTextPair?.1, let image = recognisedTextPair?.0, (10...15).contains(text.count) {
                    delegate?.setLabel(text: text, rightCheckDigit: text.validateCheckDigit())
                    delegate?.setImage(image: image)
                }
            }
        }
    }
    
    private func getRecognisedTextForImage(boundingBoxModel: ContainerBoundingBoxModel, pixelBuffer: CVPixelBuffer, viewBoundsRect: CGRect) async -> ProcessedImageResult? {
        guard let mainBox = boundingBoxModel.mainBox,
              let image = self.boundingBoxCalculator.getBoundingBoxImage(
                cropRect: mainBox.borderRect, viewBoundsRect: viewBoundsRect,
                pixelBuffer: pixelBuffer) else { return nil }
        return try? await self.process([image])
    }
    
    private func getRecognisedTextForImages(boundingBoxModel: ContainerBoundingBoxModel, pixelBuffer: CVPixelBuffer, viewBoundsRect: CGRect) async -> ProcessedImageResult? {
        var images: [UIImage] = []
        for box in boundingBoxModel.partialImageBoxes {
            guard let image = self.boundingBoxCalculator.getBoundingBoxImage( cropRect: box.borderRect,
                                                                         viewBoundsRect: viewBoundsRect,
                                                                         pixelBuffer: pixelBuffer) else { continue }
            images.append(image)
        }

        return try? await self.process(images)
    }
    
    //TODO: - add multiple image handling
    private func getRecognisedTexts(boundingBoxModel: ContainerBoundingBoxModel, pixelBuffer: CVPixelBuffer, viewBoundsRect: CGRect) async -> [ProcessedImageResult] {
        return await withTaskGroup(of: Optional<ProcessedImageResult>.self, returning: [ProcessedImageResult].self) { [weak self] group in
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
    
    private func process(_ images: [UIImage]) async throws -> ProcessedImageResult {
        try await imageToTextProcessor.process(images: images)
    }
}
