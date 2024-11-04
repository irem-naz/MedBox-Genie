
import SwiftUI
import Firebase  // Import Firebase

@main
struct Medbox_GenieApp: App {
    
    // Initialize Firebase in the initializer
    init() {
        FirebaseApp.configure()  // Configure Firebase
        print("Firebase has been successfully initialized.")
    }

    var body: some Scene {
        WindowGroup {
            LaunchApp()
        }
    }
}

