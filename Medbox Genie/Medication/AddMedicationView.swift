import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import UserNotifications

struct AddMedicationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var medicineName: String = ""
    @State private var frequency: Int = 1
    @State private var startTime: Date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())! // Default to 8:00 AM
    @State private var duration: Int = 10
    @State private var startDate: Date = Date()
    @State private var expiryDate: Date = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
    @State private var totalPills: Int = 0 // New state for total pills
    @State private var showErrorMessage = false
    @State private var errorMessage = ""
    
    var onSave: (() -> Void)?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Medication Details")) {
                    TextField("Medicine Name", text: $medicineName)
                    
                    Stepper("Frequency: \(frequency) dose(s) per day", value: $frequency, in: 1...6)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Start Time")
                            .font(.subheadline)
                        
                        // Time picker for start time
                        DatePicker("Select Time", selection: $startTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden() // Hides the label
                    }
                    
                    Stepper("Duration: \(duration) day(s)", value: $duration, in: 1...30)
                    
                    // New input field for total pills
                    Stepper("Total Pills: \(totalPills)", value: $totalPills, in: 1...500)
                }
                
                Section(header: Text("Dates")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("Expiry Date", selection: $expiryDate, in: startDate..., displayedComponents: .date)
                }
                
                Button("Add Medication") {
                    addMedicationToFirebase()
                }
                .disabled(medicineName.isEmpty || totalPills == 0) // Disable button if totalPills is not set
            }
            .navigationBarTitle("Add Medication", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
        .alert(isPresented: $showErrorMessage) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func addMedicationToFirebase() {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated"
            showErrorMessage = true
            return
        }

        let calendar = Calendar.current
        let startHour = calendar.component(.hour, from: startTime)
        let startMinute = calendar.component(.minute, from: startTime)

        // Create the medication object
        let medication = Medication(
            medicineName: medicineName,
            frequency: frequency,
            startHour: startHour,
            startMinute: startMinute,
            duration: duration,
            startDate: startDate,
            expiryDate: expiryDate,
            totalPills: totalPills
        )

        // Generate survey dates
        let surveyDates = calculateSurveyDates(for: medication)
        medication.surveys = surveyDates.map { Survey(date: $0, isCompleted: false, isPrompted: false, responses: [:]) }

        let db = Firestore.firestore()
        let medicationRef = db.collection("users").document(userId).collection("medications").document(medication.medicineName)

        // Save medication data
        medicationRef.setData(medication.toDictionary()) { error in
            if let error = error {
                errorMessage = "Failed to save medication: \(error.localizedDescription)"
                showErrorMessage = true
            } else {
                print("[DEBUG] Medication \(medication.medicineName) saved successfully.")

                // Save each survey in the `surveys` sub-collection
                for survey in medication.surveys {
                    let surveyRef = medicationRef.collection("surveys").document("\(survey.date)")
                    surveyRef.setData(survey.toDictionary()) { surveyError in
                        if let surveyError = surveyError {
                            print("[ERROR] Failed to save survey: \(surveyError.localizedDescription)")
                        } else {
                            print("[DEBUG] Survey saved for \(medication.medicineName) on \(survey.date).")
                        }
                    }
                }

                // Schedule notifications
                NotificationManager.shared.scheduleReminderNotifications(for: medication, userId: userId)
                NotificationManager.shared.scheduleExpiryNotification(for: medication, userId: userId)
                NotificationManager.shared.scheduleLowStockNotification(for: medication, userId: userId)
                NotificationManager.shared.scheduleSurveyNotifications(for: medication, userId: userId)

                print("All notifications scheduled for \(medication.medicineName)")
                onSave?()
                dismiss()
            }
        }
    }


    // Generate survey dates (every other day)
    private func calculateSurveyDates(for medication: Medication) -> [Date] {
        var dates: [Date] = []

        // TEST MODE: Schedule the first survey 2 minutes after the current time
        let testDate = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
        dates.append(testDate)

        // FUTURE MODE: Uncomment for production logic (every other day)
        /*
        var currentDate = Calendar.current.startOfDay(for: medication.startDate)
        for(int i = 0; i<duration; i+=2) {
            dates.append(currentDate)
            currentDate = Calendar.current.date(byAdding: .day, value: 2, to: currentDate)!
        }
        */

        return dates
    }

}
