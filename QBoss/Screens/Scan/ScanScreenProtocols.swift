import UIKit

// MARK: - Presenter
protocol ScanPresenterProtocol: AnyObject {
    var delegate: ScanViewControllerDelegate? { get set }
    var router: ScanRouterSpec? { get set }
    
    func setUp(viewBoundsRect: CGRect)
    func performContainersListScreen()
    func detect(pixelBuffer: CVPixelBuffer)
//    func handleDetections(onDetections detections: [Detection],
//                          withImageSize imageSize: CGSize,
//                          viewBoundsRect: CGRect,
//                          pixelBuffer: CVPixelBuffer)
}

// MARK: - ViewController
protocol ScanViewControllerDelegate: UIViewController {
    func setImage(image: UIImage)
    func drawOverlays(objectOverlays: [ObjectOverlay])
    func cleanOverlays()
}
