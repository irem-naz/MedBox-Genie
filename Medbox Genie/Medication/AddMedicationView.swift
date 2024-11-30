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
        
        // Create the medication object with totalPills
        let medication = Medication(
            medicineName: medicineName,
            frequency: frequency,
            startHour: startHour,
            startMinute: startMinute,
            duration: duration,
            startDate: startDate,
            expiryDate: expiryDate,
            totalPills: totalPills // Pass totalPills
        )
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).collection("medications").addDocument(data: medication.toDictionary()) { error in
            if let error = error {
                errorMessage = "Failed to save medication: \(error.localizedDescription)"
                showErrorMessage = true
            } else {
                // Schedule notifications for the medication
                NotificationManager.shared.scheduleReminderNotifications(for: medication, userId: userId)
                NotificationManager.shared.scheduleExpiryNotification(for: medication, userId: userId)
                NotificationManager.shared.scheduleLowStockNotification(for: medication, userId: userId)
                onSave?()
                dismiss()
            }
        }
    }
}
