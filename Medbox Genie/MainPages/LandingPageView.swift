import SwiftUI

struct LandingPageView: View {
    @State private var showLogin = false
    @State private var showSignUp = false
    @Binding var isLoggedIn: Bool

    var body: some View {
        ZStack {
            Color(.systemBackground).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                // Logo Placeholder
                Circle()
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 120, height: 120)
                    .overlay(
                        Text("Logo")
                            .foregroundColor(.primary)
                            .font(.title)
                            .fontWeight(.bold)
                    )
                
                // Welcome Text
                Text("Welcome to Medbox Genie")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                // Login Button
                Button(action: {
                    showLogin = true
                }) {
                    Text("Login")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .fullScreenCover(isPresented: $showLogin) {
                    LoginPageView(isLoggedIn: $isLoggedIn)
                }

                // Sign Up Button
                Button(action: {
                    showSignUp = true
                }) {
                    Text("Sign Up")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .frame(width: 200, height: 50)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                }
                .fullScreenCover(isPresented: $showSignUp) {
                    SignUpPageView(isSignedUp: $showSignUp)
                }
            }
            .padding()
        }
    }
}

struct LandingPageView_Previews: PreviewProvider {
    static var previews: some View {
        LandingPageView(isLoggedIn: .constant(false))
    }
}

struct LandingPageView_Previews: PreviewProvider {
    static var previews: some View {
        LandingPageView(isLoggedIn: .constant(false))
    }
}
