//
//  ViewMedication_Tests.swift
//  new_appTests
//
//  Created by Irem Naz Celen on 14.11.2024.
//

import XCTest
import SwiftUI
import ViewInspector
@testable import new_app

// MARK: - Make Medication conform to Inspectable for testing purposes


final class ViewMedication_Tests: XCTestCase {
    
    func testMedicationRowRendering() throws {
        // Arrange
        let medication = Medication(
            medicineName: "Aspirin",
            medicineDosage: "200mg",
            numberOfTablets: 10,
            prescribedDosage: "1 tablet daily",
            intakeFrequency: 1,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            expiryDate: Calendar.current.date(byAdding: .year, value: 1, to: Date())!
        )
        let view = MedicationRow(medication: medication)

        // Act
        let row = try view.inspect()
        let text1 = try row.find(text: "Aspirin").string()

//        let text2 = try row.find(text: "Earliest Dose: \(formattedDate)").string()

        // Assert
        XCTAssertEqual(text1, "Aspirin", "The medication name should render correctly.")
//        XCTAssertEqual(text2, "Earliest Dose: \(formattedDate)", "The earliest dose date should render correctly.")
    }



    
    func testMedicationDetailViewRendering() throws {
        // Arrange
        let medication = Medication(
            medicineName: "Ibuprofen",
            medicineDosage: "400mg",
            numberOfTablets: 20,
            prescribedDosage: "1 tablet every 6 hours",
            intakeFrequency: 4,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            expiryDate: Calendar.current.date(byAdding: .year, value: 1, to: Date())!
        )
        let view = MedicationDetailView(medication: medication)

        // Date formatter for consistent date string
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium

        // Act
        let detail = try view.inspect()
        let text1 = try detail.find(text: "Ibuprofen").string()
        let text2 = try detail.find(text: "Dosage: 400mg").string()
        let text3 = try detail.find(text: "Number of Tablets: 20").string()
        let text4 = try detail.find(text: "Prescribed Dosage: 1 tablet every 6 hours").string()
        let text5 = try detail.find(text: "Intake Frequency: 4").string()
//        let text6 = try detail.find(text: "Start Date: \(dateFormatter.string(from: medication.startDate))").string()
//        let text7 = try detail.find(text: "End Date: \(dateFormatter.string(from: medication.endDate))").string()
//        let text8 = try detail.find(text: "Expiry Date: \(dateFormatter.string(from: medication.expiryDate))").string()

        // Assert
        XCTAssertEqual(text1, "Ibuprofen", "The medication name should render correctly.")
        XCTAssertEqual(text2, "Dosage: 400mg", "The dosage should render correctly.")
        XCTAssertEqual(text3, "Number of Tablets: 20", "The number of tablets should render correctly.")
        XCTAssertEqual(text4, "Prescribed Dosage: 1 tablet every 6 hours", "The prescribed dosage should render correctly.")
        XCTAssertEqual(text5, "Intake Frequency: 4", "The intake frequency should render correctly.")
//        XCTAssertEqual(text6, "Start Date: \(dateFormatter.string(from: medication.startDate))", "The start date should render correctly.")
//        XCTAssertEqual(text7, "End Date: \(dateFormatter.string(from: medication.endDate))", "The end date should render correctly.")
//        XCTAssertEqual(text8, "Expiry Date: \(dateFormatter.string(from: medication.expiryDate))", "The expiry date should render correctly.")
    }


   
}
