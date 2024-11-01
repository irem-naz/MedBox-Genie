//
//  Medbox_GenieApp.swift
//  Medbox Genie
//
//  Created by Beemnet Andualem Belete on 10/28/24.
//

import SwiftUI
import SwiftData
import Firebase  // Import Firebase

@main
struct Medbox_GenieApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    // Initialize Firebase in the initializer
    init() {
        FirebaseApp.configure()  // Configure Firebase
        print("Firebase has been successfully initialized.")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

