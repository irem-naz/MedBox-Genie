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

        let db = Firestore.firestore()
        let medicationRef = db.collection("users").document(userId).collection("medications").whereField("medicineName", isEqualTo: medicationName)
        
        medicationRef.getDocuments { snapshot, error in
            if let error = error {
                print("[ERROR] Failed to fetch medication: \(error.localizedDescription)")
                return
            }
            
            guard let document = snapshot?.documents.first else {
                print("[ERROR] Medication not found.")
                return
            }
            
            var medicationData = document.data()
            if var totalPills = medicationData["totalPills"] as? Int, totalPills > 0 {
                totalPills -= 1
                medicationData["totalPills"] = totalPills
                
                document.reference.updateData(medicationData) { error in
                    if let error = error {
                        print("[ERROR] Failed to update medication: \(error.localizedDescription)")
                    } else {
                        print("[DEBUG] Medication '\(medicationName)' total pills updated to \(totalPills).")
                    }
                }
            } else {
                print("[ERROR] Invalid total pills count.")
            }
        }
    }
}
