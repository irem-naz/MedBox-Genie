import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SurveyDetailView: View {
    @State var survey: Survey
    var medication: Medication
    @State private var userResponse: String = ""
    @State private var showAlert: Bool = false

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
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    private func submitSurvey() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("[ERROR] User not authenticated.")
            return
        }

        let db = Firestore.firestore()
        let medicationRef = db.collection("users").document(userId).collection("medications").document(medication.medicineName)

        // Update survey in Firestore
        let surveyData: [String: Any] = [
            "isCompleted": true,
            "responses": ["question1": userResponse]
        ]
        
        medicationRef.collection("surveys").document("\(survey.date)").updateData(surveyData) { error in
            if let error = error {
                print("[ERROR] Failed to update survey: \(error.localizedDescription)")
            } else {
                print("[DEBUG] Survey updated for \(medication.medicineName) on \(survey.date)")
                survey.isCompleted = true // Update local state
                showAlert = true // Show confirmation alert
            }
        }
    }
}
