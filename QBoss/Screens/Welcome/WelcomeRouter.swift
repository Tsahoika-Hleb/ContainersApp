import UIKit
import CoreLocation

protocol WelcomeRouterSpec {
    func showScanScreen()
    func showContainersList()
}

final class WelcomeRouter: WelcomeRouterSpec {
    private let routeHelper: RouteHelper
    private let dataUpdateHelper: DataUpdateHelper
    
    init(routeHelper: RouteHelper, dataUpdateHelper: DataUpdateHelper) {
        self.routeHelper = routeHelper
        self.dataUpdateHelper = dataUpdateHelper
    }
    
    func showScanScreen() {
        let scanVC = ScanViewController()
        let router = ScanRouter(routeHelper: routeHelper, dataUpdateHelper: dataUpdateHelper)
        let presenter = ScanPresenter(delegate: scanVC,
                                      router: router,
                                      tfManager: TFManager(),
                                      dataUpdateHelper: dataUpdateHelper)
        scanVC.presenter = presenter
        
        routeHelper.pushVC(scanVC)
    }
    
    func showContainersList() {
        let containersVC = ContainersListViewController()
        let router = ContainersListRouter(routeHelper: routeHelper, dataUpdateHelper: dataUpdateHelper)
        let presenter = ContainersListPresenter(delegate: containersVC, router: router, dataUpdateHelper: dataUpdateHelper)
        containersVC.presenter = presenter
        routeHelper.pushVC(containersVC)
    
    }
}
