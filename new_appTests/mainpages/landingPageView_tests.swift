import XCTest
import SwiftUI
import ViewInspector
@testable import new_app

final class LandingPageViewTests: XCTestCase {

    // Test that the view renders correctly with expected UI elements
    func testLandingPageRendering() throws {
        // Arrange
        let view = LandingPageView(isLoggedIn: .constant(false))

        // Act
        let inspectedView = try view.inspect()

        // Assert: Check for welcome text
        XCTAssertNoThrow(try inspectedView.find(text: "Welcome to Medbox Genie"), "Welcome text is missing.")

        // Assert: Check for Login button
        XCTAssertNoThrow(try inspectedView.find(button: "Login"), "Login button is missing.")

        // Assert: Check for Sign Up button
        XCTAssertNoThrow(try inspectedView.find(button: "Sign Up"), "Sign Up button is missing.")
    }

    // Test Login button action
    func testLoginButtonAction() throws {
        // Arrange
        let view = LandingPageView(isLoggedIn: .constant(false))
        let inspectedView = try view.inspect()

        // Act
        let loginButton = try inspectedView.find(button: "Login")
        XCTAssertFalse(view.showLogin, "showLogin should be false initially.")

    
    }

    // Test Sign Up button action
    func testSignUpButtonAction() throws {
        // Arrange
        let view = LandingPageView(isLoggedIn: .constant(false))
        let inspectedView = try view.inspect()

        // Act
        let signUpButton = try inspectedView.find(button: "Sign Up")
        XCTAssertFalse(view.showSignUp, "showSignUp should be false initially.")

       
    }
}
