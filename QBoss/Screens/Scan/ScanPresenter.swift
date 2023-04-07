import Foundation
import TensorFlowLiteTaskVision

final class ScanPresenter: ScanPresenterProtocol {
    
    
    // MARK: - Properties
    weak var delegate: ScanViewControllerDelegate?
    var tfManager: TFManager?
    let imageToTextProcessor: ImageToTextProcessor = .init()
    
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
    private var viewBoundsRect: CGRect = CGRect() // TODO: не придумал как его передавать
    func setUp(viewBoundsRect: CGRect) {
        self.viewBoundsRect = viewBoundsRect
    }
    
    func performContainersListScreen() {
        router?.showContainersList()
    }

    func detect(pixelBuffer: CVPixelBuffer) {
        tfManager?.detect(pixelBuffer: pixelBuffer)
        //self.viewBoundsRect = viewBoundsRect
    }
    
    // MARK: - Private Methods
    private func recognizeText(image: UIImage) {
        Task {
            //var images: [UIImage] = []
//            for result in results {
//                guard let image = try? await getImageFromResult(result) else { continue }
//                images.append(image)
//            }

            //guard let image = try? await getImageFromResult(image) else { continue }
            do {
                let result = try await imageToTextProcessor.process(image: image)
                DispatchQueue.main.async { [weak self] in
                    //self?.imageView.image = result.0
                    //self?.numberLabel.text = result.1
                    print(result.1)
                }
            } catch {
                print("Error processing images or recognizing text: \(error)")
            }
        }
    }
}


// MARK: - TFManagerDelegateProtocol
extension ScanPresenter: TFManagerDelegateProtocol {
    
    func drawAfterPerformingCalculations(onDetections detections: [Detection], withImageSize imageSize: CGSize, pixelBuffer: CVPixelBuffer) {
        
        delegate?.cleanOverlays()
        
        guard !detections.isEmpty else {
            return
        }
        var objectOverlays: [ObjectOverlay] = []
        
        objectOverlays = DetectionProcessorHelper()
            .processDetections(detections, imageSize: imageSize, viewBoundsRect: viewBoundsRect)
        delegate?.drawOverlays(objectOverlays: objectOverlays)
        
        
        let verticalEl = objectOverlays.filter{ $0.name.contains("vertical") }.first
        let horizontalEl = objectOverlays.filter{ $0.name.contains("horizontal") }.first
        if let el = verticalEl ?? horizontalEl,
           let image = BoundingBoxCalculator()
            .getBoundingBoxImage(cropRect: el.borderRect,
                                 viewBoundsRect: viewBoundsRect,
                                 pixelBuffer: pixelBuffer) {
            delegate?.setImage(image: image)
            recognizeText(image: image)
        }
    }
}
