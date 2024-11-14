import SwiftUI

struct PasswordField: View {
    @Binding var password: String
    @State private var showPassword = false

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Password")
                .foregroundColor(.white)
                .fontWeight(.semibold)
            
            ZStack {
                if showPassword {
                    TextField("Enter your password", text: $password)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                } else {
                    SecureField("Enter your password", text: $password)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
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
