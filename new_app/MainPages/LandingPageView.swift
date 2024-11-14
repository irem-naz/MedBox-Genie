// LandingPageView.swift
import SwiftUI

struct LandingPageView: View {
    @Binding var isLoggedIn: Bool

    var body: some View {
        if isLoggedIn {
            // Main content if logged in
            MainPageView(isLoggedIn: $isLoggedIn)
            
        } else {
            LandingPageView(isLoggedIn: $isLoggedIn)  // Show the landing page initially
        }
    }
}
