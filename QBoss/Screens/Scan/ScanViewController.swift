import UIKit
import TensorFlowLiteTaskVision

private enum LayoutConstants {
    static let topBottomInset: CGFloat = 0
    static let leadingTrailingInset: CGFloat = 0
    static let containerImageViewSize: CGSize = CGSize(width: 50, height: 50)
    static let serialNumberLabelSize: CGSize = CGSize(width: 200, height: 60)
    static let containerImageViewInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
    static let serialNumberLabelInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 20)
}

final class ScanViewController: UIViewController {
    
    private lazy var lastFrameImage: UIImageView = {
       var imageView = UIImageView()
        imageView.backgroundColor = .clear
        //imageView.image = I.welcomeScreenImage.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let colors = [
      UIColor.red,
      UIColor(displayP3Red: 90.0 / 255.0, green: 200.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0),
      UIColor.green,
      UIColor.orange,
      UIColor.blue,
      UIColor.purple,
      UIColor.magenta,
      UIColor.yellow,
      UIColor.cyan,
      UIColor.brown,
    ]
    
    private lazy var overlayView: OverlayView = {
        let view = OverlayView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let inferenceQueue = DispatchQueue(label: "inferencequeue")
    private var isInferenceQueueBusy = false
    
    // MARK: - Properties
    var presenter: ScanPresenterProtocol?
    var tfManager: TFManager?
    
    private lazy var previewView: PreviewView = {
        let view = PreviewView()
        view.contentMode = .scaleToFill
        //view.backgroundColor = .green
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
    
    private lazy var cameraFeedManager = CameraFeedManager(previewView: previewView)
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraFeedManager.delegate = self
        tfManager?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraFeedManager.checkCameraConfigurationAndStartSession()  // TODO: to presenter
        presenter?.setUp()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setViews()
        setConstraints()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraFeedManager.stopSession()  // TODO: to presenter
    }
    
    // MARK: - Private Methods
    private func setViews() {
        view.addSubview(previewView)
        view.addSubview(serialNumberLabel)
        view.addSubview(overlayView)
        view.addSubview(lastFrameImage)
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
        
        lastFrameImage.snp.makeConstraints { make in
            make.bottom.leading.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(200)
        }
    }
    
    // MARK: - Actions
    @objc private func imageTapped() {
        presenter?.performContainersList()
    }
}


// MARK: CameraFeedManagerDelegate Methods
extension ScanViewController: CameraFeedManagerDelegate {
    
    func didOutput(pixelBuffer: CVPixelBuffer) {
        guard !self.isInferenceQueueBusy else { return }
    
        inferenceQueue.async {
            self.isInferenceQueueBusy = true
            self.tfManager?.detect(pixelBuffer: pixelBuffer)
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


extension ScanViewController: ScanViewControllerDelegate {
}


// MARK: - TFManagerDelegate
extension ScanViewController: TFManagerDelegateProtocol {
    
    func drawAfterPerformingCalculations(onDetections detections: [Detection],
                                         withImageSize imageSize: CGSize,
                                         pixelBuffer: CVPixelBuffer) {
        
        overlayView.objectOverlays = []
        overlayView.setNeedsDisplay()
        
        guard !detections.isEmpty else {
            return
        }
        //print("Detections isn't empty")
        
        var objectOverlays: [ObjectOverlay] = []
        
        for detection in detections {
            
            guard let category = detection.categories.first else { continue }

            let calculator = BoundingBoxCalculator()
            let rect = calculator
                .createBoundingBox(convertedRect: detection.boundingBox.applying(
                    CGAffineTransform( scaleX: overlayView.bounds.size.width / imageSize.width,
                                       y: overlayView.bounds.size.height / imageSize.height)),
                                   viewBounds: overlayView.bounds)
            
            let objectDescription = String(
                format: "\(category.label ?? "Unknown") (%.2f)",
                category.score)
            
            let displayColor = colors[category.index % colors.count]
            
            let size = objectDescription.size(withAttributes: [.font: UIFont.displayFont])
            
            let objectOverlay = ObjectOverlay(
                name: objectDescription, borderRect: rect, nameStringSize: size,
                color: displayColor,
                font: UIFont.displayFont)
            
            objectOverlays.append(objectOverlay)
            if objectDescription.contains("vertical") || objectDescription.contains("horizontal") {
                lastFrameImage.image = calculator.getBoundingBoxImage(cropRect: rect,
                                                                      viewBoundsRect: previewView.bounds,
                                                                      pixelBuffer: pixelBuffer)
            }
        }
        
        // Hands off drawing to the OverlayView
        overlayView.objectOverlays = objectOverlays
        overlayView.setNeedsDisplay()
    }
    
    
}
