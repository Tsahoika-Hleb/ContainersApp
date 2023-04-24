import UIKit

protocol ContainersListDelegate: AnyObject {
    func onHandleAllButtonAction()
    func onHandleNotSendButtonAction()
    func onHandleNotIdentifiedButtonAction()
    func containersCount() -> Int
    func containerForRow(_ rowIndex: Int) -> ScannedContainerModel?
    func deleteContainerForRow(_ rowIndex: Int)
    func sendToServer(for row: Int)
}

private enum ButtonSizes {
    static let all = CGSize(width: 65, height: 28)
    static let notSend = CGSize(width: 115, height: 28)
    static let notIdentified = CGSize(width: 145, height: 28)
}

private enum LayoutConstants {
    static let buttonTopInset: CGFloat = 0
    static let buttonLeadingInset: CGFloat = 16
    static let buttonSpacing: CGFloat = 8
    static let tableViewTopInset: CGFloat = 20
}

final class ContainersList: UIView {
    
    weak var delegate: ContainersListDelegate?
    
    // MARK: - Private Properties
    private lazy var allButton: UIButton = {
        let button = createFilterButton(title: S.Screens.ContainerList.allFilterButtonTitle,
                                        action: #selector(handleAllButtonTap))
        button.backgroundColor = .blue
        return button
    }()
    
    private lazy var notSendButton: UIButton = createFilterButton(
        title: S.Screens.ContainerList.notSendButtonTitle,
        action: #selector(handleNotSendButtonTap))
    
    private lazy var notIdentifiedButton: UIButton = createFilterButton(
        title: S.Screens.ContainerList.notIdentifiedButtonTitle,
        action: #selector(handleNotIdentifiedButtonTap))
    
    private lazy var scannedContainersTableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(cellClass: ScannedContainerTableViewCell.self)
        tableView.rowHeight = 150
        tableView.allowsSelection = false
        tableView.backgroundColor = .white
        return tableView
    }()
    
    // MARK: - Initialization
    init() {
        super.init(frame: .zero)
        setViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    func updateList() {
        scannedContainersTableView.reloadData()
    }
    
    // MARK: - Private Methods
    private func setViews() {
        addSubview(allButton)
        addSubview(notSendButton)
        addSubview(notIdentifiedButton)
        addSubview(scannedContainersTableView)
    }
    
    private func setConstraints() {
        allButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(LayoutConstants.buttonTopInset)
            make.leading.equalToSuperview().inset(LayoutConstants.buttonLeadingInset)
            make.size.equalTo(ButtonSizes.all)
        }
        
        notSendButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(LayoutConstants.buttonTopInset)
            make.leading.equalTo(allButton.snp.trailing).offset(LayoutConstants.buttonSpacing)
            make.size.equalTo(ButtonSizes.notSend)
        }
        
        notIdentifiedButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(LayoutConstants.buttonTopInset)
            make.leading.equalTo(notSendButton.snp.trailing).offset(LayoutConstants.buttonSpacing)
            make.size.equalTo(ButtonSizes.notIdentified)
        }
        
        scannedContainersTableView.snp.makeConstraints { make in
            make.top.equalTo(allButton.snp.bottom).offset(LayoutConstants.tableViewTopInset)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Actions
    @objc private func handleAllButtonTap(sender: UIButton!) {
        filterChoosed(sender)
        delegate?.onHandleAllButtonAction()
    }
    
    @objc private func handleNotSendButtonTap(sender: UIButton!) {
        filterChoosed(sender)
        delegate?.onHandleNotSendButtonAction()
    }
    
    @objc private func handleNotIdentifiedButtonTap(sender: UIButton!) {
        filterChoosed(sender)
        delegate?.onHandleNotIdentifiedButtonAction()
    }
    
    private func filterChoosed(_ sender: UIButton) {
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
        
        allButton.backgroundColor = .lightGray
        notSendButton.backgroundColor = .lightGray
        notIdentifiedButton.backgroundColor = .lightGray
        
        sender.backgroundColor = .blue
    }
    
    private func createFilterButton(title: String, action: Selector) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 14
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
}


// MARK: - UITableViewDataSource & UITableViewDelegate
extension ContainersList: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        delegate?.containersCount() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: ScannedContainerTableViewCell = scannedContainersTableView.dequeueReusableCell(for: indexPath),
              let container = delegate?.containerForRow(indexPath.row)
        else {
            return UITableViewCell()
        }
        
        cell.setup(leftImage: UIImage(data: container.image),
                   scanTimestamp: container.detectedTime.dateToString(),
                   isIdentified: container.isScannedSuccessfully,
                   serialNumber: container.title,
                   latitude: String(format: "%.5f", container.latitude),
                   longitude: String(format: "%.5f",container.longitude),
                   sentToServer: container.isSentToServer)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            delegate?.deleteContainerForRow(indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let customAction = UIContextualAction(style: .normal, title: S.Screens.ContainerList.rightSwipeActionTitle) { (action, view, completionHandler) in
            self.delegate?.sendToServer(for: indexPath.row)
            completionHandler(true)
        }
        customAction.backgroundColor = UIColor.blue
        
        let configuration = UISwipeActionsConfiguration(actions: [customAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}


