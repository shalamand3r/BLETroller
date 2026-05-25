import UIKit

private let BLETrollerQuickActionTypeBroadcastRandom = "com.bletroller.broadcastRandom"
private let BLETrollerPendingQuickActionDefaultsKey = "BLETrollerPendingQuickActionType"
private let BLETrollerQuickActionNotification = Notification.Name("BLETrollerQuickActionNotification")

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    private func configureQuickActions() {
        let randomIcon: UIApplicationShortcutIcon?
        if #available(iOS 13.0, *) {
            randomIcon = UIApplicationShortcutIcon(systemImageName: "antenna.radiowaves.left.and.right")
        } else {
            randomIcon = nil
        }

        let broadcastRandom = UIApplicationShortcutItem(
            type: BLETrollerQuickActionTypeBroadcastRandom,
            localizedTitle: "Start a random broadcast",
            localizedSubtitle: nil,
            icon: randomIcon,
            userInfo: nil
        )

        UIApplication.shared.shortcutItems = [broadcastRandom]
    }

    private func handleQuickActionType(_ type: String?) -> Bool {
        guard let type, !type.isEmpty else { return false }
        UserDefaults.standard.set(type, forKey: BLETrollerPendingQuickActionDefaultsKey)
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(
            name: BLETrollerQuickActionNotification,
            object: nil,
            userInfo: ["type": type]
        )
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureQuickActions()
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleQuickActionType(shortcutItem.type))
    }
}
