import XCTest
@testable import new_app

final class MedicationTests: XCTestCase {

    func testMedicationInitialization() {
        // Arrange
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 10, to: startDate)!
        let expiryDate = Calendar.current.date(byAdding: .year, value: 1, to: startDate)!
        
        // Act
        let medication = Medication(
            medicineName: "Aspirin",
            medicineDosage: "200mg",
            numberOfTablets: 30,
            prescribedDosage: "1 tablet daily",
            intakeFrequency: 1,
            startDate: startDate,
            endDate: endDate,
            expiryDate: expiryDate
        )
        
        // Assert
        XCTAssertEqual(medication.medicineName, "Aspirin")
        XCTAssertEqual(medication.medicineDosage, "200mg")
        XCTAssertEqual(medication.numberOfTablets, 30)
        XCTAssertEqual(medication.prescribedDosage, "1 tablet daily")
        XCTAssertEqual(medication.intakeFrequency, 1)
        XCTAssertEqual(medication.startDate, startDate)
        XCTAssertEqual(medication.endDate, endDate)
        XCTAssertEqual(medication.expiryDate, expiryDate)
    }
}
