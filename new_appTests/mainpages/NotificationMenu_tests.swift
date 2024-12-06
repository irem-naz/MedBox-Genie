import XCTest
import SwiftUI
import ViewInspector
@testable import new_app

final class NotificationsMenuViewTests: XCTestCase {
    
    func testNotificationsMenuViewRendering() throws {
        // Arrange
        let view = NotificationsMenuView(showNotifications: .constant(true))
        
        // Act
        let inspectedView = try view.inspect()
        
        // Assert
        XCTAssertNoThrow(try inspectedView.find(text: "Notifications"), "Header should render 'Notifications'")
    }
        
    func testFetchNotifications_EmptyFile() {
        // Arrange
        let surveyFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("survey.json")
        try? FileManager.default.removeItem(at: surveyFileURL)
        
        let view = NotificationsMenuView(showNotifications: .constant(true))
        
        // Act
        view.fetchNotifications()
        
        // Assert
        XCTAssertTrue(view.notifications.isEmpty, "Notifications should be empty when survey.json is not present.")
    }
        
    func testFetchNotifications_ValidSurveys() {
        // Arrange
        let surveyFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("survey.json")
        let surveyData: [[String: Any]] = [
            [
                "medicationName": "Ibuprofen",
                "date": ISO8601DateFormatter().string(from: Date()),
                "isCompleted": false,
                "isPrompted": true,
                "responses": [:]
            ],
            [
                "medicationName": "Paracetamol",
                "date": ISO8601DateFormatter().string(from: Date()),
                "isCompleted": true,
                "isPrompted": false,
                "responses": [:]
            ]
        ]
        
        if let data = try? JSONSerialization.data(withJSONObject: surveyData, options: .prettyPrinted) {
            try? data.write(to: surveyFileURL)
        }
        
        let view = NotificationsMenuView(showNotifications: .constant(true))
        
        // Act
        view.fetchNotifications()
        
    }
        
    func testFetchNotifications_InvalidSurveyFile() {
        // Arrange
        let surveyFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("survey.json")
        try? "invalid content".write(to: surveyFileURL, atomically: true, encoding: .utf8)
        
        let view = NotificationsMenuView(showNotifications: .constant(true))
        
        // Act
        view.fetchNotifications()
        
        // Assert
        XCTAssertTrue(view.notifications.isEmpty, "Notifications should be empty for invalid survey.json content.")
    }
        
    func testNotificationCardRendering() throws {
        // Arrange
        let date = Date()
        let card = NotificationCard(medicationName: "Ibuprofen", surveyDate: date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let expectedDateText = dateFormatter.string(from: date)
        
        // Act
        let inspectedCard = try card.inspect()
        
        // Assert
        XCTAssertNoThrow(try inspectedCard.find(text: "Ibuprofen"), "Card should display the medication name.")
        XCTAssertNoThrow(try inspectedCard.find(text: "Survey Due"), "Card should display 'Survey Due'.")
        XCTAssertNoThrow(try inspectedCard.find(text: expectedDateText), "Card should display the survey date.")
    }


}
