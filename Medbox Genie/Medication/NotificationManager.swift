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
    func scheduleExpiryNotification(for medication: Medication, userId: String) {
        let notificationIdentifier = "\(userId)_\(medication.medicineName)_expiry"
        
        // Remove existing notification for this medication
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
        
        let content = UNMutableNotificationContent()
        content.title = "Medication Expiry Alert"
        content.body = "Your medication '\(medication.medicineName)' has expired."
        content.sound = .default
        content.categoryIdentifier = "MEDICATION_CATEGORY"
        
        let calendar = Calendar.current
        // Directly use the hour and minute set in add medication
        let expiryDateTime = calendar.date(bySettingHour: medication.startHour, minute: medication.startMinute+2, second: 0, of: medication.expiryDate) ?? medication.expiryDate
        
        let triggerDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: expiryDateTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[ERROR] Error scheduling expiry notification: \(error.localizedDescription)")
            } else {
                print("[DEBUG] Expiry notification scheduled for \(medication.medicineName) at \(triggerDateComponents).")
            }
        }
    }


    
    func scheduleReminderNotifications(for medication: Medication, userId: String) {
        let calendar = Calendar.current
        let intervalBetweenDoses = 24 / medication.frequency
        var currentDate = medication.startDate
        var remainingPills = medication.totalPills

        outerLoop: for _ in 0..<medication.duration { // Loop through days
            for doseIndex in 0..<medication.frequency { // Loop through doses in a day
                guard remainingPills > 0 else {
                    print("[INFO] No pills left to schedule further reminders.")
                    break outerLoop
                }

                let doseHour = medication.startHour + doseIndex * intervalBetweenDoses
                let doseTime = calendar.date(bySettingHour: doseHour % 24, minute: medication.startMinute, second: 0, of: currentDate)!

                // Schedule the notification
                let notificationIdentifier = "\(userId)_\(medication.medicineName)_\(doseTime)"
                let content = UNMutableNotificationContent()
                content.title = "Medication Reminder"
                content.body = "Time to take your medication: \(medication.medicineName). Pills left: \(remainingPills - 1)."
                content.sound = .default
                content.categoryIdentifier = "MEDICATION_CATEGORY"

                let triggerDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: doseTime)
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)

                let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("[ERROR] Error scheduling reminder notification: \(error.localizedDescription)")
                    } else {
                        print("[DEBUG] Reminder notification scheduled for \(medication.medicineName) at \(triggerDateComponents).")
                    }
                }

                // Deduct one pill for the scheduled reminder
                remainingPills -= 1
            }

            // Move to the next day
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        // Log final state
        print("[INFO] Scheduled reminders up to the pill limit. Remaining pills: \(remainingPills)")
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
