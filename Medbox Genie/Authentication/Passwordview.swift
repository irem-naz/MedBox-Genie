import SwiftUI

struct PasswordField: View {
    @Binding var password: String
    @State private var showPassword = false

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Password")
                .foregroundColor(.blue)
                .fontWeight(.semibold)
            
            ZStack {
                if showPassword {
                    TextField("Enter your password", text: $password)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue, lineWidth: 2) ) // Blue border
                        .foregroundColor(.blue)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                } else {
                    SecureField("Enter your password", text: $password)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue, lineWidth: 2))
                        .foregroundColor(.blue)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                HStack {
                    Spacer()
                    Button(action: {
                        showPassword.toggle()
                    }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                            .padding(.trailing, 10)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
}
