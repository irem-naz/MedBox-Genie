import XCTest
@testable import new_app

final class MedicationTests: XCTestCase {
    
    func testMedicationInitialization() {
        // Arrange
        let startDate = Date()
        let expiryDate = Calendar.current.date(byAdding: .year, value: 1, to: startDate)!
        let startHour = 8
        let startMinute = 0
        let duration = 10
        let totalPills = 30
        let surveys = [
            Survey(date: Calendar.current.date(byAdding: .day, value: 1, to: startDate)!, isCompleted: false, isPrompted: false, responses: [:])
        ]
        
        // Act
        let medication = Medication(
            medicineName: "Aspirin",
            frequency: 3,
            startHour: startHour,
            startMinute: startMinute,
            duration: duration,
            startDate: startDate,
            expiryDate: expiryDate,
            totalPills: totalPills,
            surveys: surveys
        )
        
        // Assert
        XCTAssertEqual(medication.medicineName, "Aspirin")
        XCTAssertEqual(medication.frequency, 3)
        XCTAssertEqual(medication.startHour, startHour)
        XCTAssertEqual(medication.startMinute, startMinute)
        XCTAssertEqual(medication.duration, duration)
        XCTAssertEqual(medication.startDate, startDate)
        XCTAssertEqual(medication.expiryDate, Calendar.current.startOfDay(for: expiryDate))
        XCTAssertEqual(medication.totalPills, totalPills)
        XCTAssertEqual(medication.surveys.count, 1)
        XCTAssertEqual(medication.surveys.first?.isCompleted, false)
        XCTAssertEqual(medication.surveys.first?.isPrompted, false)
    }
}
