import XCTest
import SwiftUI
import ViewInspector
@testable import new_app


final class SurveyDetailViewTests: XCTestCase {
    
    func testSurveyDetailViewRendering() throws {
        // Arrange
        let survey = Survey(
            date: Date(),
            isCompleted: false,
            isPrompted: false,
            responses: [:]
        )
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
        let view = SurveyDetailView(survey: survey, medication: medication)

        // Debugging: Print all visible texts
        let visibleTexts = try view.inspect().findAll(ViewType.Text.self).map { try $0.string() }
        print("Visible Texts: \(visibleTexts)")

        // Act
        let titleText = try view.inspect().find(ViewType.Text.self, where: { try $0.string() == "Survey for Ibuprofen" }).string()

        // Assert
        XCTAssertEqual(titleText, "Survey for Ibuprofen", "Title should display the correct medication name.")
    }



    
    func testSubmitSurveyUpdatesFile() {
        let surveyFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("survey.json")
        try? FileManager.default.removeItem(at: surveyFileURL)

        let surveyDate = Date() // Current date
        let survey = Survey(
            date: surveyDate,
            isCompleted: false,
            isPrompted: false,
            responses: [:]
        )
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

        // Pre-populate survey.json with a survey
        let prepopulatedSurveyDate = ISO8601DateFormatter().string(from: surveyDate)
        let surveyData: [[String: Any]] = [
            [
                "medicationName": medication.medicineName,
                "date": prepopulatedSurveyDate,
                "isCompleted": false,
                "isPrompted": false,
                "responses": [:]
            ]
        ]
        if let data = try? JSONSerialization.data(withJSONObject: surveyData, options: .prettyPrinted) {
            try? data.write(to: surveyFileURL)
        }

        // Debugging pre-populated file content
        if let fileContent = try? String(contentsOf: surveyFileURL) {
            print("[DEBUG] Pre-populated file content: \(fileContent)")
        }

        let view = SurveyDetailView(survey: survey, medication: medication)
        view.userResponse = "I'm feeling better now."

        // Act
        view.submitSurvey()

        // Assert
        do {
            let data = try Data(contentsOf: surveyFileURL)
            if let surveys = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                print("[DEBUG] Surveys after update: \(surveys)") // Debugging log
                XCTAssertEqual(surveys.count, 1)
                XCTAssertEqual(surveys[0]["medicationName"] as? String, "Ibuprofen")
                XCTAssertEqual(surveys[0]["isCompleted"] as? Bool, true)

                // Check if "responses" is correctly updated
                if let responses = surveys[0]["responses"] as? [String: String] {
                    
                } else {
                    XCTFail("Responses field not updated correctly.")
                }
            } else {
                XCTFail("Failed to decode surveys.")
            }
        } catch {
            XCTFail("Failed to read survey file: \(error.localizedDescription)")
        }
    }


    
    func testSubmitSurveyNotFound() {
        // Arrange
        let surveyFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("survey.json")
        try? FileManager.default.removeItem(at: surveyFileURL) // Ensure no pre-existing file

        let surveyDate = Date()
        let survey = Survey(
            date: surveyDate,
            isCompleted: false,
            isPrompted: false,
            responses: [:]
        )
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

        let view = SurveyDetailView(survey: survey, medication: medication)
        view.userResponse = "Feeling okay."

        // Act
        view.submitSurvey()

        // Assert
        XCTAssertFalse(view.survey.isCompleted, "Survey should not be marked as completed if not found in the file.")
    }
}
