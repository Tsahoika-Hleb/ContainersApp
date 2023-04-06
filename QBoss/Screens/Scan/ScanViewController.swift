import UIKit
//import TensorFlowLiteTaskVision

private enum LayoutConstants {
    static let topBottomInset: CGFloat = 0
    static let leadingTrailingInset: CGFloat = 0
    static let containerImageViewSize: CGSize = CGSize(width: 50, height: 50)
    static let serialNumberLabelSize: CGSize = CGSize(width: 200, height: 60)
    static let containerImageViewInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
    static let serialNumberLabelInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 20)
}

final class ScanViewController: UIViewController {
    
    // MARK: - Properties
    var presenter: ScanPresenterProtocol?
//    var tfManager: TFManager?
    private lazy var cameraFeedManager = CameraFeedManager(previewView: previewView) // TODO: Как привильно перенесть в presenter?
    private let inferenceQueue = DispatchQueue(label: "inferencequeue")
    private var isInferenceQueueBusy = false
    
    private lazy var overlayView: OverlayView = {
        let view = OverlayView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var lastFrameImageView: UIImageView = {
       var imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var previewView: PreviewView = {
        let view = PreviewView()
        view.contentMode = .scaleToFill
        view.autoresizesSubviews = true
        return view
    }()
    
    private lazy var containersListImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage.listBullet)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.tintColor = .white
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
        return imageView
    }()
    
    private lazy var serialNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        label.textAlignment = .right
        label.text = "ABCU 123567" // TODO: REMOVE IN THE FUTURE
        return label
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraFeedManager.delegate = self
        //tfManager?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraFeedManager.checkCameraConfigurationAndStartSession()
        presenter?.setUp(viewBoundsRect: view.bounds)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setViews()
        setConstraints()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraFeedManager.stopSession()
    }
    
    // MARK: - Private Methods
    private func setViews() {
        view.addSubview(previewView)
        view.addSubview(serialNumberLabel)
        view.addSubview(overlayView)
        view.addSubview(lastFrameImageView)
        view.addSubview(containersListImageView)
    }
    
    private func setConstraints() {
        previewView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
                .inset(UIEdgeInsets(top: LayoutConstants.topBottomInset,
                                    left: LayoutConstants.leadingTrailingInset,
                                    bottom: LayoutConstants.topBottomInset,
                                    right: LayoutConstants.leadingTrailingInset))
        }
        
        containersListImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.trailing.equalToSuperview().inset(LayoutConstants.containerImageViewInsets.right)
            make.width.height.equalTo(LayoutConstants.containerImageViewSize.width)
        }
        
        serialNumberLabel.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin).inset(LayoutConstants.serialNumberLabelInsets.bottom)
            make.trailing.equalToSuperview().inset(LayoutConstants.serialNumberLabelInsets.right)
            make.height.equalTo(LayoutConstants.serialNumberLabelSize.height)
            make.width.equalTo(LayoutConstants.serialNumberLabelSize.width)
        }
        
        overlayView.snp.makeConstraints { make in
            make.top.trailing.leading.bottom.equalToSuperview()
        }
        
        lastFrameImageView.snp.makeConstraints { make in
            make.bottom.leading.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(200)
        }
    }
    
    // MARK: - Actions
    @objc private func imageTapped() {
        presenter?.performContainersListScreen()
    }
}


// MARK: CameraFeedManagerDelegate Methods
extension ScanViewController: CameraFeedManagerDelegate {
    
    func didOutput(pixelBuffer: CVPixelBuffer) {
        guard !self.isInferenceQueueBusy else { return }
    
        inferenceQueue.async {
            self.isInferenceQueueBusy = true
            //self.tfManager?.detect(pixelBuffer: pixelBuffer)
            self.presenter?.detect(pixelBuffer: pixelBuffer)
            self.isInferenceQueueBusy = false
        }
    }
    
    func presentCameraPermissionsDeniedAlert() {
        let alertController = UIAlertController(
            title: S.Screens.Scan.CameraPermissionDenied.allertTitle,
            message: S.Screens.Scan.CameraPermissionDenied.allertMessage,
            preferredStyle: .alert)

        let cancelAction = UIAlertAction.cancelAction
        let settingsAction = UIAlertAction.settingAction

        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)

        present(alertController, animated: true, completion: nil)
    }
    
    func presentVideoConfigurationErrorAlert() {
        let alertController = UIAlertController(
            title: S.Screens.Scan.PresentVideoError.allertTitle,
            message: S.Screens.Scan.PresentVideoError.allertMessage,
            preferredStyle: .alert)
        let okAction = UIAlertAction.okAction
        alertController.addAction(okAction)

        present(alertController, animated: true, completion: nil)
    }
    
    func sessionRunTimeErrorOccurred() {
        
    }
    
    func sessionWasInterrupted(canResumeManually resumeManually: Bool) {
        
    }
    
    func sessionInterruptionEnded() {
        
    }
}


// MARK: - ScanViewControllerDelegate
extension ScanViewController: ScanViewControllerDelegate {
    func cleanOverlays() {
        overlayView.objectOverlays = []
        overlayView.setNeedsDisplay()
        lastFrameImageView.image = nil
    }
    
    func drawOverlays(objectOverlays: [ObjectOverlay]) {
        overlayView.objectOverlays = objectOverlays
        overlayView.setNeedsDisplay()
    }
    
    func setImage(image: UIImage) {
        lastFrameImageView.image = image
        //await print(TextRecognitionHelper().recognizeText(in: image) ?? "NOTHING")
    }
    
}


//// MARK: - TFManagerDelegate
//extension ScanViewController: TFManagerDelegateProtocol {
//    func drawAfterPerformingCalculations(onDetections detections: [Detection],
//                                         withImageSize imageSize: CGSize,
//                                         pixelBuffer: CVPixelBuffer) {
//        guard let presenter = presenter else {
//            fatalError("No presenter")
//        }
//
//        overlayView.objectOverlays = []
//        overlayView.setNeedsDisplay()
//
//        guard !detections.isEmpty else {
//            return
//        }
//        var objectOverlays: [ObjectOverlay] = []
//
//        objectOverlays = DetectionProcessorHelper()
//            .processDetections(detections, imageSize: imageSize, viewBoundsRect: overlayView.bounds)
//
//        let verticalEl = objectOverlays.filter{ $0.name.contains("vertical") }.first
//        let horizontalEl = objectOverlays.filter{ $0.name.contains("horizontal") }.first
//        if let el = verticalEl {
//            lastFrameImageView.image = BoundingBoxCalculator()
//                .getBoundingBoxImage(cropRect: el.borderRect,
//                                     viewBoundsRect: overlayView.frame,
//                                     pixelBuffer: pixelBuffer)
//        }
//
//        overlayView.objectOverlays = //presenter?.handleDetections(onDetections: detections, withImageSize: imageSize, pixelBuffer: pixelBuffer)
//        overlayView.setNeedsDisplay()
//    }
//}
