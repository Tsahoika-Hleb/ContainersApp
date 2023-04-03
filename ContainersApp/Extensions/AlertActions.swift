import UIKit

extension UIAlertAction {
    static let cancelAction = UIAlertAction(title: S.AlertAction.cancel, style: .cancel, handler: nil)
    static let okAction = UIAlertAction(title: S.AlertAction.ok, style: .cancel, handler: nil)
    static let settingAction = UIAlertAction(title: S.AlertAction.settings, style: .default) { _ in
            guard let appSettings = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
    }
}
