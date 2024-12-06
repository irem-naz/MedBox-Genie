import SwiftUI

struct SurveyDetailView: View {
    @State var survey: Survey
    var medication: Medication
    @State  var userResponse: String = ""
    @State  var showAlert: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Survey for \(medication.medicineName)")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Survey Date: \(survey.date, formatter: dateFormatter)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // Survey Question and Response
            VStack(alignment: .leading, spacing: 16) {
                Text("Question 1: How are you feeling after taking this medication?")
                TextField("Type your response here", text: $userResponse)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            Spacer()
            
            Button(action: submitSurvey) {
                Text("Submit Survey")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .disabled(userResponse.isEmpty) // Disable button if no response
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Survey Submitted"),
                    message: Text("Your response has been saved."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .padding()
        .navigationBarTitle("Survey", displayMode: .inline)
    }
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    func submitSurvey() {
        let surveyFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("survey.json")
        
        var surveys: [[String: Any]] = []

        // Load surveys from the survey.json file
        if FileManager.default.fileExists(atPath: surveyFileURL.path) {
            do {
                let data = try Data(contentsOf: surveyFileURL)
                surveys = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] ?? []
            } catch {
                print("[ERROR] Failed to read survey file.")
                return
            }
        }

        // Find the matching survey and update it
        if let index = surveys.firstIndex(where: { ($0["medicationName"] as? String) == medication.medicineName &&
                                                   ($0["date"] as? String) == ISO8601DateFormatter().string(from: survey.date) }) {
            surveys[index]["isCompleted"] = true
            surveys[index]["responses"] = ["question1": userResponse] // Ensure this is a dictionary
        } else {
            print("[ERROR] Survey not found.")
            return
        }

        // Save the updated surveys back to the survey.json file
        do {
            let data = try JSONSerialization.data(withJSONObject: surveys, options: .prettyPrinted)
            try data.write(to: surveyFileURL, options: .atomic)
            print("[DEBUG] Survey updated successfully.")
            survey.isCompleted = true // Update local state
            showAlert = true // Show confirmation alert
        } catch {
            print("[ERROR] Failed to save survey file.")
        }
    }

}
