import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }

        // Handle local notifications when app is launched from a notification
        if let notification = launchOptions?[.remoteNotification] as? [String: Any] {
            handleLocalNotification(notification)
        }

        return true
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        handleLocalNotification(userInfo)
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Perform background tasks, e.g., check if alarm should trigger and show local notification

        completionHandler(.newData)
    }

    func handleLocalNotification(_ userInfo: [AnyHashable: Any]) {
        // Handle local notification details here
    }
}
