import XCTest
import SwiftUI
import ViewInspector
@testable import new_app


final class AddMedicationViewTests: XCTestCase {
    func testSaveMedicationToLocalFile() {
        // Arrange
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("medications.json")

        // Clean up any existing file
        try? FileManager.default.removeItem(at: fileURL)

        // Create a view with injected mock data
        let view = AddMedicationView(
            medicineName: "Ibuprofen",
            medicineDosage: "400mg",
            numberOfTablets: 20,
            prescribedDosage: "1 tablet every 6 hours",
            intakeFrequency: 4,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            expiryDate: Calendar.current.date(byAdding: .year, value: 1, to: Date())!
        )

        // Act
        view.saveMedicationToLocalFile()

        // Assert
        do {
            let data = try Data(contentsOf: fileURL)
            let medications = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]

            XCTAssertEqual(medications?.count, 1)
            XCTAssertEqual(medications?[0]["medicineName"] as? String, "Ibuprofen")
            XCTAssertEqual(medications?[0]["medicineDosage"] as? String, "400mg")
            XCTAssertEqual(medications?[0]["numberOfTablets"] as? Int, 20)
            XCTAssertEqual(medications?[0]["prescribedDosage"] as? String, "1 tablet every 6 hours")
            XCTAssertEqual(medications?[0]["intakeFrequency"] as? Int, 4)
        } catch {
            XCTFail("Failed to read back data from file: \(error.localizedDescription)")
        }
    }
    
    func testAddMedicationButtonDisabled() {
        // Arrange
        let view = AddMedicationView()

        // Act & Assert
        XCTAssertTrue(view.medicineName.isEmpty)
        XCTAssertTrue(view.medicineDosage.isEmpty)
        XCTAssertEqual(view.numberOfTablets, 0)
        XCTAssertTrue(view.prescribedDosage.isEmpty)
        XCTAssertEqual(view.intakeFrequency, 0)

        // Assert that the button is disabled
        let isButtonDisabled = view.medicineName.isEmpty || view.medicineDosage.isEmpty || view.numberOfTablets == 0 || view.prescribedDosage.isEmpty || view.intakeFrequency == 0
        XCTAssertTrue(isButtonDisabled)
    }

    

    func testValidDates() {
        // Arrange
        let view = AddMedicationView(
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        )

        // Act
        let isValid = view.startDate <= view.endDate

        // Assert
        XCTAssertTrue(isValid, "Start date should be before or equal to end date.")
    }
    
    func testJSONFileFormat() {
        // Arrange
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("medications.json")
        try? FileManager.default.removeItem(at: fileURL)

        let view = AddMedicationView(
            medicineName: "Ibuprofen",
            medicineDosage: "400mg",
            numberOfTablets: 20,
            prescribedDosage: "1 tablet every 6 hours",
            intakeFrequency: 4,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            expiryDate: Calendar.current.date(byAdding: .year, value: 1, to: Date())!
        )

        // Act
        view.saveMedicationToLocalFile()

        // Assert
        do {
            let data = try Data(contentsOf: fileURL)
            let medications = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
            XCTAssertNotNil(medications)
            XCTAssertEqual(medications?[0].keys.count, 8)
        } catch {
            XCTFail("Failed to read JSON file: \(error.localizedDescription)")
        }
    }


    
    func testUIRendering() throws {
            // Arrange
            let view = AddMedicationView()

            // Act & Assert
            XCTAssertNoThrow(try view.inspect().find(text: "Medicine Name"))
            XCTAssertNoThrow(try view.inspect().find(text: "Medicine Dosage"))
            XCTAssertNoThrow(try view.inspect().find(button: "Add Medication"))
        }
    
//    func testTextFieldInput() throws {
//            // Arrange
//            @State var medicineName = ""
//            let view = AddMedicationView(medicineName: medicineName)
//            let hostingController = UIHostingController(rootView: view)
//
//            // Act
//            let textField = try hostingController.inspect()
//                .find(ViewType.TextField.self) // Locate the TextField
//            try textField.setInput("Ibuprofen") // Simulate user input
//
//            // Assert
//            XCTAssertEqual(view.medicineName, "Ibuprofen", "The text input should be updated correctly.")
//        }
//


}
