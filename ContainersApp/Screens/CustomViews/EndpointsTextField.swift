import UIKit

final class EndpointsTextField: UIView {
    
    var endpointsCount: (() -> Int)?
    var endpointForRow: ((Int) -> String)?
    var addEndpoint: ((String) -> Void)?
    
    // MARK: - Private Properties
    private var expandedTouchArea: CGFloat = 0.0
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: S.Screens.ContainerList.textFieldDefaultPlaceholder,
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        textField.returnKeyType = .done
        textField.backgroundColor = .white
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
        tableView.register(cellClass: UITableViewCell.self)
        tableView.rowHeight = 44
        tableView.backgroundColor = .clear
        tableView.isHidden = true
        tableView.clipsToBounds = false
        tableView.layer.masksToBounds = true
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
    func getText() -> String? {
        return textField.text
    }
    
    func setTextField(_ str: String) {
        if !str.isEmpty {
            textField.text = str
        }
        isEndpointsEmpty()
    }
    
    func urlValidationResult(_ isSuccesful: Bool) {
        if isSuccesful {
            textField.layer.borderColor = UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1.00).cgColor
            updateTableView()
            dropdownButton.isHidden = false
            isEndpointsEmpty()
        } else {
            textField.text = ""
            textField.placeholder = S.Screens.ContainerList.textFieldAlertPlaceholder
            textField.layer.borderColor = UIColor(red: 1.00, green: 0.00, blue: 0.00, alpha: 1.00).cgColor
        }
    }
    
    func updateTableView() {
        endpointListTableView.snp.updateConstraints { make in
            make.height.equalTo(getTableViewHeight())
        }
        endpointListTableView.reloadData()
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let extendedBounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height + expandedTouchArea)
        return extendedBounds.contains(point)
    }
    
    // MARK: - Private Methods
    private func isEndpointsEmpty() {
        if let endpointsCount = endpointsCount {
            if endpointsCount() == 0 {
                dropdownButton.isHidden = true
                textField.snp.makeConstraints { make in
                    make.trailing.equalToSuperview()
                }
            } else {
                textField.snp.updateConstraints { make in
                    make.trailing.equalToSuperview().inset(50)
                }
            }
        }
    }
    
    private func setConstraints() {
        addSubview(textField)
        addSubview(dropdownButton)
        addSubview(endpointListTableView)

        let textFieldHeight: CGFloat = 44
        let endpointListTableViewHeight: CGFloat = 0

        textField.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.height.equalTo(textFieldHeight)
            make.trailing.equalToSuperview()
        }

        dropdownButton.snp.makeConstraints { make in
            make.centerY.equalTo(textField)
            make.trailing.equalToSuperview()
        }

        endpointListTableView.snp.updateConstraints { make in
            make.top.equalTo(textField.snp.bottom)
            make.leading.trailing.equalTo(textField)
            make.height.equalTo(endpointListTableViewHeight)
        }

    }
    
    private func getTableViewHeight() -> Int{
        let maxVisiableCells = 5
        if let endpointsCount = endpointsCount {
            let height = Int(endpointListTableView.rowHeight) * endpointsCount()
            let maxHeight = Int(endpointListTableView.rowHeight) * maxVisiableCells
            if endpointsCount() < maxVisiableCells {
                return height
            } else {
                return maxHeight
            }
        } else {
            return 0
        }
    }
    
    private func updateTouchArea() {
        expandedTouchArea = CGFloat(endpointListTableView.isHidden ? 0 : getTableViewHeight())
        setNeedsDisplay()
    }
    
    // MARK: - Actions
    @objc private func textFieldEditingDidBegin() {
        endpointListTableView.isHidden = false
        updateTouchArea()
    }
    
    @objc private func dropdownButtonTapped() {
        endpointListTableView.isHidden.toggle()
        updateTouchArea()
    }
}


// MARK: - UITableViewDataSource & UITableViewDelegate
extension EndpointsTextField: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        endpointsCount?() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: UITableViewCell = endpointListTableView.dequeueReusableCell(for: indexPath),
              let endpointForRow = endpointForRow
        else {
            return UITableViewCell()
        }
        
        cell.backgroundColor = .white
        cell.textLabel?.text = endpointForRow(indexPath.row)
        cell.textLabel?.textColor = .black
        cell.layer.borderWidth = 0.2
        cell.layer.borderColor = UIColor.black.cgColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let endpointForRow = endpointForRow else {
            return
        }
        textField.text = endpointForRow(indexPath.row)
        textField.layer.borderColor = UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1.00).cgColor
        endpointListTableView.deselectRow(at: indexPath, animated: false)
        endpointListTableView.isHidden = true
        updateTouchArea()
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
}


//MARK: - UITextFieldDelegate
extension EndpointsTextField: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            textField.resignFirstResponder()
            endpointListTableView.isHidden = true
            addEndpoint?(text)
            return true
        } else {
            return false
        }
    }
}
