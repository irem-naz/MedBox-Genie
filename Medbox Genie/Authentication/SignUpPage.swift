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
            Color.white.edgesIgnoringSafeArea(.all) // Background color
            
            VStack(spacing: 16) {
                // Back Button
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()  // Dismiss the view to go back
                    }) {
                        HStack {
                            Image(systemName: "arrow.left")
                            Text("Back")
                        }
                        .foregroundColor(.blue)
                        .padding()
                    }
                    Spacer()
                }

                // Welcome Text
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding(.top, 20)

                // Genie Lamp Below "Create Account"
                Image("genieLamp") // Add your genie lamp image to Assets with the name "genieLamp"
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100) // Adjust size as needed
                    .padding(.top, 10)

                // Email Field
                VStack(alignment: .leading, spacing: 5) {
                    Text("Email")
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)

                    TextField("Enter your email", text: $email)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                        .foregroundColor(.blue)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.emailAddress)
                        .padding(.horizontal, 20)
                }

                // Username Field
                VStack(alignment: .leading, spacing: 5) {
                    Text("Username")
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)

                    TextField("Enter your username", text: $username)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                        .foregroundColor(.blue)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding(.horizontal, 20)
                }

                // Password Field
                PasswordField(password: $password) // Reuse the PasswordField component
                
                Text("Password must be at least 8 characters long and include both letters and numbers.")
                    .font(.footnote)
                    .foregroundColor(.blue.opacity(0.8))
                    .padding(.horizontal, 20)
                
                // Sign Up Button
                Button(action: validateAndSignUp) {
                    Text("Sign Up")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(email.isEmpty || username.isEmpty || password.isEmpty ? Color.gray : Color.red)
                        .cornerRadius(20)
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

struct SignUpPageView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpPageView(isSignedUp: .constant(false)) // Correct binding for `isSignedUp`
    }
}

