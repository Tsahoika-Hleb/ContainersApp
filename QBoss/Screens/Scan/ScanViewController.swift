import UIKit

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
        view.addSubview(containersListImageView)
        view.addSubview(serialNumberLabel)
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
    }
    
    // MARK: - Actions
    @objc private func imageTapped() {
        presenter?.performContainersList()
    }
}


// MARK: CameraFeedManagerDelegate Methods
extension ScanViewController: CameraFeedManagerDelegate {
    
    func didOutput(pixelBuffer: CVPixelBuffer) {
        
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


