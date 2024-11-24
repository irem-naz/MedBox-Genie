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
    @State private var selectedDays: Set<String> = [] // New state for reminder days
    @State private var showErrorMessage = false
    @State private var errorMessage = ""
    
    let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
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
                    VStack(alignment: .leading){
                        Text("Reminder Days").font(.headline)
                        ForEach(daysOfWeek, id: \.self){day in
                            HStack{
                                Text(day)
                                Spacer()
                                if selectedDays.contains(day){
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                        .onTapGesture{
                                            selectedDays.remove(day)
                                        }
                                }else{
                                    Image(systemName: "circle")
                                        .foregroundColor(.gray)
                                        .onTapGesture{
                                            selectedDays.insert(day)
                                        }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
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
            expiryDate: expiryDate,
            reminderDays: selectedDays
        )
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).collection("medications").addDocument(data: medication.toDictionary()) { error in
            if let error = error {
                errorMessage = "Failed to save medication: \(error.localizedDescription)"
                showErrorMessage = true
            } else {
                // Schedule Expiry Notification
                NotificationManager.shared.scheduleExpiryNotification(
                    for: medication.medicineName,
                    at: medication.expiryDate,
                    userId: userId
                )
                
                // Schedule Reminder Notifications
                NotificationManager.shared.scheduleReminderNotifications(
                    for: medication.medicineName,
                    on: medication.reminderDays,
                    after: medication.startDate,
                    until: medication.endDate, // Pass the `endDate` here
                    userId: userId
                )
                
                onSave?()
                dismiss()
            }
        }
    }
}
