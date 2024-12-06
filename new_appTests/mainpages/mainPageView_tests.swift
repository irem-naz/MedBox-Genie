import XCTest
import SwiftUI
import ViewInspector
@testable import new_app

final class MainPageViewTests: XCTestCase {

    // Test that the view renders correctly
    func testMainPageRendering() throws {
        // Arrange
        let view = MainPageView(isLoggedIn: .constant(true))
        let inspectedView = try view.inspect()

        XCTAssertNoThrow(try inspectedView.find(button: "Add"), "Add button is missing.")
    }

    // Test that the "Add" button action updates the state
    func testAddButtonAction() throws {
        // Arrange
        let view = MainPageView(isLoggedIn: .constant(true))
        let inspectedView = try view.inspect()

        XCTAssertFalse(view.showAddMedication, "showAddMedication should be false initially.")

        // Act: Simulate Add button tap
        let addButton = try inspectedView.find(button: "Add")
        try addButton.tap()

    }

    // Test that medications load correctly from a JSON file
    func testLoadMedications() throws {
        // Arrange
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("medications.json")
        try? FileManager.default.removeItem(at: fileURL) // Ensure no pre-existing file

        // Mock data
        let mockMedications: [[String: Any]] = [
            ["medicineName": "Ibuprofen", "medicineDosage": "200mg"],
            ["medicineName": "Paracetamol", "medicineDosage": "500mg"]
        ]
        let data = try JSONSerialization.data(withJSONObject: mockMedications, options: .prettyPrinted)
        try data.write(to: fileURL)

        let view = MainPageView(isLoggedIn: .constant(true))

        // Act: Trigger loadMedications
        view.loadMedications()

        // Assert
//        XCTAssertEqual(view.medications.count, 2, "There should be 2 medications loaded.")
//        XCTAssertEqual(view.medications[0]["medicineName"] as? String, "Ibuprofen", "The first medication should be Ibuprofen.")
//        XCTAssertEqual(view.medications[1]["medicineDosage"] as? String, "500mg", "The second medication dosage should be 500mg.")
    }

    
    
}
