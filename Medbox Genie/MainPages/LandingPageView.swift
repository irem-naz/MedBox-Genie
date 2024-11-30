import SwiftUI

struct LandingPageView: View {
    @State private var showLogin = false
    @State private var showSignUp = false
    @Binding var isLoggedIn: Bool

    var body: some View {
        ZStack {
            // Plain white background
            Color.white
                .edgesIgnoringSafeArea(.all)

            // Main content
            VStack(spacing: 40) {
                Spacer() // Adds space to move content down
                
                // Genie Logo (Big and Centered)
                Image("genieLogo") // Add your genie logo to Assets and name it "genieLogo"
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300) // Bigger logo size

            
                // Welcome Text
                Text("Welcome to Medbox Genie")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)

                // Buttons Stack
                VStack(spacing: 20) {
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
                            .cornerRadius(25)
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
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                    }
                    .fullScreenCover(isPresented: $showSignUp) {
                        SignUpPageView(isSignedUp: $showSignUp)
                    }
                }

                Spacer() // Pushes everything to the bottom
            }
        }
    }
}

struct LandingPageView_Previews: PreviewProvider {
    static var previews: some View {
        LandingPageView(isLoggedIn: .constant(false))
    }
}
