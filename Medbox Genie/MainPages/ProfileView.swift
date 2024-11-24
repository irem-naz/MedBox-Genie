import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var userName = "User Name Placeholder" // Replace with actual user data retrieval
    @State private var email = Auth.auth().currentUser?.email ?? "Unknown Email"
    @State private var notificationTime: Date = Date() // Default notification time
    @Binding var isLoggedIn: Bool
    
    private let db = Firestore.firestore() // Firestore reference

    var body: some View {
        VStack(spacing: 20) {
            Text("Profile Information")
                .font(.largeTitle)
                .padding(.top, 20)
            
            Text("Name: \(userName)")
                .font(.title2)
            
            Text("Email: \(email)")
                .font(.title2)
            
            Divider().padding(.vertical)
            
            Text("Preferences")
                .font(.headline)
                .padding(.bottom, 10)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Notification Time")
                    .font(.subheadline)
                
                // Time-only picker
                DatePicker("Select Time", selection: $notificationTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden() // Hides the label
                
                Button(action: saveNotificationTime) {
                    Text("Save Notification Time")
                        .font(.body)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 10)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            Spacer()
            
            Button(action: logOff) {
                Text("Log Off")
                    .font(.title3)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.bottom, 10)
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Close")
                    .font(.title3)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.bottom, 30)
        }
        .padding()
        .onAppear(perform: loadNotificationTime) // Load saved notification time
    }
    
    private func saveNotificationTime() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("[ERROR] User not authenticated")
            return
        }
        
        // Save the time to Firestore
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: notificationTime)
        let minute = calendar.component(.minute, from: notificationTime)
        
        db.collection("users").document(userId).setData(["notificationTime": ["hour": hour, "minute": minute]], merge: true) { error in
            if let error = error {
                print("[ERROR] Failed to save notification time: \(error.localizedDescription)")
            } else {
                print("[INFO] Notification time saved successfully: \(hour):\(minute)")
            }
        }
    }
    
    private func loadNotificationTime() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("[ERROR] User not authenticated")
            return
        }
        
        // Load the time from Firestore
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                print("[ERROR] Failed to load notification time: \(error.localizedDescription)")
                return
            }
            
            if let data = snapshot?.data(),
               let timeData = data["notificationTime"] as? [String: Int],
               let hour = timeData["hour"],
               let minute = timeData["minute"] {
                let calendar = Calendar.current
                if let newTime = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) {
                    notificationTime = newTime
                    print("[INFO] Notification time loaded: \(hour):\(minute)")
                }
            } else {
                print("[INFO] No notification time found, using default.")
            }
        }
    }
    
    private func logOff() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false // Update login status to redirect to the landing page
            presentationMode.wrappedValue.dismiss() // Dismiss the profile view
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(isLoggedIn: .constant(true))
    }
}
