import XCTest
import SwiftUI
import ViewInspector
@testable import new_app

final class ViewMedicationTests: XCTestCase {

    func testMedicationRowRendering() throws {
        // Arrange
        let medication = Medication(
            medicineName: "Paracetamol",
            frequency: 3,
            startHour: 8,
            startMinute: 0,
            duration: 7,
            startDate: Date(),
            expiryDate: Calendar.current.date(byAdding: .year, value: 1, to: Date())!,
            totalPills: 21
        )
        let row = MedicationRow(medication: medication)

        // Act
        let inspectedRow = try row.inspect()

        // Assert
        XCTAssertNoThrow(try inspectedRow.find(ViewType.Text.self, where: { try $0.string() == "Paracetamol" }), "The medication name should render correctly.")
        XCTAssertNoThrow(try inspectedRow.find(ViewType.Text.self, where: { try $0.string().contains("Next Dose:") }), "The next dose time should render correctly.")
    }

    func testNextDoseCalculation() throws {
        // Arrange
        let medication = Medication(
            medicineName: "Ibuprofen",
            frequency: 2,
            startHour: 8,
            startMinute: 0,
            duration: 10,
            startDate: Date(),
            expiryDate: Calendar.current.date(byAdding: .year, value: 1, to: Date())!,
            totalPills: 20
        )
        let row = MedicationRow(medication: medication)

        // Act
        let nextDoseTime = row.calculateNextDoseTime(for: medication)

        // Assert
        XCTAssertFalse(nextDoseTime.isEmpty, "Next dose time should be calculated and not empty.")
    }

    func testMedicationDetailViewRendering() throws {
        // Arrange
        let medication = Medication(
            medicineName: "Amoxicillin",
            frequency: 2,
            startHour: 9,
            startMinute: 30,
            duration: 7,
            startDate: Date(),
            expiryDate: Calendar.current.date(byAdding: .year, value: 1, to: Date())!,
            totalPills: 14
        )
        let detailView = MedicationDetailView(medication: medication)

        // Act
        let inspectedView = try detailView.inspect()

        // Assert
        XCTAssertNoThrow(try inspectedView.find(ViewType.Text.self, where: { try $0.string() == "Amoxicillin" }), "The medication name should render correctly.")
        XCTAssertNoThrow(try inspectedView.find(ViewType.Text.self, where: { try $0.string().contains("Frequency: 2 dose(s) per day") }), "The frequency should render correctly.")
        XCTAssertNoThrow(try inspectedView.find(ViewType.Text.self, where: { try $0.string().contains("Duration: 7 day(s)") }), "The duration should render correctly.")
        XCTAssertNoThrow(try inspectedView.find(ViewType.Text.self, where: { try $0.string().contains("Start Date:") }), "The start date should render correctly.")
        XCTAssertNoThrow(try inspectedView.find(ViewType.Text.self, where: { try $0.string().contains("Expiry Date:") }), "The expiry date should render correctly.")
    }

    func testFormattedTime() {
        // Arrange
        let detailView = MedicationDetailView(medication: Medication(
            medicineName: "Ibuprofen",
            frequency: 3,
            startHour: 7,
            startMinute: 45,
            duration: 10,
            startDate: Date(),
            expiryDate: Calendar.current.date(byAdding: .year, value: 1, to: Date())!,
            totalPills: 30
        ))

        // Act
        let formattedTime = detailView.formattedTime(hour: 7, minute: 45)

        // Assert
    }
}

