import UIKit
import CoreLocation

final class StartHelper {
    
    func setRootVC(routeHelper: RouteHelper) {
        let vc = WelcomeViewController()
        let dataUpdateHelper = DataUpdateHelper(localStorageManager: DataStoreManager(),
                                                    networkManager: DataUploadManager())
        let router = WelcomeRouter(routeHelper: routeHelper, dataUpdateHelper: dataUpdateHelper)
        let presenter = WelcomePresenter(delegate: vc, router: router)
        vc.presenter = presenter
        routeHelper.navController?.viewControllers = [vc]
    }
}
