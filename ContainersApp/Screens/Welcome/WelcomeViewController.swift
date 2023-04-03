import UIKit
import SnapKit
import IQKeyboardManagerSwift

final class WelcomeViewController: UIViewController {
    
    // MARK: - Properties
    var presenter: WelcomePresenterProtocol?
    
    private lazy var endpointsTextField: EndpointsTextField = {
        let view = EndpointsTextField()
        
        view.endpointsCount = { [weak presenter] in
            guard let presenter = presenter else {
                fatalError("No presenter")
            }
            return presenter.endpointsCount
        }
        view.endpointForRow = { [weak presenter] row in
            guard let presenter = presenter else {
                fatalError("No presenter")
            }
            return presenter.endpoint(for: row)
        }
        view.addEndpoint = { [weak presenter] endpoint in
            presenter?.addEndpoint(endpoint)
        }
        
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
        //presenter?.locationRequest()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureSubviews()
    }
    
    // MARK: - Private Methods
    private func configureSubviews() {
        view.addSubview(topSafeAreaView)
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(instructionsLabel)
        view.addSubview(scanButton)
        view.addSubview(endpointsTextField)
        
        let kTopInset: CGFloat = 16
        let kSideInset: CGFloat = 16
        let kTextFieldHeight: CGFloat = 44
        let kButtonHeight: CGFloat = 40
        let kImageViewHeightMultiplier: CGFloat = 0.4

        topSafeAreaView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top)
        }

        imageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(kImageViewHeightMultiplier)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(kTopInset)
            make.left.right.equalToSuperview().inset(kSideInset)
        }

        instructionsLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(kTopInset)
            make.left.right.equalToSuperview().inset(kSideInset)
        }

        endpointsTextField.snp.makeConstraints { make in
            make.top.equalTo(instructionsLabel.snp.bottom).offset(kTopInset / 2)
            make.leading.trailing.equalToSuperview().inset(kSideInset)
            make.height.equalTo(kTextFieldHeight)
        }
        endpointsTextField.updateTableView()

        scanButton.snp.makeConstraints { make in
            make.top.equalTo(endpointsTextField.snp.bottom).offset(kTopInset)
            make.left.right.equalToSuperview().inset(kSideInset)
            make.height.equalTo(kButtonHeight)
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

