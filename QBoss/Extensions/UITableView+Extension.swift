import UIKit

extension UIView {
    static var identifier: String {
        return String(describing: self)
    }
}

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T? {
        guard let cell = dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as? T else {
            assertionFailure("unable to dequeue cell with identifier \(T.identifier)")
            return nil
        }
        return cell
    }
    
    func register(cellClass: UITableViewCell.Type) {
        register(cellClass.self, forCellReuseIdentifier: cellClass.identifier)
    }
}
