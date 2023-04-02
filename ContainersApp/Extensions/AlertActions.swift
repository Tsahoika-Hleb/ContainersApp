//

import UIKit

extension UIAlertAction {
    static let cancelAction = UIAlertAction(title: S.AlertAction.cancel, style: .cancel, handler: nil)
    static let okAction = UIAlertAction(title: S.AlertAction.ok, style: .cancel, handler: nil)
    static let settingAction = UIAlertAction(title: S.AlertAction.settings, style: .default) { (action) in
        UIApplication.shared.open(
            URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }
}
