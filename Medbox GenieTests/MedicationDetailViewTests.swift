import XCTest
import SwiftUI
@testable import Medbox_Genie

final class MedicationDetailViewTests: XCTestCase {
    
    func testMedicationDetailView() {
        // Create a sample Medication object
        let medication = Medication(
            medicineName: "Test Medicine",
            medicineDosage: "500mg",
            numberOfTablets: 30,
            prescribedDosage: "1 tablet",
            intakeFrequency: "Twice a day",
            startDate: Date(),
            endDate: Date().addingTimeInterval(60*60*24*30), // 30 days from now
            expiryDate: Date().addingTimeInterval(60*60*24*365) // 1 year from now
        )
        
        // Create the MedicationDetailView with the sample medication
        let view = MedicationDetailView(medication: medication)
        
        // Render the view
        let viewController = UIHostingController(rootView: view)
        
        // Verify the view's content
        XCTAssertNotNil(viewController.view)
        
        // Check if the view contains the correct medication details
        let textElements = viewController.view.subviews.compactMap { $0 as? UILabel }
        XCTAssertTrue(textElements.contains { $0.text == "Test Medicine" })
        XCTAssertTrue(textElements.contains { $0.text == "Dosage: 500mg" })
        XCTAssertTrue(textElements.contains { $0.text == "Number of Tablets: 30" })
        XCTAssertTrue(textElements.contains { $0.text == "Prescribed Dosage: 1 tablet" })
        XCTAssertTrue(textElements.contains { $0.text == "Intake Frequency: Twice a day" })
        
        // Check date formatting
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        XCTAssertTrue(textElements.contains { $0.text == "Start Date: \(dateFormatter.string(from: medication.startDate))" })
        XCTAssertTrue(textElements.contains { $0.text == "End Date: \(dateFormatter.string(from: medication.endDate))" })
        XCTAssertTrue(textElements.contains { $0.text == "Expiry Date: \(dateFormatter.string(from: medication.expiryDate))" })
    }
}