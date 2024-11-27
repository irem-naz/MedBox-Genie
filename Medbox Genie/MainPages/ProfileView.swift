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
