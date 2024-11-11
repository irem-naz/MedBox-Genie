import SwiftUI
import SwiftData

struct LaunchApp: View {
    
    @State private var isLoggedIn: Bool = false  // Control login state
    
    var body: some View {
        if isLoggedIn {
            // Main content if logged in
            MainPageView(isLoggedIn: $isLoggedIn)
            
        } else {
            LandingPageView(isLoggedIn: $isLoggedIn)  // Show the landing page initially
        }
    }

}

#Preview {
    LaunchApp()
}
