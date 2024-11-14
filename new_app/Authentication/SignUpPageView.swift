//
//  SignUpPageView.swift
//  new_app
//
//  Created by Irem Naz Celen on 15.11.2024.
//
import SwiftUI

class SignUpViewModel: ObservableObject {
    @Published var email = ""
    @Published var username = ""
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var showErrorMessage = false
    @Published var showSuccessMessage = false

    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("users.json")
    }

    func validateAndSignUp() {
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

        saveUserToJSON()
    }

    private func saveUserToJSON() {
        var users: [[String: String]] = []

        // Load existing users
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                users = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: String]] ?? []
            } catch {
                errorMessage = "Failed to load existing user data."
                showErrorMessage = true
                return
            }
        }

        // Check for duplicates
        if users.contains(where: { $0["email"] == email || $0["username"] == username }) {
            errorMessage = "Email or username already in use."
            showErrorMessage = true
            return
        }

        // Save new user
        let newUser: [String: String] = [
            "email": email,
            "username": username,
            "password": password
        ]
        users.append(newUser)

        do {
            let data = try JSONSerialization.data(withJSONObject: users, options: .prettyPrinted)
            try data.write(to: fileURL, options: .atomic)
            showSuccessMessage = true
        } catch {
            errorMessage = "Failed to save user data."
            showErrorMessage = true
        }
    }
}

struct SignUpPageView: View {
    @ObservedObject var viewModel = SignUpViewModel()
    @Binding var isSignedUp: Bool

    var body: some View {
        ZStack {
            Color(.systemTeal).edgesIgnoringSafeArea(.all)
            VStack(spacing: 16) {
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                TextField("Email", text: $viewModel.email)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.horizontal, 20)
                
                TextField("Username", text: $viewModel.username)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.horizontal, 20)
                
                PasswordField(password: $viewModel.password)
                
                Text("Password must be at least 8 characters long and include both letters and numbers.")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 20)
                
                Button(action: viewModel.validateAndSignUp) {
                    Text("Sign Up")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(viewModel.email.isEmpty || viewModel.username.isEmpty || viewModel.password.isEmpty ? Color.gray : Color.green)
                        .cornerRadius(10)
                }
                .disabled(viewModel.email.isEmpty || viewModel.username.isEmpty || viewModel.password.isEmpty)
                .padding(.top, 20)
            }
            .padding()
        }
        .alert(isPresented: $viewModel.showErrorMessage) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $viewModel.showSuccessMessage) {
            Alert(
                title: Text("Success"),
                message: Text("Account created successfully!"),
                dismissButton: .default(Text("OK"), action: {
                    isSignedUp = false
                })
            )
        }
    }
}
