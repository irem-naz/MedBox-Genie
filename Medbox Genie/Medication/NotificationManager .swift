import Foundation
import UserNotifications
import FirebaseFirestore

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
    
    // MARK: - Schedule Expiry Notification
    func scheduleExpiryNotification(for medicationName: String, at expiryDate: Date, userId: String) {
        let notificationIdentifier = "\(userId)_\(medicationName)_expiry"
        
        // Remove existing notification for this medication
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
        
        let content = UNMutableNotificationContent()
        content.title = "Medication Expiry Alert"
        content.body = "Your medication '\(medicationName)' is expiring soon."
        content.sound = .default
        content.categoryIdentifier = "MEDICATION_CATEGORY"
        
        // Use the provided expiry date for scheduling
        let triggerDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: expiryDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[ERROR] Error scheduling expiry notification: \(error.localizedDescription)")
            } else {
                print("[DEBUG] Expiry notification scheduled for \(medicationName) at \(triggerDateComponents) for user \(userId).")
            }
        }
    }
    
    func scheduleReminderNotifications(for medicationName: String, on reminderDays: Set<String>, after startDate: Date, until endDate: Date, userId: String) {
        fetchNotificationTime(for: userId) { preferredTime in
            guard let preferredTime = preferredTime else {
                print("[ERROR] Preferred notification time not set. Skipping reminder notifications.")
                return
            }
            
            let calendar = Calendar.current
            let daySymbols = calendar.shortWeekdaySymbols // ["Sun", "Mon", "Tue", ...]
            
            for day in reminderDays {
                guard let targetDayIndex = daySymbols.firstIndex(of: day) else {
                    print("[ERROR] Invalid day: \(day). Skipping.")
                    continue
                }
                
                // Start with the first occurrence of the target day after the start date
                var nextReminderDate = self.getNextReminderDate(for: targetDayIndex, after: startDate, with: preferredTime)
                
                print("[DEBUG] Scheduling reminders for \(day):") // Debug: Print which day we're processing
                
                while let reminderDate = nextReminderDate, reminderDate <= endDate {
                    // Debug: Log the date for this reminder
                    print("    [DEBUG] Reminder Date: \(reminderDate)")
                    
                    let notificationIdentifier = "\(userId)_\(medicationName)_\(day)_\(reminderDate)"
                    
                    // Create the notification content
                    let content = UNMutableNotificationContent()
                    content.title = "Medication Reminder"
                    content.body = "Time to take your medication: \(medicationName)."
                    content.sound = .default
                    content.categoryIdentifier = "MEDICATION_CATEGORY"
                    
                    // Schedule the notification
                    let triggerDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
                    
                    let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            print("[ERROR] Error scheduling reminder notification: \(error.localizedDescription)")
                        } else {
                            print("[DEBUG] Reminder notification scheduled for \(medicationName) on \(day) at \(triggerDateComponents).")
                        }
                    }
                    
                    // Move to the next occurrence (add 7 days to get the next week)
                    nextReminderDate = calendar.date(byAdding: .day, value: 7, to: reminderDate)
                }
            }
        }
    }

    
    // MARK: - Fetch Notification Time from Firestore
    func fetchNotificationTime(for userId: String, completion: @escaping (Date?) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                print("[ERROR] Failed to fetch notification time: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let data = snapshot?.data(),
               let timeData = data["notificationTime"] as? [String: Int],
               let hour = timeData["hour"],
               let minute = timeData["minute"] {
                let calendar = Calendar.current
                let preferredTime = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date())
                completion(preferredTime)
            } else {
                print("[INFO] No notification time found. Using default.")
                completion(nil)
            }
        }
    }
    
    // MARK: - Calculate Next Reminder Date
    private func getNextReminderDate(for targetDayIndex: Int, after startDate: Date, with time: Date) -> Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: time)
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        
        var nextDate = startDate
        while calendar.component(.weekday, from: nextDate) - 1 != targetDayIndex {
            // Move to the next day until we match the target day
            nextDate = calendar.date(byAdding: .day, value: 1, to: nextDate) ?? nextDate
        }
        
        // Set the time to the preferred notification time
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: nextDate)
    }
}
