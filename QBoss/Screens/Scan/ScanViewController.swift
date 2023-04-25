import UIKit

private enum LayoutConstants {
    static let topBottomInset: CGFloat = 0
    static let leadingTrailingInset: CGFloat = 0
    static let containerImageViewSize: CGSize = CGSize(width: 50, height: 50)
    static let insent10: CGFloat = 10
    static let serialNumberLabelSize: CGSize = CGSize(width: 200, height: 60)
    static let containerImageViewInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
    static let serialNumberLabelInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 20)
}

final class ScanViewController: UIViewController {
    
    // MARK: - Properties
    var presenter: ScanPresenterProtocol?
    
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
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textColor = .white
        label.textAlignment = .left
        label.backgroundColor = .black
        label.text = ""
        return label
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.setUp(previewView: previewView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.checkCameraConfiguration()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setViews()
        setConstraints()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter?.stopSession()
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
        
        overlayView.snp.makeConstraints { make in
            make.top.trailing.leading.bottom.equalToSuperview()
        }
        
        lastFrameImageView.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(LayoutConstants.insent10)
            make.bottom.equalTo(serialNumberLabel.snp.top)
            make.width.lessThanOrEqualToSuperview().inset(LayoutConstants.insent10)
        }
        
        serialNumberLabel.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview().inset(LayoutConstants.insent10)
        }
    }
    
    // MARK: - Actions
    @objc private func imageTapped() {
        presenter?.performContainersListScreen()
    }
}

// MARK: - ScanViewControllerDelegate
extension ScanViewController: ScanViewControllerDelegate {
    
    func setLabel(text: String, rightCheckDigit: Bool?) {
        serialNumberLabel.text = text
        
        if let rightCheckDigit = rightCheckDigit {
            rightCheckDigit ? (serialNumberLabel.textColor = .green) : (serialNumberLabel.textColor = .red)
        } else {
            serialNumberLabel.textColor = .white
        }
    }
    
    func cleanOverlays() {
        overlayView.objectOverlays = []
        overlayView.setNeedsDisplay()
    }
    
    func drawOverlays(objectOverlays: [ObjectOverlay]) {
        overlayView.objectOverlays = objectOverlays
        overlayView.setNeedsDisplay()
    }
    
    func setImage(image: UIImage) {
        lastFrameImageView.image = image
    }
}
