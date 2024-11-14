//
//  SignUp_Tests.swift
//  new_app
//
//  Created by Irem Naz Celen on 15.11.2024.
//

import XCTest
import ViewInspector
@testable import new_app

final class SignUpViewModelTests: XCTestCase {

    private var fileURL: URL!

    override func setUpWithError() throws {
        fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("users.json")
        try? FileManager.default.removeItem(at: fileURL)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: fileURL)
    }

    func testAllFieldsRequired() {
        let viewModel = SignUpViewModel()
        viewModel.email = ""
        viewModel.username = ""
        viewModel.password = ""

        viewModel.validateAndSignUp()

        XCTAssertEqual(viewModel.errorMessage, "All fields are required.")
        XCTAssertTrue(viewModel.showErrorMessage)
    }

    func testPasswordValidationFails() {
        let viewModel = SignUpViewModel()
        viewModel.email = "test@example.com"
        viewModel.username = "testuser"
        viewModel.password = "short"

        viewModel.validateAndSignUp()

        XCTAssertEqual(viewModel.errorMessage, "Password must be at least 8 characters long and include both letters and numbers.")
        XCTAssertTrue(viewModel.showErrorMessage)
    }

    func testSaveNewUserSuccess() {
        let viewModel = SignUpViewModel()
        viewModel.email = "test@example.com"
        viewModel.username = "testuser"
        viewModel.password = "Password123"

        viewModel.validateAndSignUp()

        XCTAssertTrue(viewModel.showSuccessMessage)

        do {
            let data = try Data(contentsOf: fileURL)
            let users = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: String]]
            XCTAssertEqual(users?.count, 1)
            XCTAssertEqual(users?[0]["email"], "test@example.com")
            XCTAssertEqual(users?[0]["username"], "testuser")
            XCTAssertEqual(users?[0]["password"], "Password123")
        } catch {
            XCTFail("Failed to read or decode user data.")
        }
    }

    func testDuplicateEmailOrUsernameFails() {
        let viewModel = SignUpViewModel()
        let existingUser: [String: String] = [
            "email": "test@example.com",
            "username": "testuser",
            "password": "Password123"
        ]

        do {
            let data = try JSONSerialization.data(withJSONObject: [existingUser], options: .prettyPrinted)
            try data.write(to: fileURL)
        } catch {
            XCTFail("Failed to set up existing user data.")
        }

        viewModel.email = "test@example.com"
        viewModel.username = "newuser"
        viewModel.password = "Password123"

        viewModel.validateAndSignUp()

        XCTAssertEqual(viewModel.errorMessage, "Email or username already in use.")
        XCTAssertTrue(viewModel.showErrorMessage)
    }
    
    func testEmptyEmailErrorMessage() {
        let viewModel = SignUpViewModel()
        viewModel.email = ""
        viewModel.username = "testuser"
        viewModel.password = "Password123"

        viewModel.validateAndSignUp()

        XCTAssertEqual(viewModel.errorMessage, "All fields are required.")
        XCTAssertTrue(viewModel.showErrorMessage)
    }

    func testEmptyUsernameErrorMessage() {
        let viewModel = SignUpViewModel()
        viewModel.email = "test@example.com"
        viewModel.username = ""
        viewModel.password = "Password123"

        viewModel.validateAndSignUp()

        XCTAssertEqual(viewModel.errorMessage, "All fields are required.")
        XCTAssertTrue(viewModel.showErrorMessage)
    }

    func testEmptyPasswordErrorMessage() {
        let viewModel = SignUpViewModel()
        viewModel.email = "test@example.com"
        viewModel.username = "testuser"
        viewModel.password = ""

        viewModel.validateAndSignUp()

        XCTAssertEqual(viewModel.errorMessage, "All fields are required.")
        XCTAssertTrue(viewModel.showErrorMessage)
    }
    
    func testUIElementsRenderCorrectly() throws {
        let view = SignUpPageView(isSignedUp: .constant(false))
        let inspectedView = try view.inspect()

        // Ensure TextFields for email and username exist
        XCTAssertNoThrow(try inspectedView.find(ViewType.TextField.self, where: { _ in true }), "Email TextField should render")
        XCTAssertNoThrow(try inspectedView.find(ViewType.TextField.self, where: { _ in true }), "Username TextField should render")

        // Ensure PasswordField exists
        XCTAssertNoThrow(try inspectedView.find(ViewType.SecureField.self), "PasswordField should render")

        // Ensure Button exists
        XCTAssertNoThrow(try inspectedView.find(ViewType.Button.self), "Sign Up button should render")
    }


}
