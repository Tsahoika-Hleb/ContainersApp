//

import UIKit
import SnapKit

class ScanViewController: UIViewController {
    
    // MARK: - Properties
    var presenter: ScanPresenterProtocol?
    private var alerts: [UIAlertController] = []
    
    private lazy var previewView: PreviewView = {
        let view = PreviewView()
        view.contentMode = .scaleToFill
        view.backgroundColor = .green
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
        configureSubviews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraFeedManager.stopSession()  // TODO: to presenter
    }
    
    // MARK: - Private Methods
    private func configureSubviews() {
        view.addSubview(previewView)
        view.addSubview(containersListImageView)
        view.addSubview(serialNumberLabel)
        
        previewView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        containersListImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.trailing.equalToSuperview().inset(20)
            make.width.height.equalTo(50)
        }
        
        serialNumberLabel.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(60)
            make.width.equalTo(200)
        }
    }
    
    // MARK: - Actions
    @objc func imageTapped() {
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

        let cancelAction = UIAlertAction(title: S.AlertAction.cancel, style: .cancel) { [self] (action) in
            if alerts.count == 2 {
                present(alerts[1], animated: true) //
                alerts.remove(at: 1)
            }
        }
        let settingsAction = UIAlertAction.settingAction

        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)

        if alerts.isEmpty { alerts.append(alertController) }
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
    
    func locationPermissionDenied() {
        
        let alertController = UIAlertController(
            title: S.Screens.Scan.LocationPermissionDenied.allertTitle,
            message: S.Screens.Scan.LocationPermissionDenied.allertMessage,
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction.cancelAction
        let settingsAction = UIAlertAction.settingAction
        
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        
        alerts.append(alertController)
        present(alertController, animated: true, completion: nil)
        
    }
}


