//

import UIKit
import SnapKit

final class WelcomeViewController: UIViewController {
    
    // MARK: - Properties
    var presenter: WelcomePresenterProtocol?
    
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
    
    private lazy var urlTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = S.Screens.Welcome.textFieldDefaultPlaceholder
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        
        textField.text = "https://www.google.com/"
        
        textField.autocorrectionType = .no
        textField.layer.borderWidth = 0.5
        return textField
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

        presenter?.locationRequest()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureSubviews()
    }
    
    // MARK: - Setup
    private func configureSubviews() {
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(instructionsLabel)
        view.addSubview(urlTextField)
        view.addSubview(scanButton)
        
        imageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.4)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
        }
        
        instructionsLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
        }
        
        urlTextField.snp.makeConstraints { make in
            make.top.equalTo(instructionsLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }
        
        scanButton.snp.makeConstraints { make in
            make.top.equalTo(urlTextField.snp.bottom).offset(15)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }
    }
    
    // MARK: - Actions
    @objc private func scanButtonTapped(sender: UIButton!) {
        UIView.animate(withDuration: 0.2, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            sender.alpha = 0.8
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, animations: {
                sender.transform = CGAffineTransform.identity
                sender.alpha = 1.0
            })
        })
        
        if let url = urlTextField.text {
            presenter?.urlReferenceValidate(url)
        }
    }
    
}


// MARK: - WelcomeViewControllerDelegate
extension WelcomeViewController: WelcomeViewControllerDelegate {
    
    func urlValidationError() {
        urlTextField.text = ""
        urlTextField.placeholder = S.Screens.Welcome.textFieldAlertPlaceholder
        urlTextField.layer.borderColor = UIColor(red: 1.00, green: 0.00, blue: 0.00, alpha: 1.00).cgColor
    }
}
