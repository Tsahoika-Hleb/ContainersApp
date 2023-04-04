import UIKit

protocol ContainerListViewDelegateProtocol: UIViewController {
    func showContainersList()
    func urlValidation(isSuccesful: Bool)
    func showLastEndpoint(_ endpoint: String)
}

private enum LayoutConstants {
    static let leadingTrainlingInset: CGFloat = 16
    static let navBarHeight: CGFloat = 44
    static let lineHeight: CGFloat = 1
    static let buttonHeight: CGFloat = 55
    static let topOffset: CGFloat = 16
    static let containersListTopOffset: CGFloat = 20
}

final class ContainersListViewController: UIViewController {
    
    // MARK: - Properties
    var presenter: ContainersListPresenterSpec?
    
    private lazy var containersList: ContainersList = {
        let view = ContainersList()
        view.delegate = self
        return view
    }()
    
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
        setViews()
        setConstraints()
    }
    
    // MARK: - Private Methods
    private func setViews() {
        view.addSubview(topSafeAreaView)
        view.addSubview(navigationBar)
        view.addSubview(lineView)
        view.addSubview(startScanningButton)
        view.addSubview(containersList)
        view.addSubview(endpointsTextField)
    }
    
    private func setConstraints() {
        topSafeAreaView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top)
        }

        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(LayoutConstants.navBarHeight)
        }

        lineView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(LayoutConstants.leadingTrainlingInset)
            make.height.equalTo(LayoutConstants.lineHeight)
        }

        endpointsTextField.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(LayoutConstants.topOffset)
            make.leading.equalToSuperview().offset(LayoutConstants.leadingTrainlingInset)
            make.trailing.equalToSuperview().inset(LayoutConstants.leadingTrainlingInset)
            make.height.equalTo(LayoutConstants.navBarHeight)
        }
        endpointsTextField.updateTableView()

        startScanningButton.snp.makeConstraints { make in
            make.top.equalTo(endpointsTextField.snp.bottom).offset(LayoutConstants.topOffset)
            make.leading.trailing.equalToSuperview().inset(LayoutConstants.leadingTrainlingInset)
            make.height.equalTo(LayoutConstants.buttonHeight)
        }

        containersList.snp.makeConstraints { make in
            make.top.equalTo(startScanningButton.snp.bottom).offset(LayoutConstants.containersListTopOffset)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Actions
    @objc private func startScanningButtonTapped(sender: UIButton!) {
        if let text = endpointsTextField.getText() {
            presenter?.returnToScanPage(urlString: text)
        }
    }
}


// MARK: - ContainerListViewDelegateProtocol
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


// MARK: - ContainersListDelegate
extension ContainersListViewController: ContainersListDelegate {
    func onHandleAllButtonAction() {
        presenter?.changeFilter(to: .all)
    }
    
    func onHandleNotSendButtonAction() {
        presenter?.changeFilter(to: .notSend)
    }
    
    func onHandleNotIdentifiedButtonAction() {
        presenter?.changeFilter(to: .notIdentified)
    }
    
    func containersCount() -> Int {
        guard let presenter = presenter else {
            fatalError("No presenter")
        }
        return presenter.scunnedContainersCount
    }
    
    func containerForRow(_ rowIndex: Int) -> ScannedContainerModel? {
        guard let presenter = presenter else {
            fatalError("No presenter")
        }
        return presenter.container(for: rowIndex)
    }
    
    func deleteContainerForRow(_ rowIndex: Int) {
        guard let presenter = presenter else {
            fatalError("No presenter")
        }
        presenter.deleteContainerForRow(for: rowIndex)
    }
    
    func sendToServer() {
        guard let presenter = presenter else {
            fatalError("No presenter")
        }
        presenter.sendToServer()
    }
}


// MARK: - EndpointsTextFieldDelegate
extension ContainersListViewController: EndpointsTextFieldDelegate {
    
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
