import UIKit
import Flutter
import Firebase
import FirebaseMessaging
import UserNotifications
import restart

@main
@objc class AppDelegate: FlutterAppDelegate {
    var firebaseToken: String = ""
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // --------------------------------------------------
        RestartPlugin.generatedPluginRegistrantRegisterCallback = { [weak self] in
            GeneratedPluginRegistrant.register(with: self!)
        }
        // --------------------------------------------------
        
        // Only configure Firebase, permissions will be handled in Flutter
        FirebaseApp.configure()
        
        // ── NEW: set the UNUserNotificationCenter delegate ──
        UNUserNotificationCenter.current().delegate = self 
        
        // ── NEW: actually register for remote notifications ──
        application.registerForRemoteNotifications()
        
        // FCM setup
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true  // Disable auto-initialization
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        print("APNS Token received: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
        super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    override func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register for notifications: \(error.localizedDescription)")
        super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
}

// // ── NEW: handle notification callbacks if needed ──
// extension AppDelegate: UNUserNotificationCenterDelegate {
//     // e.g. to show alerts when app is in foreground:
//     // func userNotificationCenter(_ center: UNUserNotificationCenter,
//     //                             willPresent notification: UNNotification,
//     //                             withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//     //     completionHandler([.alert, .badge, .sound])
//     // }
// }

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let token = fcmToken {
            self.firebaseToken = token
            print("FCM Token: \(token)")
        }
    }
}
