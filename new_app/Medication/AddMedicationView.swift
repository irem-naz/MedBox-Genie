import SwiftUI

struct AddMedicationView: View {
    @Environment(\.dismiss) private var dismiss
    @State var medicineName: String = ""
    @State var medicineDosage: String = ""
    @State var numberOfTablets: Int = 0
    @State var prescribedDosage: String = ""
    @State var intakeFrequency: Int = 0
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    @State var expiryDate: Date = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
    @State var showErrorMessage = false
    @State var errorMessage = ""

    var onSave: (() -> Void)?

    var body: some View {
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
                saveMedicationToLocalFile()
            }
            .disabled(medicineName.isEmpty || medicineDosage.isEmpty || numberOfTablets == 0 || prescribedDosage.isEmpty || intakeFrequency == 0)
        }
        .alert(isPresented: $showErrorMessage) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }

    func saveMedicationToLocalFile() {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("medications.json")

        var medications: [[String: Any]] = []

        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                medications = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] ?? []
            } catch {
                return
            }
        }

        // Convert dates to string format
        let dateFormatter = ISO8601DateFormatter()
        let newMedication: [String: Any] = [
            "medicineName": medicineName,
            "medicineDosage": medicineDosage,
            "numberOfTablets": numberOfTablets,
            "prescribedDosage": prescribedDosage,
            "intakeFrequency": intakeFrequency,
            "startDate": dateFormatter.string(from: startDate),
            "endDate": dateFormatter.string(from: endDate),
            "expiryDate": dateFormatter.string(from: expiryDate)
        ]

        medications.append(newMedication)

        do {
            let data = try JSONSerialization.data(withJSONObject: medications, options: .prettyPrinted)
            try data.write(to: fileURL, options: .atomic)
            dismiss()
        } catch {
            errorMessage = "Failed to save file."
            showErrorMessage = true
        }
    }

}
