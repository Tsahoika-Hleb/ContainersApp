import UIKit
import SnapKit
import IQKeyboardManagerSwift

protocol WelcomeViewControllerDelegate: UIViewController {
    func urlValidation(isSuccesful: Bool)
    func showLastEndpoint(_ endpoint: String)
}

private enum LayoutConstants {
    static let topInset: CGFloat = 16
    static let sideInset: CGFloat = 16
    static let textFieldHeight: CGFloat = 44
    static let buttonHeight: CGFloat = 40
    static let imageViewHeightMultiplier: CGFloat = 0.4
}

final class WelcomeViewController: UIViewController {
    
    // MARK: - Properties
    var presenter: WelcomePresenterProtocol?
    
    private lazy var endpointsTextField: EndpointsTextField = {
        let view = EndpointsTextField()
        view.delegate = self
        return view
    }()
    
    private lazy var topSafeAreaView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = I.welcomeScreenImage.image
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        label.text = S.Screens.Welcome.title
        label.textAlignment = .center
        return label
    }()
    
    private lazy var instructionsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.text = S.Screens.Welcome.instructionsLabelText
        label.textAlignment = .center
        return label
    }()
    
    private lazy var scanButton: UIButton = {
        let button = UIButton()
        button.setTitle(S.Screens.Welcome.buttonTitle, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(scanButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        IQKeyboardManager.shared.enableAutoToolbar = false
        presenter?.setUpPresenter()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setViews()
        configureSubviews()
    }
    
    // MARK: - Private Methods
    private func setViews() {
        view.addSubview(topSafeAreaView)
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(instructionsLabel)
        view.addSubview(scanButton)
        view.addSubview(endpointsTextField)
    }
    
    private func configureSubviews() {
        topSafeAreaView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top)
        }

        imageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(LayoutConstants.imageViewHeightMultiplier)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(LayoutConstants.topInset)
            make.left.right.equalToSuperview().inset(LayoutConstants.sideInset)
        }

        instructionsLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(LayoutConstants.topInset)
            make.left.right.equalToSuperview().inset(LayoutConstants.sideInset)
        }

        endpointsTextField.snp.makeConstraints { make in
            make.top.equalTo(instructionsLabel.snp.bottom).offset(LayoutConstants.topInset / 2)
            make.leading.trailing.equalToSuperview().inset(LayoutConstants.sideInset)
            make.height.equalTo(LayoutConstants.textFieldHeight)
        }
        endpointsTextField.updateTableView()

        scanButton.snp.makeConstraints { make in
            make.top.equalTo(endpointsTextField.snp.bottom).offset(LayoutConstants.topInset)
            make.left.right.equalToSuperview().inset(LayoutConstants.sideInset)
            make.height.equalTo(LayoutConstants.buttonHeight)
        }
    }
    
    // MARK: - Actions
    @objc private func scanButtonTapped(sender: UIButton!) {
        let animationDuration: TimeInterval = 0.2
        let scaleFactor: CGFloat = 0.95
        let initialAlpha: CGFloat = 1.0
        let highlightedAlpha: CGFloat = 0.8

        UIView.animate(withDuration: animationDuration, animations: {
            sender.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
            sender.alpha = highlightedAlpha
        }, completion: { _ in
            UIView.animate(withDuration: animationDuration, animations: {
                sender.transform = CGAffineTransform.identity
                sender.alpha = initialAlpha
            })
        })
        
        if let url = endpointsTextField.getText() {
            presenter?.startScanning(url)
        }
    }
    
}


// MARK: - WelcomeViewControllerDelegate
extension WelcomeViewController: WelcomeViewControllerDelegate {
    
    func showLastEndpoint(_ endpoint: String) {
        endpointsTextField.setTextField(endpoint)
    }
    
    func urlValidation(isSuccesful: Bool) {
        endpointsTextField.urlValidationResult(isSuccesful)
    }
}


// MARK: - EndpointsTextFieldDelegate
extension WelcomeViewController: EndpointsTextFieldDelegate {
    
    func endpointsCount() -> Int {
        guard let presenter = presenter else {
            fatalError("No presenter")
        }
        return presenter.endpointsCount
    }
    
    func endpointForRow(rowIndex: Int) -> String? {
        guard let presenter = presenter else {
            fatalError("No presenter")
        }
        return presenter.endpoint(for: rowIndex)
        
    }
    
    func addEndpoint(_ endpoint: String) {
        presenter?.addEndpoint(endpoint)
    }
}
