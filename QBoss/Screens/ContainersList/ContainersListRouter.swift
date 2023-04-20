import UIKit

protocol ContainersListRouterProtocol {
    func showScanScreen()
}

final class ContainersListRouter: ContainersListRouterProtocol {
    private let routeHelper: RouteHelper
    private let dataUpdateHelper: DataUpdateHelper
    
    init(routeHelper: RouteHelper, dataUpdateHelper: DataUpdateHelper) {
        self.routeHelper = routeHelper
        self.dataUpdateHelper = dataUpdateHelper
    }
    
    func showScanScreen() {
        guard !routeHelper.popTo(controllerType: ScanViewController.self, animated: true) else { return }
        let scanVC = ScanViewController()
        let router = ScanRouter(routeHelper: routeHelper, dataUpdateHelper: dataUpdateHelper)
        let presenter = ScanPresenter(delegate: scanVC,
                                      router: router,
                                      tfManager: TFManager(),
                                      dataUpdateHelper: dataUpdateHelper)
        scanVC.presenter = presenter
        routeHelper.pushVC(scanVC)
    }
}
