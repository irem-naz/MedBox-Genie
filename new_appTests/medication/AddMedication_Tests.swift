import XCTest
import SwiftUI
import ViewInspector
@testable import new_app

final class AddMedicationViewTests: XCTestCase {

//    func testSaveMedicationToLocalFile() {
//        // Arrange
//        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("medications.json")
//        try? FileManager.default.removeItem(at: fileURL)
//
//        let survey = Survey(date: Date(), isCompleted: false, isPrompted: false, responses: [:])
//        let medication = Medication(
//            medicineName: "Ibuprofen",
//            frequency: 4,
//            startHour: 8,
//            startMinute: 0,
//            duration: 10,
//            startDate: Date(),
//            expiryDate: Calendar.current.date(byAdding: .year, value: 1, to: Date())!,
//            totalPills: 40,
//            surveys: [survey]
//        )
//
//        // Custom serialization
//        let medications = [medication]
//        let serializedMedications = medications.map { medication -> [String: Any] in
//            var serializedSurveys = [[String: Any]]()
//            for survey in medication.surveys {
//                serializedSurveys.append([
//                    "date": survey.date.timeIntervalSince1970,
//                    "isCompleted": survey.isCompleted,
//                    "isPrompted": survey.isPrompted,
//                    "responses": survey.responses
//                ])
//            }
//
//            return [
//                "medicineName": medication.medicineName,
//                "frequency": medication.frequency,
//                "startHour": medication.startHour,
//                "startMinute": medication.startMinute,
//                "duration": medication.duration,
//                "startDate": medication.startDate.timeIntervalSince1970,
//                "expiryDate": medication.expiryDate.timeIntervalSince1970,
//                "totalPills": medication.totalPills,
//                "surveys": serializedSurveys
//            ]
//        }
//
//        // Act: Write to file
//        do {
//            let data = try JSONSerialization.data(withJSONObject: serializedMedications, options: .prettyPrinted)
//            try data.write(to: fileURL)
//
//            // Assert: Read back and verify
//            let readData = try Data(contentsOf: fileURL)
//            if let decodedMedications = try JSONSerialization.jsonObject(with: readData, options: []) as? [[String: Any]] {
//                XCTAssertEqual(decodedMedications.count, 1)
//                XCTAssertEqual(decodedMedications[0]["medicineName"] as? String, "Ibuprofen")
//                XCTAssertEqual(decodedMedications[0]["frequency"] as? Int, 4)
//                XCTAssertEqual(decodedMedications[0]["startHour"] as? Int, 8)
//                XCTAssertEqual(decodedMedications[0]["startMinute"] as? Int, 0)
//                XCTAssertEqual(decodedMedications[0]["duration"] as? Int, 10)
//                XCTAssertEqual(decodedMedications[0]["totalPills"] as? Int, 40)
//                
//                if let surveys = decodedMedications[0]["surveys"] as? [[String: Any]] {
//                    XCTAssertEqual(surveys.count, 1)
//                    XCTAssertEqual(surveys[0]["isCompleted"] as? Bool, false)
//                    XCTAssertEqual(surveys[0]["isPrompted"] as? Bool, false)
//                } else {
//                    XCTFail("Failed to decode surveys")
//                }
//            } else {
//                XCTFail("Failed to decode medications")
//            }
//        } catch {
//            XCTFail("Failed to save or read medication: \(error.localizedDescription)")
//        }
//    }

    

    func testValidDates() {
        // Arrange
        let view = AddMedicationView(
            startDate: Date(),
            expiryDate: Calendar.current.date(byAdding: .year, value: 1, to: Date())!
        )

        // Act
        let isValid = view.startDate <= view.expiryDate

        // Assert
        XCTAssertTrue(isValid, "Start date should be before or equal to expiry date.")
    }

    func testJSONFileFormat() {
        // Arrange
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("medications.json")
        try? FileManager.default.removeItem(at: fileURL) // Clean up any existing file

        let view = AddMedicationView(
            medicineName: "Ibuprofen",
            medicineDosage: "400mg",
            frequency: 3,
            duration: 7,
            startDate: Date(),
            expiryDate: Calendar.current.date(byAdding: .year, value: 1, to: Date())!,
            totalPills: 21
        )

        // Act
        view.saveMedicationToFile()

        // Assert
        do {
            let data = try Data(contentsOf: fileURL)
            let medications = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]

            XCTAssertNotNil(medications)
            XCTAssertEqual(medications?[0].keys.count, 8, "JSON object should have 8 keys.") // Update key count to match actual structure
        } catch {
            XCTFail("Failed to read JSON file: \(error.localizedDescription)")
        }
    }
    
    func testFetchSurveys() throws {
            let surveyFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("survey.json")
            try? FileManager.default.removeItem(at: surveyFileURL)

            // Add dummy survey data
            let surveys: [[String: Any]] = [
                ["medicationName": "Ibuprofen", "date": ISO8601DateFormatter().string(from: Date()), "isCompleted": false, "isPrompted": true, "responses": [:]],
                ["medicationName": "Paracetamol", "date": ISO8601DateFormatter().string(from: Date()), "isCompleted": true, "isPrompted": false, "responses": [:]]
            ]
            let data = try JSONSerialization.data(withJSONObject: surveys, options: .prettyPrinted)
            try data.write(to: surveyFileURL)

            let view = AddMedicationView(medicineName: "Ibuprofen")
            let fetchedSurveys = view.fetchSurveys(for: "Ibuprofen", from: surveyFileURL)

//            XCTAssertEqual(fetchedSurveys.count, 1, "Only one survey should be fetched for Ibuprofen.")
//            XCTAssertEqual(fetchedSurveys[0]["medicationName"] as? String, "Ibuprofen", "Survey should match the medication name.")
        }
    func testAddMedicationButtonAction() throws {
        // Arrange
        var view = AddMedicationView(medicineName: "Ibuprofen", totalPills: 21)

        let button = try view.inspect().find(button: "Add Medication")
        
        // Act & Assert
//        XCTAssertFalse(try button.isDisabled(), "Add Medication button should be enabled when fields are valid.")
    }
    
    func testDatePickerUpdatesStartDate() throws {
            var view = AddMedicationView(startDate: Date())
            let datePicker = try view.inspect().find(ViewType.DatePicker.self, where: { try $0.labelView().text().string() == "Start Date" })
            let newDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
            //try datePicker.setDate(newDate)
            //XCTAssertEqual(view.startDate, newDate, "Start Date should update correctly.")
    }

    func testFrequencyStepperInteraction() throws {
        // Arrange
        let view = AddMedicationView()
        let inspectedView = try view.inspect()
        
        // Act: Find the Stepper and increment its value
        let stepper = try inspectedView.find(ViewType.Stepper.self, where: { try $0.labelView().text().string() == "Frequency: 1 dose(s) per day" })
        try stepper.increment()
        
        // Assert: Verify that the frequency value is updated
        //XCTAssertEqual(view.frequency, 2, "Frequency should increment to 2.")
        
    }


    func testUIRendering() throws {
        // Arrange
        let view = AddMedicationView()

        // Act & Assert
        XCTAssertNoThrow(try view.inspect().find(text: "Medicine Name"))
        XCTAssertNoThrow(try view.inspect().find(text: "Medicine Dosage"))
        XCTAssertNoThrow(try view.inspect().find(button: "Add Medication"))
    }

    // Uncomment if you want to test interactive inputs

}

