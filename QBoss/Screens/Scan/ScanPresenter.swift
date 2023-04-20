import Foundation
import TensorFlowLiteTaskVision

final class ScanPresenter: ScanPresenterProtocol {
    // MARK: - Properties

    var router: ScanRouterSpec?
    weak var delegate: ScanViewControllerDelegate?
    
    // MARK: - Private Properties

    private var tfManager: TFManager?
    private let imageToTextProcessor: ImageToTextProcessor = .init()
    private let boundingBoxCalculator = BoundingBoxCalculator()
    private let validator = CISValidator()
    private var dataUpdateHelper: DataUpdateHelper
    private lazy var detectionProcessorHelper: DetectionProcessorHelper = .init()
    private let locationManager = LocationManager()
    
    // MARK: - Initialization
    init(delegate: ScanViewControllerDelegate, router: ScanRouterSpec,
         tfManager: TFManager, dataUpdateHelper: DataUpdateHelper) {
        self.delegate = delegate
        self.router = router
        self.tfManager = tfManager
        self.dataUpdateHelper = dataUpdateHelper
        tfManager.delegate = self
    }
    
    // MARK: - Methods
    func performContainersListScreen() {
        router?.showContainersList(dataUpdateHelper: dataUpdateHelper)
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
        guard !detections.isEmpty, let viewBoundsRect = delegate?.view.bounds else { return }

        let objectOverlays = detectionProcessorHelper.processDetections(detections,
                                                                        imageSize: imageSize,
                                                                        viewBoundsRect: viewBoundsRect)
        delegate?.drawOverlays(objectOverlays: objectOverlays)

        let boundingBoxModel = ContainerBoundingBoxModel(models: objectOverlays)
        Task {
            let recognisedTextPairs = await getRecognisedTexts(boundingBoxModel: boundingBoxModel,
                                                               pixelBuffer: pixelBuffer,
                                                               viewBoundsRect: viewBoundsRect,
                                                               isVertical: boundingBoxModel.getContainerOrientation() == .vertical)

            guard !recognisedTextPairs.isEmpty,
                    let result = validator.handleResults(mainNumber: recognisedTextPairs.first,
                                                       partialNumber: recognisedTextPairs.last) else { return }
            
            saveContainer(containerText: result.1,
                          isScannedSuccessfully: result.2,
                          image: result.0.jpegData(compressionQuality: 0.5),
                          pixelBuffer: pixelBuffer,
                          scannedType: boundingBoxModel.getContainerOrientation())

            Task { @MainActor in
                delegate?.setLabel(text: result.1, rightCheckDigit: result.2)
                delegate?.setImage(image: result.0)
            }
        }
    }

    private func getRecognisedTexts(boundingBoxModel: ContainerBoundingBoxModel,
                                    pixelBuffer: CVPixelBuffer,
                                    viewBoundsRect: CGRect,
                                    isVertical: Bool) async -> [ProcessedImageResult] {
        return await withTaskGroup(of: Optional<ProcessedImageResult>.self,
                                   returning: [ProcessedImageResult].self) { [weak self] group in
            guard let self else { return [] }
            group.addTask {
                return await self.getRecognisedTextForImage(boundingBoxModel: boundingBoxModel,
                                                            pixelBuffer: pixelBuffer,
                                                            viewBoundsRect: viewBoundsRect,
                                                            isVertical: isVertical)
            }
            group.addTask {
                return await self.getRecognisedTextForImages(boundingBoxModel: boundingBoxModel,
                                                             pixelBuffer: pixelBuffer,
                                                             viewBoundsRect: viewBoundsRect,
                                                             isVertical: isVertical)
            }
            return await group.compactMap { $0 }.reduce(into: [], { $0.append($1) })
        }
    }

    private func getRecognisedTextForImage(boundingBoxModel: ContainerBoundingBoxModel,
                                           pixelBuffer: CVPixelBuffer,
                                           viewBoundsRect: CGRect,
                                           isVertical: Bool) async -> ProcessedImageResult? {

        guard let mainBox = boundingBoxModel.mainBox,
              let image = boundingBoxCalculator.getBoundingBoxImage(cropRect: mainBox.borderRect,
                                                                    viewBoundsRect: viewBoundsRect,
                                                                    pixelBuffer: pixelBuffer) else { return nil }

        return await imageToTextProcessor.process(image: image)
    }

    private func getRecognisedTextForImages(boundingBoxModel: ContainerBoundingBoxModel,
                                            pixelBuffer: CVPixelBuffer,
                                            viewBoundsRect: CGRect,
                                            isVertical: Bool) async -> ProcessedImageResult? {

        var images: [UIImage] = []
        for box in boundingBoxModel.partialImageBoxes {
            guard let image = boundingBoxCalculator.getBoundingBoxImage(
                cropRect: box.borderRect,
                viewBoundsRect: viewBoundsRect,
                pixelBuffer: pixelBuffer) else { continue }
            images.append(image)
        }
        return await imageToTextProcessor.process(images: images, isVertical: isVertical)
    }
}

// MARK: - Send&Save containers
extension ScanPresenter {
    private func saveContainer(containerText: String,
                               isScannedSuccessfully: Bool,
                               image: Data?,
                               pixelBuffer: CVPixelBuffer,
                               scannedType: ContainerOrientationType) {
        let title = String(containerText.prefix(11))
        let sizeCode: String? = containerText.count > 11 ? String(containerText.suffix(4)) : nil
        
        guard let imageData = pixelBuffer.getImage()?.jpegData(compressionQuality: 0.5), let image else { return }
        
        let container = ScannedContainerModel(
            title: title,
            detectedTime: Date(),
            isScannedSuccessfully: isScannedSuccessfully,
            latitude: locationManager.currentLocation?.coordinate.latitude ?? 0,
            longitude: locationManager.currentLocation?.coordinate.longitude ?? 0,
            isSentToServer: false,
            image: image,
            scannedType: scannedType,
            fullImage: imageData,
            sizeCodeStr: sizeCode)
        
        self.dataUpdateHelper.saveContainer(container)
    }
}
