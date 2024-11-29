import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpPageView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isSignedUp: Bool
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var showErrorMessage = false
    @State private var errorMessage = ""
    @State private var showSuccessMessage = false

    var body: some View {
        ZStack {
            Color(.systemBackground).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                // Back Button
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
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
                
                Spacer()
                
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.top, 40)
                
                // Email Field
                TextField("Email", text: $email)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.horizontal, 20)
                
                // Username Field
                TextField("Username", text: $username)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.horizontal, 20)
                
                // Password Field with Visibility Toggle
                PasswordField(password: $password)
                    .padding(.horizontal, 20)

                // Sign Up Button
                Button(action: validateAndSignUp) {
                    Text("Sign Up")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(email.isEmpty || password.isEmpty || username.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(email.isEmpty || password.isEmpty || username.isEmpty)
                .padding(.top, 20)
                
                Spacer()
            }
            .padding()
        }
        .alert(isPresented: $showErrorMessage) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func validateAndSignUp() {
        guard !email.isEmpty, !password.isEmpty, !username.isEmpty else {
            errorMessage = "All fields are required."
            showErrorMessage = true
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = "Sign up failed: \(error.localizedDescription)"
                showErrorMessage = true
            } else {
                isSignedUp = true
            }
        }
    }
}
