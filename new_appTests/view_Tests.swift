//
//  ViewInspectionTests.swift
//  new_appTests
//
//  Created by Irem Naz Celen on 15.11.2024.
//
import XCTest
import SwiftUI
import ViewInspector
@testable import new_app


final class ViewInspectionTests: XCTestCase {

    func testLandingPageView() throws {
        let view = LandingPageView(isLoggedIn: .constant(false))
        let inspectedView = try view.inspect()

        // Check that it contains the LandingPageView when isLoggedIn is false
        XCTAssertNoThrow(try inspectedView.find(LandingPageView.self), "LandingPageView should render when not logged in")

        // Check that it contains the MainPageView when isLoggedIn is true
        let loggedInView = LandingPageView(isLoggedIn: .constant(true))
        let inspectedLoggedInView = try loggedInView.inspect()
        XCTAssertNoThrow(try inspectedLoggedInView.find(MainPageView.self), "MainPageView should render when logged in")
    }

    func testNotificationMenuView() throws {
        let view = NotificationMenuView(showNotifications: .constant(true))
        let inspectedView = try view.inspect()

        // Check that it contains the notification text
        let text = try inspectedView.find(text: "No notifications available.")
        XCTAssertEqual(try text.string(), "No notifications available.", "Notification text should render")

        // Check that the Close button exists and has the correct label
//        let button = try inspectedView.find(ViewType.Button.self)
//        let buttonText = try button.content().view(Text.self).string()
//        XCTAssertEqual(buttonText, "Close", "Close button should render with correct label")
    }


    func testProfileView() throws {
        let view = ProfileView()
        let inspectedView = try view.inspect()

        // Check that the profile placeholder text exists
        let text = try inspectedView.find(text: "Profile Placeholder")
        XCTAssertEqual(try text.string(), "Profile Placeholder", "Profile placeholder text should render")
    }
    
    
}
