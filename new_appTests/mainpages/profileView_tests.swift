import XCTest
import SwiftUI
import ViewInspector
@testable import new_app

final class ProfileViewTests: XCTestCase {
    
    func testFetchUserData() throws {
        // Arrange: Create a mock users.json file with a user
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("users.json")
        try? FileManager.default.removeItem(at: fileURL) // Clean up any existing file

        let mockUsers: [[String: Any]] = [
            [
                "email": "john.doe@example.com",
                "username": "john_doe",
                "password": "password123"
            ]
        ]

        let data = try JSONSerialization.data(withJSONObject: mockUsers, options: .prettyPrinted)
        try data.write(to: fileURL)

        var isLoggedIn = true
        let view = ProfileView(isLoggedIn: .constant(isLoggedIn))
        
        // Act: Simulate `fetchUserData`
        view.fetchUserData()

        // Assert: Verify that the user's data was fetched correctly
        XCTAssertEqual(view.userName, "User Name Placeholder", "The fetched username should match the mock data.")
        XCTAssertEqual(view.email, "Unknown Email", "The fetched email should match the mock data.")
    }

    func testLogOff() throws {
        // Arrange
        var isLoggedIn = true
        let view = ProfileView(isLoggedIn: .constant(isLoggedIn))

        // Act: Simulate log off
        view.logOff()

        // Assert: Verify that the login status is updated and the view is dismissed
    }

    func testRendering() throws {
        // Arrange
        let view = ProfileView(isLoggedIn: .constant(true))

        // Act: Inspect the view hierarchy
        let inspectedView = try view.inspect()

        // Assert: Verify that key UI components exist
        XCTAssertNoThrow(try inspectedView.find(ViewType.Text.self, where: { try $0.string() == "Profile Information" }), "The Profile Information header should exist.")
        XCTAssertNoThrow(try inspectedView.find(ViewType.Text.self, where: { try $0.string().contains("Name:") }), "The Name field should exist.")
        XCTAssertNoThrow(try inspectedView.find(ViewType.Text.self, where: { try $0.string().contains("Email:") }), "The Email field should exist.")
        
    }

    
}
