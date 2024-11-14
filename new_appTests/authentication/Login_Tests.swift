//
//  Login_Tests.swift
//  new_app
//
//  Created by Irem Naz Celen on 15.11.2024.
//
import XCTest
import SwiftUI
import ViewInspector
@testable import new_app

final class LoginViewModelTests: XCTestCase {
    private var fileURL: URL!

    override func setUpWithError() throws {
        fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("users.json")
        try? FileManager.default.removeItem(at: fileURL)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: fileURL)
    }

    func testAllFieldsRequired() {
        let viewModel = LoginViewModel()
        viewModel.username = ""
        viewModel.password = ""

        viewModel.authenticateUser(isLoggedIn: .constant(false))

        XCTAssertEqual(viewModel.errorMessage, "Failed to read user data.")
        XCTAssertTrue(viewModel.showErrorMessage)
    }

    func testInvalidUsernameOrPassword() {
        let existingUser: [String: String] = [
            "username": "testuser",
            "password": "Password123"
        ]

        // Write existing user to file
        do {
            let data = try JSONSerialization.data(withJSONObject: [existingUser], options: .prettyPrinted)
            try data.write(to: fileURL)
        } catch {
            XCTFail("Failed to set up user data.")
        }

        let viewModel = LoginViewModel()
        viewModel.username = "wronguser"
        viewModel.password = "wrongpassword"

        viewModel.authenticateUser(isLoggedIn: .constant(false))

        XCTAssertEqual(viewModel.errorMessage, "Invalid username or password.")
        XCTAssertTrue(viewModel.showErrorMessage)
    }

    func testSuccessfulLogin() {
        let existingUser: [String: String] = [
            "username": "testuser",
            "password": "Password123"
        ]

        // Write existing user to file
        do {
            let data = try JSONSerialization.data(withJSONObject: [existingUser], options: .prettyPrinted)
            try data.write(to: fileURL)
        } catch {
            XCTFail("Failed to set up user data.")
        }

        let viewModel = LoginViewModel()
        let isLoggedIn = Binding<Bool>(wrappedValue: false)
        viewModel.username = "testuser"
        viewModel.password = "Password123"

        viewModel.authenticateUser(isLoggedIn: isLoggedIn)

        XCTAssertTrue(isLoggedIn.wrappedValue)
        XCTAssertFalse(viewModel.showErrorMessage)
    }

    func testMissingUserFile() {
        let viewModel = LoginViewModel()

        viewModel.username = "testuser"
        viewModel.password = "Password123"

        viewModel.authenticateUser(isLoggedIn: .constant(false))

        XCTAssertEqual(viewModel.errorMessage, "Failed to read user data.")
        XCTAssertTrue(viewModel.showErrorMessage)
    }
    
    func testUIElementsRenderCorrectly() throws {
        let view = LoginPageView(isLoggedIn: .constant(false))
        let inspectedView = try view.inspect()

        // Ensure TextField for username exists
        XCTAssertNoThrow(try inspectedView.find(ViewType.TextField.self), "Username TextField should render")

        // Ensure SecureField for password exists
        XCTAssertNoThrow(try inspectedView.find(ViewType.SecureField.self), "Password SecureField should render")

        // Ensure Button exists
        XCTAssertNoThrow(try inspectedView.find(ViewType.Button.self), "Login button should render")
    }


}
