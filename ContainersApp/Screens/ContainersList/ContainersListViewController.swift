//

import UIKit

class ContainersListViewController: UIViewController {
    
    // MARK: - Properties
    var presenter: ContainersListPresenterSpec?
    
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = S.Screens.ContainerList.textFieldDefaultPlaceholder
        textField.returnKeyType = .done
        textField.textColor = .black
        textField.layer.borderWidth = 0.5
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.borderStyle = .roundedRect
        textField.addTarget(self, action: #selector(textFieldEditingDidBegin), for: .editingDidBegin)
        textField.delegate = self
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private lazy var dropdownButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.chevronDown, for: .normal)
        button.tintColor = .gray
        button.addTarget(self, action: #selector(dropdownButtonTapped), for: .touchUpInside)
        button.contentEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        return button
    }()
    
    private lazy var endpointListTableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(cellClasses: UITableViewCell.self)
        tableView.rowHeight = 44
        tableView.backgroundColor = .clear
        tableView.isHidden = true
        tableView.clipsToBounds = false
        tableView.layer.masksToBounds = true
        return tableView
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
    
    lazy var allButton: UIButton = {
        let button = UIButton()
        button.setTitle(S.Screens.ContainerList.allFilterButtonTitle, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 14
        button.addTarget(self, action: #selector(handleAllButtonTap), for: .touchUpInside)
        return button
    }()

    lazy var notSendButton: UIButton = {
        let button = UIButton()
        button.setTitle(S.Screens.ContainerList.notSendButtonTitle, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 14
        button.addTarget(self, action: #selector(handleNotSendButtonTap), for: .touchUpInside)
        return button
    }()

    lazy var notIdentifiedButton: UIButton = {
        let button = UIButton()
        button.setTitle(S.Screens.ContainerList.notIdentifiedButtonTitle, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 14
        button.addTarget(self, action: #selector(handleNotIdentifiedButtonTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var scannedContainersTableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(cellClasses: ScannedContainerTableViewCell.self)
        tableView.rowHeight = 150
        tableView.allowsSelection = false
        return tableView
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = S.Screens.ContainerList.navigationTitle
        
        presenter?.setUp()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureSubviews()
    }
    
    // MARK: - Private Methods
    private func configureSubviews() {
        view.addSubview(lineView)
        view.addSubview(dropdownButton)
        view.addSubview(startScanningButton)
        view.addSubview(allButton)
        view.addSubview(notSendButton)
        view.addSubview(notIdentifiedButton)
        view.addSubview(scannedContainersTableView)
        view.addSubview(endpointListTableView)
        view.addSubview(textField)
        
        lineView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(1)
        }
        
        textField.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(44)
            make.trailing.equalTo(dropdownButton.snp.leading).offset(-8)
        }
        
        dropdownButton.snp.makeConstraints { make in
            make.centerY.equalTo(textField)
            make.trailing.equalToSuperview().inset(16)
        }
        
        endpointListTableView.snp.updateConstraints { make in
            make.top.equalTo(textField.snp.bottom)
            make.leading.trailing.equalTo(textField)
            if let presenter = presenter {
                let height = Int(endpointListTableView.rowHeight) * presenter.endpointsCount
                let maxHeight = Int(endpointListTableView.rowHeight) * 5
                if presenter.endpointsCount < 5 {
                    make.height.equalTo(height)
                } else {
                    make.height.equalTo(maxHeight + 10)
                }
            }
        }

        startScanningButton.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(55)
        }
        
        allButton.snp.makeConstraints { make in
            make.top.equalTo(startScanningButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(28)
            make.width.equalTo(65)
        }
        
        notSendButton.snp.makeConstraints { make in
            make.top.equalTo(startScanningButton.snp.bottom).offset(20)
            make.leading.equalTo(allButton.snp.trailing).offset(8)
            make.height.equalTo(28)
            make.width.equalTo(115)
        }
        
        notIdentifiedButton.snp.makeConstraints { make in
            make.top.equalTo(startScanningButton.snp.bottom).offset(20)
            make.leading.equalTo(notSendButton.snp.trailing).offset(8)
            make.height.equalTo(28)
            make.width.equalTo(145)
        }
        
        scannedContainersTableView.snp.makeConstraints { make in
            make.top.equalTo(allButton.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    // MARK: - Actions
    @objc private func startScanningButtonTapped(sender: UIButton!) {
        presenter?.returnToScanPage()
    }
    
    @objc private func textFieldEditingDidBegin() {
        endpointListTableView.isHidden = false
    }
    
    @objc private func dropdownButtonTapped() {
        endpointListTableView.isHidden.toggle()
    }
    
    @objc func handleAllButtonTap(sender: UIButton!) {
        filterChoosed(sender)
        presenter?.changeFilter(to: .all)
    }

    @objc func handleNotSendButtonTap(sender: UIButton!) {
        filterChoosed(sender)
        presenter?.changeFilter(to: .notSend)
    }

    @objc func handleNotIdentifiedButtonTap(sender: UIButton!) {
        filterChoosed(sender)
        presenter?.changeFilter(to: .notIdentified)
    }
    
    private func filterChoosed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            sender.alpha = 0.8
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, animations: {
                sender.transform = CGAffineTransform.identity
                sender.alpha = 1.0
            })
        })
        
        allButton.backgroundColor = .lightGray
        notSendButton.backgroundColor = .lightGray
        notIdentifiedButton.backgroundColor = .lightGray
        
        sender.backgroundColor = .blue
    }
}


// MARK: - UITableViewDataSource & UITableViewDelegate
extension ContainersListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let presenter = presenter else {
            fatalError("No presenter")
        }
        
        if tableView == self.endpointListTableView {
            return presenter.endpointsCount
        } else if tableView == self.scannedContainersTableView {
            return presenter.scunnedContainersCount
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let presenter = presenter else {
            fatalError("No presenter")
        }
        
        if tableView == self.endpointListTableView {
            guard let cell: UITableViewCell = endpointListTableView.dequeueReusableCell(for: indexPath) else {
                return UITableViewCell()
            }
            
            cell.textLabel?.text = presenter.getEndpointForRow(for: indexPath.row)
            cell.layer.borderWidth = 0.2
            cell.layer.borderColor = UIColor.black.cgColor
            return cell
            
        } else if tableView == self.scannedContainersTableView {
            guard let cell: ScannedContainerTableViewCell = scannedContainersTableView.dequeueReusableCell(for: indexPath) else {
                return UITableViewCell()
            }
            
            let container = presenter.getContainerForRow(for: indexPath.row)
            if indexPath.row == 1 {
                cell.setup(leftImage: UIImage(named: "mockImage2"),
                           scanTimestamp: container.scanTimestamp,
                           isIdentified: container.isIdentified,
                           serialNumber: container.serialNumber,
                           latitude: String(container.latitude),
                           longitude: String(container.longitude),
                           sentToServer: container.isSentToServer)
            } else {
                cell.setup(leftImage: UIImage(named: "mockImage"),
                           scanTimestamp: container.scanTimestamp,
                           isIdentified: container.isIdentified,
                           serialNumber: container.serialNumber,
                           latitude: String(container.latitude),
                           longitude: String(container.longitude),
                           sentToServer: container.isSentToServer)
            }
            return cell
            
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == self.endpointListTableView {
            textField.text = presenter?.getEndpointForRow(for: indexPath.row)
            endpointListTableView.isHidden = true
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            scrollView.setContentOffset(CGPoint.zero, animated: false)
        }
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY + height >= contentHeight {
            scrollView.setContentOffset(CGPoint(x: 0, y: contentHeight - height), animated: false)
        }
    }
    
    // TODO: add handler of deleting endpoint
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView == scannedContainersTableView {
            if editingStyle == .delete {
                presenter?.deleteContainerForRow(for: indexPath.row)
            }
        }
    }
    

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if tableView == scannedContainersTableView {
            let customAction = UIContextualAction(style: .normal, title: S.Screens.ContainerList.rightSwipeActionTitle) { (action, view, completionHandler) in
                self.presenter?.sendToServer()
                completionHandler(true)
            }
            customAction.backgroundColor = .blue
            
            let configuration = UISwipeActionsConfiguration(actions: [customAction])
            configuration.performsFirstActionWithFullSwipe = false
            return configuration
        }
        
        return UISwipeActionsConfiguration()
    }

}


//MARK: - ContainerListViewDelegateProtocol
extension ContainersListViewController: ContainerListViewDelegateProtocol {
    
    func urlValidationSucces() {
        textField.layer.borderColor = UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1.00).cgColor
        endpointListTableView.reloadData()
        endpointListTableView.snp.updateConstraints { make in
            if let presenter = presenter {
                let height = Int(endpointListTableView.rowHeight) * presenter.endpointsCount
                let maxHeight = Int(endpointListTableView.rowHeight) * 5
                if presenter.endpointsCount < 5 {
                    make.height.equalTo(height)
                } else {
                    make.height.equalTo(maxHeight + 10)
                }
            }
        }
    }
    
    func urlValidationError() {
        textField.text = ""
        textField.placeholder = S.Screens.ContainerList.textFieldAlertPlaceholder
        textField.layer.borderColor = UIColor(red: 1.00, green: 0.00, blue: 0.00, alpha: 1.00).cgColor
    }
    
    func showContainersList() {
        scannedContainersTableView.reloadData()
    }
}


//MARK: - UITextFieldDelegate
extension ContainersListViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            textField.resignFirstResponder()
            endpointListTableView.isHidden = true
            presenter?.addEndpoint(text)
            return true
        } else {
            return false
        }
    }
}
