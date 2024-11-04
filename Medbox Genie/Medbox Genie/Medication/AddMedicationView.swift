//
//  AddMedicationView.swift
//  Medbox Genie
//
//  Created by Irem Naz Celen on 4.11.2024.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

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
                    Stepper("Number of Tablets: \(numberOfTablets)", value: $numberOfTablets, in: 0...100)
                    TextField("Prescribed Dosage", text: $prescribedDosage)
                    Stepper("Intake Frequency: \(intakeFrequency)", value: $intakeFrequency, in: 0...100)
                }
                
                Section(header: Text("Dates")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                    DatePicker("Expiry Date", selection: $expiryDate, displayedComponents: .date)
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
        guard endDate > startDate else {
                errorMessage = "End date must be later than start date."
                showErrorMessage = true
                return
        }
        
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated"
            showErrorMessage = true
            return
        }
        
        let db = Firestore.firestore()
        let medicationData: [String: Any] = [
            "medicineName": medicineName,
            "medicineDosage": medicineDosage,
            "numberOfTablets": numberOfTablets,
            "prescribedDosage": prescribedDosage,
            "intakeFrequency": intakeFrequency,
            "startDate": Timestamp(date: startDate),
            "endDate": Timestamp(date: endDate),
            "expiryDate": Timestamp(date: expiryDate)
        ]
        
        db.collection("users").document(userId).collection("medications").addDocument(data: medicationData) { error in
            if let error = error {
                errorMessage = "Failed to save medication: \(error.localizedDescription)"
                showErrorMessage = true
            } else {
                onSave?()
                dismiss() // Close the view after saving
            }
        }
    }
}
