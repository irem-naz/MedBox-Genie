import SwiftUI
import FirebaseAuth

struct LoginPageView: View {
    @Binding var isLoggedIn: Bool
    @Environment(\.presentationMode) var presentationMode // Environment variable for dismissing the view
    @State private var email = ""
    @State private var password = ""
    @State private var showErrorMessage = false
    @State private var showSuccessMessage = false // State for showing the success alert
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            Color(.systemTeal).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                // Back Button
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss() // Dismiss view to go back
                    }) {
                        HStack {
                            Image(systemName: "arrow.left")
                            Text("Back")
                        }
                        .foregroundColor(.white)
                        .padding()
                    }
                    Spacer()
                }
                
                Text("Welcome Back")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                // Email Field
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.horizontal, 20)
                
                // Password Field with Visibility Toggle
                PasswordField(password: $password)

                // Login Button
                Button(action: validateAndLogin) {
                    Text("Login")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(email.isEmpty || password.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(email.isEmpty || password.isEmpty)
                .padding(.top, 20)
            }
            .padding()
        }
        .alert(isPresented: $showErrorMessage) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $showSuccessMessage) {
            Alert(title: Text("Success"), message: Text("Login successful!"), dismissButton: .default(Text("OK")) {
                // Delay before setting isLoggedIn to true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isLoggedIn = true // Show black screen after success alert
                }
            })
        }
        .fullScreenCover(isPresented: $isLoggedIn) {
            SuccessView()
        }
    }

    private func validateAndLogin() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password cannot be empty."
            showErrorMessage = true
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = "Try again" // Custom message for failed login
                showErrorMessage = true
            } else {
                showSuccessMessage = true  // Show success alert on successful login
            }
        }
    }
}

// Simple Success View
struct SuccessView: View {
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            Text("Login Successful")
                .font(.title)
                .foregroundColor(.white)
        }
    }
}
