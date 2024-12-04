import XCTest
import UserNotifications
@testable import Medbox_Genie// Replace with your app's module name


// MARK: - Mock Class for Testing
class MockUserNotificationCenter: UserNotificationCenterProtocol {
    var authorizationGranted = false
    var addedRequests = [UNNotificationRequest]()
    var notificationCategories = Set<UNNotificationCategory>()
    var removeIdentifiers = [String]()

    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void) {
        completionHandler(authorizationGranted, nil)
    }

    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?) {
        print("[DEBUG] Adding notification request: \(request.identifier)")
        addedRequests.append(request)
        completionHandler?(nil)
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        print("[DEBUG] Removing notification requests: \(identifiers)")
        removeIdentifiers.append(contentsOf: identifiers)
        addedRequests.removeAll { identifiers.contains($0.identifier) }
    }

    func setNotificationCategories(_ categories: Set<UNNotificationCategory>) {
        print("[DEBUG] Setting notification categories: \(categories)")
        notificationCategories = categories
    }
}

// MARK: - NotificationManagerTests
final class NotificationManagerTests: XCTestCase {
    var mockCenter: MockUserNotificationCenter!
    var notificationManager: NotificationManager!
    
    override func setUp() {
        super.setUp()
        mockCenter = MockUserNotificationCenter()
        notificationManager = NotificationManager(mockCenter: mockCenter) // Inject mock center
    }
    
    override func tearDown() {
        mockCenter = nil
        notificationManager = nil
        super.tearDown()
    }
    
    func testRequestNotificationPermission_granted() {
        // Simulate permission granted
        mockCenter.authorizationGranted = true
        
        notificationManager.requestNotificationPermission()
        
        XCTAssertEqual(mockCenter.notificationCategories.count, 1)
    }
    
    func testRequestNotificationPermission_denied() {
        // Simulate permission denied
        mockCenter.authorizationGranted = false
        
        notificationManager.requestNotificationPermission()
        
        XCTAssertEqual(mockCenter.notificationCategories.count, 0)
    }
    
    func testScheduleExpiryNotification() {
        let medication = Medication(
            medicineName: "TestMed",
            frequency: 1,
            startHour: 9,
            startMinute: 0,
            duration: 1,
            startDate: Date(),
            expiryDate: Calendar.current.date(byAdding: .minute, value: 2, to: Date())!,
            totalPills: 10
        )
        
        let userId = "testUser"
        notificationManager.scheduleExpiryNotification(for: medication, userId: userId)
        
        XCTAssertEqual(mockCenter.addedRequests.count, 1, "Expected 1 notification request to be added.")
        guard let request = mockCenter.addedRequests.first else {
            XCTFail("No notification request was added.")
            return
        }
        
        XCTAssertEqual(request.content.title, "Medication Expiry Alert", "Notification title is incorrect.")
        XCTAssertEqual(request.identifier, "\(userId)_\(medication.medicineName)_expiry", "Notification identifier is incorrect.")
    }
    
    func testScheduleLowStockNotification() {
        let medication = Medication(
            medicineName: "TestMed",
            frequency: 1, // 1 dose per day
            startHour: 9,
            startMinute: 0,
            duration: 1, // 1 day
            startDate: Date(), // Current date
            expiryDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
            totalPills: 3 // Critically low stock at start
        )

        let userId = "testUser"
        print("[DEBUG] Starting testScheduleLowStockNotification with \(medication.totalPills) pills.")
        notificationManager.scheduleLowStockNotification(for: medication, userId: userId)

        XCTAssertEqual(mockCenter.addedRequests.count, 1, "Expected 1 low stock notification request to be added.")

        guard let request = mockCenter.addedRequests.first else {
            XCTFail("No low stock notification request was added.")
            return
        }

        XCTAssertEqual(request.content.title, "Low Stock Alert", "Notification title is incorrect.")
        XCTAssertEqual(
            request.content.body,
            "You have critically low stock of \(medication.medicineName). Only 3 pill(s) available. Please refill soon!",
            "Notification body is incorrect."
        )


        XCTAssertEqual(
            request.identifier,
            "\(userId)_\(medication.medicineName)_lowstock",
            "Notification identifier is incorrect."
        )
    }
    
    func testScheduleLowStockNotification_stockFallsToThreshold() {
        // Medication setup: starts with stock > 3 but will eventually fall to 3 during usage
        let medication = Medication(
            medicineName: "TestMed",
            frequency: 1, // 1 dose per day
            startHour: 9,
            startMinute: 0,
            duration: 5, // 5 days
            startDate: Date(), // Current date
            expiryDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
            totalPills: 5 // Starts with 5 pills; stock falls to 3 on day 3
        )

        let userId = "testUser"
        print("[DEBUG] Starting testScheduleLowStockNotification_stockFallsToThreshold with \(medication.totalPills) pills.")

        // Call the method to schedule the low stock notification
        notificationManager.scheduleLowStockNotification(for: medication, userId: userId)

        // Assert that one low stock notification is added
        XCTAssertEqual(mockCenter.addedRequests.count, 1, "Expected 1 low stock notification request to be added.")

        // Validate notification request
        guard let request = mockCenter.addedRequests.first else {
            XCTFail("No low stock notification request was added.")
            return
        }

        // Check the notification content
        XCTAssertEqual(request.content.title, "Low Stock Alert", "Notification title is incorrect.")
        XCTAssertEqual(
            request.content.body,
            "You have low stock of \(medication.medicineName). Only 3 pill(s) left. Please refill soon!",
            "Notification body is incorrect."
        )

        // Validate the identifier
        XCTAssertEqual(
            request.identifier,
            "\(userId)_\(medication.medicineName)_lowstock",
            "Notification identifier is incorrect."
        )

        // Validate the trigger date matches the date when stock reaches 3
        let calendar = Calendar.current
        let expectedTriggerDate = calendar.date(byAdding: .day, value: 2, to: medication.startDate)! // Day 3 (stock = 3)
        let expectedComponents = calendar.dateComponents([.year, .month, .day], from: expectedTriggerDate)
        let triggerComponents = (request.trigger as? UNCalendarNotificationTrigger)?.dateComponents

        XCTAssertEqual(triggerComponents?.year, expectedComponents.year, "Trigger year is incorrect.")
        XCTAssertEqual(triggerComponents?.month, expectedComponents.month, "Trigger month is incorrect.")
    }
    
