import SwiftUI
import FirebaseAuth

struct LoginPageView: View {
    @Binding var isLoggedIn: Bool
    @Environment(\.presentationMode) var presentationMode // Environment variable for dismissing the view
    @State private var email = ""
    @State private var password = ""
    @State private var showErrorMessage = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
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
                        .foregroundColor(.blue)
                        .padding()
                    }
                    Spacer()
                }
                
                Text("Welcome Back")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding(.top, 20)

                // Genie Lamp Below "Welcome Back"
                Image("genieLamp") // Add your genie lamp image to Assets with the name "genieLamp"
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100) // Adjust size as needed
                    .padding(.top, 10) // Add space below "Welcome Back"

                // Email Field
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.white) // White background
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue, lineWidth: 2) // Blue border
                    )
                    .foregroundColor(.blue)
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
                        .background(email.isEmpty || password.isEmpty ? Color.blue : Color.red)
                        .cornerRadius(20)
                }
                .disabled(email.isEmpty || password.isEmpty)
                .padding(.top, 20)
            }
            .padding()
        }
        .alert(isPresented: $showErrorMessage) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
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
                isLoggedIn = true  // Set to true on successful login
                presentationMode.wrappedValue.dismiss() // Dismiss login view
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

struct LoginPageView_Previews: PreviewProvider {
    static var previews: some View {
        LoginPageView(isLoggedIn: .constant(false))
    }
}
