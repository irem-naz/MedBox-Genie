//import XCTest
//import ViewInspector
//@testable import new_app
//
//final class MainPageViewTests: XCTestCase {
//
//    private var fileURL: URL!
//
//    override func setUpWithError() throws {
//        fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("medications.json")
//        // Overwrite the file with an empty array
//        try JSONSerialization.data(withJSONObject: [], options: .prettyPrinted).write(to: fileURL)
//    }
//
//    override func tearDownWithError() throws {
//        // Clean up after tests
//        try? FileManager.default.removeItem(at: fileURL)
//    }
//
//
////    func testUIElementsRenderCorrectly() throws {
////        let view = MainPageView(isLoggedIn: .constant(true))
////        let inspectedView = try view.inspect()
////
////        XCTAssertNoThrow(try inspectedView.navigationView(), "NavigationView should render")
////        XCTAssertNoThrow(try inspectedView.navigationView().list(), "List should render")
////        XCTAssertNoThrow(
////            try inspectedView.navigationView().navigationBarItems().trailing().button(),
////            "Add button should render"
////        )
////    }
//
//    func testAddButtonTogglesSheet() throws {
//        var view = MainPageView(isLoggedIn: .constant(true)) // Use mutable view
//        let inspectedView = try view.inspect()
//
//        XCTAssertFalse(view.showAddMedication, "Initial state for showAddMedication should be false")
//        try inspectedView.navigationView().navigationBarItems().button(0).tap()
//        XCTAssertTrue(view.showAddMedication, "Tapping Add button should toggle showAddMedication to true")
//    }
//
////    func testMedicationsLoadCorrectly() throws {
////        let medications = [
////            ["medicineName": "Ibuprofen", "medicineDosage": "200mg"],
////            ["medicineName": "Paracetamol", "medicineDosage": "500mg"]
////        ]
////        let data = try JSONSerialization.data(withJSONObject: medications, options: .prettyPrinted)
////        try data.write(to: fileURL)
////
////        let view = MainPageView(isLoggedIn: .constant(true))
////        view.viewModel.loadMedications()
////
////        XCTAssertEqual(view.viewModel.medications.count, 2, "Loaded medications count should match")
////        XCTAssertEqual(view.viewModel.medications[0]["medicineName"] as? String, "Ibuprofen")
////        XCTAssertEqual(view.viewModel.medications[1]["medicineDosage"] as? String, "500mg")
////    }
//
//    func testEmptyMedicationsFile() throws {
//        let view = MainPageView(isLoggedIn: .constant(true))
//        view.viewModel.loadMedications()
//        XCTAssertTrue(view.viewModel.medications.isEmpty, "Medications array should be empty if file does not exist")
//    }
//
//    func testListRendersMedications() throws {
//        let medications = [
//            ["medicineName": "Ibuprofen", "medicineDosage": "200mg"],
//            ["medicineName": "Paracetamol", "medicineDosage": "500mg"]
//        ]
//        let data = try JSONSerialization.data(withJSONObject: medications, options: .prettyPrinted)
//        try data.write(to: fileURL)
//
//        let view = MainPageView(isLoggedIn: .constant(true))
//        view.viewModel.loadMedications()
//
//        let inspectedView = try view.inspect()
//        let list = try inspectedView.navigationView().list()
//
////        XCTAssertEqual(try list.forEach(0).vStack().text(0).string(), "Ibuprofen", "First medication name should match")
////        XCTAssertEqual(try list.forEach(1).vStack().text(0).string(), "Paracetamol", "Second medication name should match")
//    }
//}
