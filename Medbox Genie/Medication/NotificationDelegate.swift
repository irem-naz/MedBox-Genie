import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    private override init() {}
    
    // Handle notifications while the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("[DEBUG] Notification received in foreground: \(notification.request.identifier)")
        completionHandler([.banner, .sound]) // Present the notification as a banner
    }
    
    // Handle user interaction with the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("[DEBUG] User interacted with notification: \(response.notification.request.identifier)")
        let medicationName = response.notification.request.content.title
        
        switch response.actionIdentifier {
        case "ACCEPT_ACTION":
            print("[DEBUG] User tapped 'Accept' for medication: \(medicationName).")
            handleAccept(for: medicationName)
        
            
        default:
            print("[DEBUG] Unknown action: \(response.actionIdentifier)")
        }
        
        completionHandler()
    }
    
    private func handleAccept(for medicationName: String) {
        print("[DEBUG] Marking medication '\(medicationName)' as taken.")
        
    }
}
