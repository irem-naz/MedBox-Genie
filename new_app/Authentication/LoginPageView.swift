import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var showErrorMessage = false

    func authenticateUser(isLoggedIn: Binding<Bool>) {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("users.json")

        do {
            let data = try Data(contentsOf: fileURL)
            if let users = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: String]],
               users.contains(where: { $0["username"] == username && $0["password"] == password }) {
                isLoggedIn.wrappedValue = true
            } else {
                errorMessage = "Invalid username or password."
                showErrorMessage = true
            }
        } catch {
            errorMessage = "Failed to read user data."
            showErrorMessage = true
        }
    }
}

struct LoginPageView: View {
    @Binding var isLoggedIn: Bool
    @ObservedObject var viewModel = LoginViewModel()

    var body: some View {
        VStack(spacing: 20) {
            TextField("Username", text: $viewModel.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Login") {
                viewModel.authenticateUser(isLoggedIn: $isLoggedIn)
            }
            .padding()
            .alert(isPresented: $viewModel.showErrorMessage) {
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("OK")))
            }
        }
        .padding()
    }
}
