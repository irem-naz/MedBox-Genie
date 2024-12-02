import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    private override init() {}
    
    // Handle notifications while the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("[DEBUG] Notification received in foreground: \(notification.request.identifier)")
        if notification.request.identifier.contains("survey") {
            print("[DEBUG] Survey notification received: \(notification.request.identifier)")

            // Extract details from the notification
            let medicationName = notification.request.content.title
            let surveyDateString = notification.request.identifier.split(separator: "_").last ?? ""
            let surveyDate = ISO8601DateFormatter().date(from: String(surveyDateString)) ?? Date()

            // Post the notification event with additional details
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: NSNotification.Name("NewSurveyNotification"),
                    object: nil,
                    userInfo: [
                        "medicationName": medicationName,
                        "surveyDate": surveyDate
                    ]
                )
            }
            
            // Play sound only (no banners)
            completionHandler([.sound])
        } else {
            // For all other notifications, show a banner and play sound
            completionHandler([.banner, .sound])
        }
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
