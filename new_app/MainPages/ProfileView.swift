import SwiftUI

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @State  var userName: String = "User Name Placeholder" // Will fetch from `users.json`
    @State  var email: String = "Unknown Email"            // Will fetch from `users.json`
    @Binding var isLoggedIn: Bool                                 // System variable to track login status

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
        .onAppear(perform: fetchUserData)
    }
    
     func fetchUserData() {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("users.json")
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("[DEBUG] users.json file does not exist.")
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            if let users = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                // Assume that the first logged-in user is the active user
                if let currentUser = users.first {
                    userName = currentUser["username"] as? String ?? "User Name Placeholder"
                    email = currentUser["email"] as? String ?? "Unknown Email"
                }
            }
        } catch {
            print("[ERROR] Failed to read users.json: \(error.localizedDescription)")
        }
    }
    
     func logOff() {
        isLoggedIn = false // Simply update the system variable
        presentationMode.wrappedValue.dismiss() // Dismiss the profile view
        print("[DEBUG] User logged off successfully.")
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(isLoggedIn: .constant(true))
    }
}
