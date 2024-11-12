import XCTest
import UserNotifications
@testable import Medbox_Genie

final class NotificationManagerTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRequestNotificationPermissionGranted() {
        let expectation = self.expectation(description: "Notification permission granted")
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            XCTAssertNil(error)
            XCTAssertTrue(granted)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testRequestNotificationPermissionDenied() {
        let expectation = self.expectation(description: "Notification permission denied")
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            XCTAssertNil(error)
            XCTAssertFalse(granted)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testSetupNotificationCategories() {
        NotificationManager.shared.setupNotificationCategories()
        
        UNUserNotificationCenter.current().getNotificationCategories { categories in
            XCTAssertTrue(categories.contains { $0.identifier == "MEDICATION_CATEGORY" })
        }
    }
    
    func testScheduleNotificationWithActions() {
        let medicationName = "TestMedication"
        let date = Date().addingTimeInterval(60) // 1 minute from now
        let userId = "TestUser"
        
        NotificationManager.shared.scheduleNotificationWithActions(for: medicationName, at: date, userId: userId)
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            XCTAssertTrue(requests.contains { $0.identifier == "\(userId)_\(medicationName)_expiry" })
        }
    }
}