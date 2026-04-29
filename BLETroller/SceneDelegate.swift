import UIKit

private let BLETrollerPendingQuickActionDefaultsKey = "BLETrollerPendingQuickActionType"
private let BLETrollerQuickActionNotification = Notification.Name("BLETrollerQuickActionNotification")

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = ViewController()
            window.makeKeyAndVisible()
            self.window = window
        }

        if let shortcut = connectionOptions.shortcutItem, !shortcut.type.isEmpty {
            UserDefaults.standard.set(shortcut.type, forKey: BLETrollerPendingQuickActionDefaultsKey)
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(
                name: BLETrollerQuickActionNotification,
                object: nil,
                userInfo: ["type": shortcut.type]
            )
        }
    }

    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let handled = !shortcutItem.type.isEmpty
        if handled {
            UserDefaults.standard.set(shortcutItem.type, forKey: BLETrollerPendingQuickActionDefaultsKey)
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(
                name: BLETrollerQuickActionNotification,
                object: nil,
                userInfo: ["type": shortcutItem.type]
            )
        }
        completionHandler(handled)
    }
}
