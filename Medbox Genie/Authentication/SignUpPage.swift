import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpPageView: View {
    @Environment(\.presentationMode) var presentationMode  // Dismiss environment for back button
    @Binding var isSignedUp: Bool
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var showErrorMessage = false
    @State private var errorMessage = ""
    @State private var showSuccessMessage = false

    var body: some View {
        ZStack {
            Color(.systemTeal).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                // Back Button
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()  // Dismiss the view to go back
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                }
                
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.horizontal, 20)
                
                TextField("Username", text: $username)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.horizontal, 20)
                
                PasswordField(password: $password)  // Assuming PasswordField is defined elsewhere
                
                Text("Password must be at least 8 characters long and include both letters and numbers.")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 20)
                
                Button(action: validateAndSignUp) {
                    Text("Sign Up")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(email.isEmpty || username.isEmpty || password.isEmpty ? Color.gray : Color.green)
                        .cornerRadius(10)
                }
                .disabled(email.isEmpty || username.isEmpty || password.isEmpty)
                .padding(.top, 20)
            }
            .padding()
        }
        .alert(isPresented: $showErrorMessage) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $showSuccessMessage) {
            Alert(
                title: Text("Success"),
                message: Text("Account created successfully!"),
                dismissButton: .default(Text("OK"), action: {
                    isSignedUp = false  // Return to landing page on success
                })
            )
        }
    }

    private func validateAndSignUp() {
        print("Starting sign-up process...")  // Debugging print statement

        // Input validation
        guard !email.isEmpty, !username.isEmpty, !password.isEmpty else {
            errorMessage = "All fields are required."
            showErrorMessage = true
            return
        }
        
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        
        if !passwordPredicate.evaluate(with: password) {
            errorMessage = "Password must be at least 8 characters long and include both letters and numbers."
            showErrorMessage = true
            return
        }
        
        // Firebase Authentication
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
                print("Firebase Auth Error: \(errorMessage)")  // Debugging print statement
                showErrorMessage = true
            } else {
                print("Firebase Auth Success")  // Debugging print statement
                saveUserDetailsToFirestore()
                showSuccessMessage = true
            }
        }
    }
    
    private func saveUserDetailsToFirestore() {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "Failed to retrieve user ID"
            showErrorMessage = true
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).setData([
            "username": username,
            "email": email
        ]) { error in
            if let error = error {
                errorMessage = "Failed to save user data: \(error.localizedDescription)"
                print("Firestore Save Error: \(errorMessage)")  // Debugging print statement
                showErrorMessage = true
            } else {
                print("User data saved to Firestore")  // Debugging print statement
            }
        }
    }
}
