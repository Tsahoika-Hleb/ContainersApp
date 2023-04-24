import UIKit

private enum LayoutConstants {
    static let textFieldHeight: CGFloat = 44
    static let endpointListTableViewHeight: CGFloat = 0
    static let textFieldTrailingInset: CGFloat = 50
    static let endpointListTableViewBorderWidth: CGFloat = 0.2
    static let textFieldBorderWidth: CGFloat = 0.5
    static let buttonContentInsents: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
}

final class EndpointsTextField: UIView {
    
    // MARK: - Private Properties
    private var expandedTouchArea: CGFloat = 0.0
    private var urlRepository = URLRepository.init()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: S.Screens.ContainerList.textFieldDefaultPlaceholder,
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        textField.returnKeyType = .done
        textField.backgroundColor = .white
        textField.textColor = .black
        textField.layer.borderWidth = LayoutConstants.textFieldBorderWidth
        textField.font = UIFont.systemFont16
        textField.borderStyle = .roundedRect
        textField.addTarget(self, action: #selector(textFieldEditingDidBegin), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(urlEndEditing), for: .editingDidEnd)
        textField.delegate = self
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private lazy var dropdownButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.contentInsets = LayoutConstants.buttonContentInsents
        let button = UIButton(configuration: configuration)
        button.setImage(UIImage.chevronDown, for: .normal)
        button.tintColor = .gray
        button.addTarget(self, action: #selector(dropdownButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var endpointListTableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(cellClass: UITableViewCell.self)
        tableView.rowHeight = LayoutConstants.textFieldHeight
        tableView.backgroundColor = .clear
        tableView.isHidden = true
        tableView.clipsToBounds = false
        tableView.layer.masksToBounds = true
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
    func isUrlEstablished() -> Bool {
        urlRepository.fetchLastEndpoint().isEmpty ? false : true
    }
    
    func setTextField(_ str: String) {
        textField.text = str
        isEndpointsEmpty()
    }
    
    func urlValidationResult(_ isSuccesful: Bool) {
        if isSuccesful {
            textField.layer.borderColor = UIColor.transperant
            updateTableView()
            dropdownButton.isHidden = false
            isEndpointsEmpty()
        } else {
            textField.text = ""
            textField.placeholder = S.Screens.ContainerList.textFieldAlertPlaceholder
            textField.layer.borderColor = UIColor.red.cgColor
        }
    }
    
    func updateTableView() {
        endpointListTableView.snp.updateConstraints { make in
            make.height.equalTo(getTableViewHeight())
        }
        endpointListTableView.reloadData()
    }
    
    func endEditing() {
        textField.endEditing(true)
        endpointListTableView.isHidden = true
        updateTouchArea()
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let extendedBounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height + expandedTouchArea)
        return extendedBounds.contains(point)
    }
    
    // MARK: - Private Methods
    private func setViews() {
        addSubview(textField)
        addSubview(dropdownButton)
        addSubview(endpointListTableView)
        setTextField(urlRepository.fetchLastEndpoint())
    }
    
    private func setConstraints() {
        textField.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.height.equalTo(LayoutConstants.textFieldHeight)
            make.trailing.equalToSuperview()
        }
        
        dropdownButton.snp.makeConstraints { make in
            make.centerY.equalTo(textField)
            make.trailing.equalToSuperview()
        }
        
        endpointListTableView.snp.updateConstraints { make in
            make.top.equalTo(textField.snp.bottom)
            make.leading.trailing.equalTo(textField)
            make.height.equalTo(LayoutConstants.endpointListTableViewHeight)
        }
    }
    
    private func isEndpointsEmpty() {
        if urlRepository.endpointsCount <= 1 {
            dropdownButton.isHidden = true
            textField.snp.updateConstraints { make in
                make.trailing.equalToSuperview()
            }
        } else {
            textField.snp.updateConstraints { make in
                make.trailing.equalToSuperview().inset(LayoutConstants.textFieldTrailingInset)
            }
        }
    }
    
    private func getTableViewHeight() -> Int{
        let maxVisiableCells = 5
        let height = Int(endpointListTableView.rowHeight) * urlRepository.endpointsCount
        let maxHeight = Int(endpointListTableView.rowHeight) * maxVisiableCells
        if urlRepository.endpointsCount < maxVisiableCells {
            return height
        } else {
            return maxHeight
        }
    }
    
    private func updateTouchArea() {
        expandedTouchArea = CGFloat(endpointListTableView.isHidden ? 0 : getTableViewHeight())
        setNeedsDisplay()
    }
    
    // MARK: - Actions
    @objc private func textFieldEditingDidBegin() {
        endpointListTableView.isHidden = true
        updateTouchArea()
    }
    
    @objc private func urlEndEditing() {  // TODO: SET HERE
        endpointListTableView.isHidden = true
        urlValidationResult(urlRepository.addEndpoint(textField.text ?? ""))
    }
    
    @objc private func dropdownButtonTapped() {
        textField.endEditing(true)
        endpointListTableView.isHidden.toggle()
        updateTouchArea()
    }
}


// MARK: - UITableViewDataSource & UITableViewDelegate
extension EndpointsTextField: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        urlRepository.endpointsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: UITableViewCell = endpointListTableView.dequeueReusableCell(for: indexPath)
        else { return UITableViewCell() }
        
        let index = urlRepository.endpointsCount - 1 - indexPath.row
        
        cell.backgroundColor = .white
        cell.textLabel?.text = urlRepository.endpoint(for: index)
        cell.textLabel?.textColor = .black
        cell.layer.borderWidth = LayoutConstants.endpointListTableViewBorderWidth
        cell.layer.borderColor = UIColor.black.cgColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = urlRepository.endpointsCount - 1 - indexPath.row
        
        let url = urlRepository.endpoint(for: index)
        textField.text = url
        textField.layer.borderColor = UIColor.transperant
        endpointListTableView.deselectRow(at: indexPath, animated: false)
        endpointListTableView.isHidden = true
        updateTouchArea()
        
        urlRepository.setSelected(url)
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
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let customAction = UIContextualAction(style: .normal, title: S.Screens.EndpointsList.deleteSwipeActionTitle) { [self] (action, view, completionHandler) in
            let index = self.urlRepository.endpointsCount - 1 - indexPath.row
            urlRepository.deleteEndpoint(for: index)
            tableView.reloadData()
            isEndpointsEmpty()
            setTextField(urlRepository.fetchLastEndpoint())
            completionHandler(true)
        }
        customAction.backgroundColor = UIColor.red
        
        let configuration = UISwipeActionsConfiguration(actions: [customAction])
        return configuration
    }
}


//MARK: - UITextFieldDelegate
extension EndpointsTextField: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            textField.resignFirstResponder()
            endpointListTableView.isHidden = true
            updateTouchArea()
            urlValidationResult(urlRepository.addEndpoint(text))
            return true
        } else {
            return false
        }
    }
}
