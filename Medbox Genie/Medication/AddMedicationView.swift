import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import UserNotifications


struct AddMedicationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var medicineName: String = ""
    @State private var medicineDosage: String = ""
    @State private var numberOfTablets: Int = 0
    @State private var prescribedDosage: String = ""
    @State private var intakeFrequency: Int = 0
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var expiryDate: Date = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
    @State private var showErrorMessage = false
    @State private var errorMessage = ""
    
    var onSave: (() -> Void)?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Medication Details")) {
                    TextField("Medicine Name", text: $medicineName)
                    TextField("Medicine Dosage", text: $medicineDosage)
                    Stepper("Number of Tablets: \(numberOfTablets)", value: $numberOfTablets, in: 1...100)
                    TextField("Prescribed Dosage", text: $prescribedDosage)
                    Stepper("Intake Frequency: \(intakeFrequency)", value: $intakeFrequency, in: 1...10)
                }
                
                Section(header: Text("Dates")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
                    DatePicker("Expiry Date", selection: $expiryDate, in: Date()..., displayedComponents: .date)
                }
                
                Button("Add Medication") {
                    addMedicationToFirebase()
                }
                .disabled(medicineName.isEmpty || medicineDosage.isEmpty || numberOfTablets == 0 || prescribedDosage.isEmpty || intakeFrequency == 0)
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
        
        guard endDate > startDate else {
            errorMessage = "End date must be later than start date."
            showErrorMessage = true
            return
        }
        
        let medication = Medication(
            medicineName: medicineName,
            medicineDosage: medicineDosage,
            numberOfTablets: numberOfTablets,
            prescribedDosage: prescribedDosage,
            intakeFrequency: intakeFrequency,
            startDate: startDate,
            endDate: endDate,
            expiryDate: expiryDate
        )
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).collection("medications").addDocument(data: medication.toDictionary()) { error in
            if let error = error {
                errorMessage = "Failed to save medication: \(error.localizedDescription)"
                showErrorMessage = true
            } else {
                // Schedule the notification 2 minutes from now
                let notificationDate = Calendar.current.date(byAdding: .minute, value: 2, to: Date())!
                NotificationManager.shared.scheduleNotificationWithActions(for: self.medicineName, at: notificationDate, userId: userId)
                
                onSave?()
                dismiss()
            }
        }
    }
}
