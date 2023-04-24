import UIKit
import SnapKit
import IQKeyboardManagerSwift

protocol WelcomeViewControllerDelegate: UIViewController {
}

private enum LayoutConstants {
    static let topInset: CGFloat = 16
    static let sideInset: CGFloat = 16
    static let textFieldHeight: CGFloat = 44
    static let buttonHeight: CGFloat = 40
    static let imageViewHeightMultiplier: CGFloat = 0.4
    static let cornerRadius: CGFloat = 8
}

private enum AnimationConstants {
    static let animationDuration: TimeInterval = 0.2
    static let scaleFactor: CGFloat = 0.95
    static let initialAlpha: CGFloat = 1.0
    static let highlightedAlpha: CGFloat = 0.8
}

final class WelcomeViewController: UIViewController, WelcomeViewControllerDelegate {
    
    // MARK: - Properties
    var presenter: WelcomePresenterProtocol?
    
    private lazy var endpointsTextField: EndpointsTextField = {
        let view = EndpointsTextField()
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
        label.font = UIFont.boldSystemFont20
        label.textColor = .black
        label.text = S.Screens.Welcome.title
        label.textAlignment = .center
        return label
    }()
    
    private lazy var instructionsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont16
        label.textColor = .gray
        label.text = S.Screens.Welcome.instructionsLabelText
        label.textAlignment = .center
        return label
    }()
    
    private lazy var scanButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(S.Screens.Welcome.scanButtonTitle, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = LayoutConstants.cornerRadius
        button.addTarget(self, action: #selector(scanButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var containersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(S.Screens.Welcome.containersButtonTitle, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = LayoutConstants.cornerRadius
        button.addTarget(self, action: #selector(containersButtonTapped), for: .touchUpInside)
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
        view.addSubview(containersButton)
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
        
        containersButton.snp.makeConstraints { make in
            make.top.equalTo(scanButton.snp.bottom).offset(LayoutConstants.topInset)
            make.left.right.equalToSuperview().inset(LayoutConstants.sideInset)
            make.height.equalTo(LayoutConstants.buttonHeight)
        }
        
    }
    
    private func buttonAnimation(button: UIButton) {
        UIView.animate(withDuration: AnimationConstants.animationDuration, animations: {
            button.transform = CGAffineTransform(scaleX: AnimationConstants.scaleFactor, y: AnimationConstants.scaleFactor)
            button.alpha = AnimationConstants.highlightedAlpha
        }, completion: { _ in
            UIView.animate(withDuration: AnimationConstants.animationDuration, animations: {
                button.transform = CGAffineTransform.identity
                button.alpha = AnimationConstants.initialAlpha
            })
        })
    }
    
    // MARK: - Actions
    @objc private func scanButtonTapped(sender: UIButton!) {
        buttonAnimation(button: sender)
        
        presenter?.startScanning(urlEstablished: endpointsTextField.isUrlEstablished())
    }
    
    @objc private func containersButtonTapped(sender: UIButton!) {
        buttonAnimation(button: sender)
        
        presenter?.showContainers()
    }
}
