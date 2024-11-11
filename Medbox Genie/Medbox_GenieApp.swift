import SwiftUI
import Firebase  // Import Firebase
import FirebaseAuth

@main
struct Medbox_GenieApp: App {
    init() {
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        NotificationManager.shared.requestNotificationPermission()

        // Fetch and schedule notifications for the logged-in user
        if let userId = Auth.auth().currentUser?.uid {
            MedicationManager.shared.fetchAndScheduleNotifications(for: userId)
            MedicationManager.shared.listenToMedicationChanges(for: userId)
        }
    }

    var body: some Scene {
        WindowGroup {
            LaunchApp()
        }
    }
}
