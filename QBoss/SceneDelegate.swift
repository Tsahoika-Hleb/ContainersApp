import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var routeHelper: RouteHelper?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let winScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: winScene)
        
        if let window {
            let helper: RouteHelper = .init(window: window)
            routeHelper = helper
            StartHelper().setRootVC(routeHelper: helper)
        }
    }
}

