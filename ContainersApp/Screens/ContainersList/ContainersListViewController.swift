import UIKit

class ContainersListViewController: UIViewController {
    
    // MARK: - Properties
    var presenter: ContainersListPresenterSpec?
    
    private lazy var containersList: ContainersList = {
        let view = ContainersList()
        
        view.onHandleAllButtonAction = { [weak presenter] in
            presenter?.changeFilter(to: .all)
        }
        view.onHandleNotSendButtonAction = { [weak presenter] in
            presenter?.changeFilter(to: .notSend)
        }
        view.onHandleNotIdentifiedButtonAction = { [weak presenter] in
            presenter?.changeFilter(to: .notIdentified)
        }
        
        view.containersCount = { [weak presenter] in
            guard let presenter = presenter else {
                fatalError("No presenter")
            }
            return presenter.scunnedContainersCount
        }
        view.containerForRow = { [weak presenter] row in
            guard let presenter = presenter else {
                fatalError("No presenter")
            }
            return presenter.container(for: row)
        }
        view.deleteContainerForRow = { [weak presenter] row in
            guard let presenter = presenter else {
                fatalError("No presenter")
            }
            presenter.deleteContainerForRow(for: row)
        }
        view.sendToServer = { [weak presenter] in
            guard let presenter = presenter else {
                fatalError("No presenter")
            }
            presenter.sendToServer()
        }
        
        return view
    }()
    
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
    
    private lazy var navigationBar: UINavigationBar = {
        let bar = UINavigationBar()
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        UINavigationBar.appearance().titleTextAttributes = textAttributes
        UINavigationBar.appearance().barTintColor = .white
        let navItem = UINavigationItem(title: S.Screens.ContainerList.navigationTitle)
        bar.setItems([navItem], animated: false)
        return bar
    }()
    
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var startScanningButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(S.Screens.ContainerList.scanButtonTitle, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(startScanningButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        presenter?.setUp()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureSubviews()
    }
    
    // MARK: - Private Methods
    private func configureSubviews() {
        view.addSubview(topSafeAreaView)
        view.addSubview(navigationBar)
        view.addSubview(lineView)
        view.addSubview(startScanningButton)
        view.addSubview(containersList)
        view.addSubview(endpointsTextField)
        
        let leadingInset: CGFloat = 16
        let trailingInset: CGFloat = 16
        let height44: CGFloat = 44
        let height1: CGFloat = 1
        let height55: CGFloat = 55
        let topOffset16: CGFloat = 16
        let topOffset20: CGFloat = 20

        topSafeAreaView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top)
        }

        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(height44)
        }

        lineView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(leadingInset)
            make.height.equalTo(height1)
        }

        endpointsTextField.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(topOffset16)
            make.leading.equalToSuperview().offset(leadingInset)
            make.trailing.equalToSuperview().inset(trailingInset)
            make.height.equalTo(height44)
        }
        endpointsTextField.updateTableView()

        startScanningButton.snp.makeConstraints { make in
            make.top.equalTo(endpointsTextField.snp.bottom).offset(topOffset16)
            make.leading.trailing.equalToSuperview().inset(leadingInset)
            make.height.equalTo(height55)
        }

        containersList.snp.makeConstraints { make in
            make.top.equalTo(startScanningButton.snp.bottom).offset(topOffset20)
            make.leading.trailing.bottom.equalToSuperview()
        }

    }
    
    // MARK: - Actions
    @objc private func startScanningButtonTapped(sender: UIButton!) {
        presenter?.returnToScanPage()
    }
}


//MARK: - ContainerListViewDelegateProtocol
extension ContainersListViewController: ContainerListViewDelegateProtocol {
    
    func showLastEndpoint(_ endpoint: String) {
        endpointsTextField.setTextField(endpoint)
    }
    
    func urlValidation(isSuccesful: Bool) {
        endpointsTextField.urlValidationResult(isSuccesful)
    }

    func showContainersList() {
        containersList.updateList()
    }
}
