import UIKit

final class ContainersList: UIView {
    
    var onHandleAllButtonAction: (() -> Void)?
    var onHandleNotSendButtonAction: (() -> Void)?
    var onHandleNotIdentifiedButtonAction: (() -> Void)?
    var containersCount: (() -> Int)?
    var containerForRow: ((Int) -> ScannedContainerModel)?
    var deleteContainerForRow: ((Int) -> Void)?
    var sendToServer: (() -> Void)?
    
    // MARK: - Private Properties
    private lazy var allButton: UIButton = {
        let button = UIButton()
        button.setTitle(S.Screens.ContainerList.allFilterButtonTitle, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 14
        button.addTarget(self, action: #selector(handleAllButtonTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var notSendButton: UIButton = {
        let button = UIButton()
        button.setTitle(S.Screens.ContainerList.notSendButtonTitle, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 14
        button.addTarget(self, action: #selector(handleNotSendButtonTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var notIdentifiedButton: UIButton = {
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
        tableView.register(cellClass: ScannedContainerTableViewCell.self)
        tableView.rowHeight = 150
        tableView.allowsSelection = false
        tableView.backgroundColor = .white
        return tableView
    }()
    
    // MARK: - Initialization
    init() {
        super.init(frame: .zero)
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
    private func setConstraints() {
        addSubview(allButton)
        addSubview(notSendButton)
        addSubview(notIdentifiedButton)
        addSubview(scannedContainersTableView)
        
        let allButtonSize = CGSize(width: 65, height: 28)
        let notSendButtonSize = CGSize(width: 115, height: 28)
        let notIdentifiedButtonSize = CGSize(width: 145, height: 28)
        let buttonTopInset: CGFloat = 0
        let buttonLeadingInset: CGFloat = 16
        let buttonSpacing: CGFloat = 8
        let tableViewTopInset: CGFloat = 20
        
        allButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(buttonTopInset)
            make.leading.equalToSuperview().inset(buttonLeadingInset)
            make.size.equalTo(allButtonSize)
        }
        
        notSendButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(buttonTopInset)
            make.leading.equalTo(allButton.snp.trailing).offset(buttonSpacing)
            make.size.equalTo(notSendButtonSize)
        }
        
        notIdentifiedButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(buttonTopInset)
            make.leading.equalTo(notSendButton.snp.trailing).offset(buttonSpacing)
            make.size.equalTo(notIdentifiedButtonSize)
        }
        
        scannedContainersTableView.snp.makeConstraints { make in
            make.top.equalTo(allButton.snp.bottom).offset(tableViewTopInset)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
    }
    
    // MARK: - Actions
    @objc func handleAllButtonTap(sender: UIButton!) {
        filterChoosed(sender)
        onHandleAllButtonAction?()
    }
    
    @objc func handleNotSendButtonTap(sender: UIButton!) {
        filterChoosed(sender)
        onHandleNotSendButtonAction?()
    }
    
    @objc func handleNotIdentifiedButtonTap(sender: UIButton!) {
        filterChoosed(sender)
        onHandleNotIdentifiedButtonAction?()
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
}


// MARK: - UITableViewDataSource & UITableViewDelegate
extension ContainersList: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        containersCount?() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: ScannedContainerTableViewCell = scannedContainersTableView.dequeueReusableCell(for: indexPath),
              let containerForRow = containerForRow
        else {
            return UITableViewCell()
        }
 
        let container = containerForRow(indexPath.row)
        if indexPath.row == 1 {
            /*
             Этого в будущем не будет, я просто хотел посмотреть как
             вертикальные картинки в ячейке смотреться будут
             */
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
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteContainerForRow?(indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let customAction = UIContextualAction(style: .normal, title: S.Screens.ContainerList.rightSwipeActionTitle) { (action, view, completionHandler) in
            self.sendToServer?()
            completionHandler(true)
        }
        customAction.backgroundColor = UIColor.blue
        
        let configuration = UISwipeActionsConfiguration(actions: [customAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}