    func testScheduleSurveyNotifications() {
        // Medication setup with surveys
        let medication = Medication(
            medicineName: "TestMed",
            frequency: 1,
            startHour: 9,
            startMinute: 0,
            duration: 5, // 5 days
            startDate: Date(),
            expiryDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
            totalPills: 10,
            surveys: [
                Survey(
                    date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
                    isCompleted: false,
                    isPrompted: false,
                    responses: [:]
                ),
                Survey(
                    date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
                    isCompleted: true,
                    isPrompted: true,
                    responses: ["Q1": "Yes"]
                ),
                Survey(
                    date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
                    isCompleted: false,
                    isPrompted: false,
                    responses: [:]
                )
            ]
        )

        let userId = "testUser"

        // Call the method to schedule survey notifications
        notificationManager.scheduleSurveyNotifications(for: medication, userId: userId)

        // Validate that notifications are only scheduled for incomplete surveys
        XCTAssertEqual(mockCenter.addedRequests.count, 2, "Expected 2 notifications to be scheduled for incomplete surveys.")

        // Validate the first survey notification
        guard mockCenter.addedRequests.count >= 2 else {
            XCTFail("Insufficient notifications scheduled.")
            return
        }

        let firstSurveyRequest = mockCenter.addedRequests[0]
        XCTAssertEqual(firstSurveyRequest.content.title, medication.medicineName, "Notification title is incorrect for the first survey.")
        XCTAssertEqual(firstSurveyRequest.content.body, "", "Notification body should be empty for the first survey.")
        XCTAssertEqual(
            firstSurveyRequest.identifier,
            "\(userId)_\(medication.medicineName)_survey_\(medication.surveys[0].date)",
            "Notification identifier is incorrect for the first survey."
        )

        // Validate the second survey notification
        let secondSurveyRequest = mockCenter.addedRequests[1]
        XCTAssertEqual(secondSurveyRequest.content.title, medication.medicineName, "Notification title is incorrect for the second survey.")
        XCTAssertEqual(secondSurveyRequest.content.body, "", "Notification body should be empty for the second survey.")
        XCTAssertEqual(
            secondSurveyRequest.identifier,
            "\(userId)_\(medication.medicineName)_survey_\(medication.surveys[2].date)",
            "Notification identifier is incorrect for the second survey."
        )

        // Validate the trigger date of the first survey
        let calendar = Calendar.current
        let expectedTriggerDate1 = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: medication.surveys[0].date)
        let actualTrigger1 = (firstSurveyRequest.trigger as? UNCalendarNotificationTrigger)?.dateComponents
        XCTAssertEqual(expectedTriggerDate1, actualTrigger1, "Trigger date is incorrect for the first survey.")

        // Validate the trigger date of the second survey
        let expectedTriggerDate2 = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: medication.surveys[2].date)
        let actualTrigger2 = (secondSurveyRequest.trigger as? UNCalendarNotificationTrigger)?.dateComponents
        XCTAssertEqual(expectedTriggerDate2, actualTrigger2, "Trigger date is incorrect for the second survey.")
    }



    func testScheduleReminderNotifications() {
        // Medication setup
        let medication = Medication(
            medicineName: "TestMed",
            frequency: 3, // 3 doses per day
            startHour: 8,
            startMinute: 0,
            duration: 1, // 1 day
            startDate: Date(), // Assume current time
            expiryDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
            totalPills: 6
        )
        
        let userId = "testUser"
        notificationManager.scheduleReminderNotifications(for: medication, userId: userId)
        
        // Assert correct number of requests
        XCTAssertEqual(mockCenter.addedRequests.count, 3, "Expected 3 notification requests to be added.")
        
        // Validate each notification
        for (index, request) in mockCenter.addedRequests.enumerated() {
            let requestContent = request.content
            
            XCTAssertEqual(requestContent.title, "Medication Reminder", "Notification title is incorrect for request \(index).")
            
            // Calculate expected dose time
            let calendar = Calendar.current
            let expectedDoseTime = calendar.date(bySettingHour: (medication.startHour + index * (24 / medication.frequency)) % 24, minute: medication.startMinute, second: 0, of: medication.startDate)!
            
            let expectedIdentifier = "\(userId)_\(medication.medicineName)_\(expectedDoseTime)"
            
            // Validate identifier
            XCTAssertEqual(request.identifier, expectedIdentifier, "Notification identifier is incorrect for request \(index).")
            
            // Validate notification body
            XCTAssertEqual(
                requestContent.body,
                "Time to take your medication: \(medication.medicineName). Pills left: \(medication.totalPills - index - 1).",
                "Notification body is incorrect for request \(index)."
            )
        }
    }
}
