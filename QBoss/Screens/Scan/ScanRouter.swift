import UIKit

protocol ScanRouterSpec {
    func showContainersList(dataUpdateHelper: DataUpdateHelper)
}

class ScanRouter: ScanRouterSpec {
    
    private let routeHelper: RouteHelper
    private let dataUpdateHelper: DataUpdateHelper
    
    init(routeHelper: RouteHelper, dataUpdateHelper: DataUpdateHelper) {
        self.routeHelper = routeHelper
        self.dataUpdateHelper = dataUpdateHelper
    }
    
    func showContainersList(dataUpdateHelper: DataUpdateHelper) {
        guard !routeHelper.popTo(controllerType: ContainersListViewController.self, animated: true) else { return }
        let containerListVC = ContainersListViewController()
        let router = ContainersListRouter(routeHelper: routeHelper, dataUpdateHelper: dataUpdateHelper)
        let presenter = ContainersListPresenter(delegate: containerListVC,
                                                router: router,
                                                dataUpdateHelper: dataUpdateHelper)
        containerListVC.presenter = presenter
        routeHelper.pushVC(containerListVC)
    }
}
