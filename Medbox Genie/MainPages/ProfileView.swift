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
        ScrollView { // Use ScrollView to handle smaller screens
            VStack(alignment: .leading, spacing: 20) { // Align content to leading
                
                // Profile Information Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Profile Information")
                        .font(.largeTitle)
                        .padding(.top, 20)
                    
                    Text("Name: \(userName)")
                        .font(.title2)
                        .foregroundColor(.primary)
                    
                    Text("Email: \(email)")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 20)
                
                Divider()
                    .padding(.horizontal, 20)

                // App Information Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("App Information")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Medbox Genie is your personal health assistant that helps you manage your medications with ease.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    
                    Text("Features:")
                        .font(.headline)
                        .padding(.top, 10)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("- Medication reminders.")
                        Text("- Low stock notifications.")
                        Text("- Expiry notifications.")
                        Text("- Adding new medications.")
                        Text("- Symptom tracking to monitor your health.")
                    }
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Log Off Button
                Button(action: logOff) {
                    Text("Log Off")
                        .font(.title3)
                        .padding()
                        .frame(maxWidth: .infinity) // Full-width button
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Close Button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Close")
                        .font(.title3)
                        .padding()
                        .frame(maxWidth: .infinity) // Full-width button
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
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
