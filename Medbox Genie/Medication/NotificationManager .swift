import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager() // Singleton instance
    
    private init() {}
    
    // MARK: - Request Notification Permission
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("[ERROR] Notification permission error: \(error.localizedDescription)")
            } else if granted {
                self.setupNotificationCategories()
            } else {
                print("[WARNING] Notification permission denied by the user.")
            }
        }
    }
    
    // MARK: - Setup Notification Categories
    private func setupNotificationCategories() {
        let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION", title: "Accept", options: [.foreground])
        let snoozeAction = UNNotificationAction(identifier: "SNOOZE_ACTION", title: "Snooze (5 min)", options: [])
        
        let medicationCategory = UNNotificationCategory(
            identifier: "MEDICATION_CATEGORY",
            actions: [acceptAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([medicationCategory])
    }
    
    // MARK: - Schedule Notification with a Constant Time
    func scheduleNotificationWithActions(for medicationName: String, at date: Date, userId: String) {
        let notificationIdentifier = "\(userId)_\(medicationName)_expiry"
        
        // Remove existing notification for this medication
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
        
        let content = UNMutableNotificationContent()
        content.title = "Medication Expiry Alert"
        content.body = "Your medication '\(medicationName)' is expiring soon."
        content.sound = .default
        content.categoryIdentifier = "MEDICATION_CATEGORY"
        
        // Use the provided date for scheduling
        let triggerDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[ERROR] Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("[DEBUG] Notification scheduled for \(medicationName) at \(triggerDateComponents) for user \(userId).")
            }
        }
    }
}
