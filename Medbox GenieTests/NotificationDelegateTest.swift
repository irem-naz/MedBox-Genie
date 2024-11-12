import XCTest
import UserNotifications
@testable import Medbox_Genie

final class NotificationDelegateTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        UNUserNotificationCenter.current().delegate = nil
    }

    func testWillPresentNotification() {
        let expectation = self.expectation(description: "Notification will present")
        
        let notification = UNNotification(
            request: UNNotificationRequest(
                identifier: "testNotification",
                content: UNNotificationContent(),
                trigger: nil
            ),
            date: Date()
        )
        
        NotificationDelegate.shared.userNotificationCenter(
            UNUserNotificationCenter.current(),
            willPresent: notification
        ) { options in
            XCTAssertTrue(options.contains(.banner))
            XCTAssertTrue(options.contains(.sound))
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDidReceiveResponse() {
        let expectation = self.expectation(description: "Notification did receive response")
        
        let content = UNMutableNotificationContent()
        content.title = "TestMedication"
        
        let notification = UNNotification(
            request: UNNotificationRequest(
                identifier: "testNotification",
                content: content,
                trigger: nil
            ),
            date: Date()
        )
        
        let response = UNNotificationResponse(
            notification: notification,
            actionIdentifier: "ACCEPT_ACTION"
        )
        
        NotificationDelegate.shared.userNotificationCenter(
            UNUserNotificationCenter.current(),
            didReceive: response
        ) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}

extension UNNotification {
    convenience init(request: UNNotificationRequest, date: Date) {
        self.init()
        self.setValue(request, forKey: "request")
        self.setValue(date, forKey: "date")
    }
}

extension UNNotificationResponse {
    convenience init(notification: UNNotification, actionIdentifier: String) {
        self.init()
        self.setValue(notification, forKey: "notification")
        self.setValue(actionIdentifier, forKey: "actionIdentifier")
    }
}