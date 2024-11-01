import SwiftUI

struct LandingPageView: View {
    @State private var showLogin = false
    @State private var showSignUp = false

    var body: some View {
        ZStack {
            Color(.systemTeal).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                // Logo Placeholder
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .overlay(
                        Text("Logo")
                            .foregroundColor(.red)
                            .font(.title)
                            .fontWeight(.bold)
                    )
                
                // Welcome Text
                Text("Welcome to Medbox Genie")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Login Button
                Button(action: {
                    showLogin = true
                }) {
                    Text("Login")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .fullScreenCover(isPresented: $showLogin) {
                    LoginPageView(isLoggedIn: .constant(false)) // Replace with actual binding if needed
                }

                // Sign Up Button
                Button(action: {
                    showSignUp = true
                }) {
                    Text("Sign Up")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                        .frame(width: 200, height: 50)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red, lineWidth: 2)
                        )
                }
                .fullScreenCover(isPresented: $showSignUp) {
                    SignUpPageView(isSignedUp: $showSignUp) // Pass binding to dismiss after sign-up
                }
            }
            .padding()
        }
    }
}

struct LandingPageView_Previews: PreviewProvider {
    static var previews: some View {
        LandingPageView()
    }
}
