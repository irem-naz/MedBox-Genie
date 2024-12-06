import SwiftUI

struct AddMedicationView: View {
    @Environment(\.dismiss)  var dismiss
    @State var medicineName: String = ""
    @State var medicineDosage: String = ""
    @State var frequency: Int = 1
    @State var duration: Int = 10
    @State var startDate: Date = Date()
    @State var expiryDate: Date = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
    @State var totalPills: Int = 0
    @State var showErrorMessage: Bool = false
    @State var errorMessage: String = ""

    var onSave: (() -> Void)?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Medication Details")) {
                    TextField("Medicine Name", text: $medicineName)
                    TextField("Medicine Dosage", text: $medicineDosage)
                    
                    Stepper("Frequency: \(frequency) dose(s) per day", value: $frequency, in: 1...6)
                    
                    Stepper("Duration: \(duration) day(s)", value: $duration, in: 1...30)
                    
                    Stepper("Total Pills: \(totalPills)", value: $totalPills, in: 1...500)
                }

                Section(header: Text("Dates")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("Expiry Date", selection: $expiryDate, in: startDate..., displayedComponents: .date)
                }

                Button("Add Medication") {
                    saveMedicationToFile()
                }
                .disabled(medicineName.isEmpty || totalPills == 0 || medicineDosage.isEmpty)
            }
            .navigationBarTitle("Add Medication", displayMode: .inline)
//            .navigationBarItems(trailing: Button("Cancel") {
//                dismiss()
            //})
        }
        
    }

    func saveMedicationToFile() {
        let medicationFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("medications.json")
        let surveyFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("survey.json")

        var medications: [[String: Any]] = []

        // Load existing medications
        if FileManager.default.fileExists(atPath: medicationFileURL.path) {
            do {
                let data = try Data(contentsOf: medicationFileURL)
                medications = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] ?? []
            } catch {
                errorMessage = "Failed to read existing file."
                showErrorMessage = true
                return
            }
        }

        // Load surveys
        let surveys = fetchSurveys(for: medicineName, from: surveyFileURL)

        // Convert dates to string
        let dateFormatter = ISO8601DateFormatter()
        let medication: [String: Any] = [
            "medicineName": medicineName,
            "medicineDosage": medicineDosage,
            "frequency": frequency,
            "duration": duration,
            "startDate": dateFormatter.string(from: startDate),
            "expiryDate": dateFormatter.string(from: expiryDate),
            "totalPills": totalPills,
            "surveys": surveys
        ]

        medications.append(medication)

        // Save to file
        do {
            let data = try JSONSerialization.data(withJSONObject: medications, options: .prettyPrinted)
            try data.write(to: medicationFileURL, options: .atomic)
            onSave?()
            dismiss()
        } catch {
            errorMessage = "Failed to save file."
            showErrorMessage = true
        }
    }

    func fetchSurveys(for medicineName: String, from surveyFileURL: URL) -> [[String: Any]] {
        var surveys: [[String: Any]] = []

        if FileManager.default.fileExists(atPath: surveyFileURL.path) {
            do {
                let data = try Data(contentsOf: surveyFileURL)
                let allSurveys = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] ?? []
                surveys = allSurveys.filter { $0["medicationName"] as? String == medicineName }
            } catch {
                print("[ERROR] Failed to fetch surveys for \(medicineName): \(error.localizedDescription)")
            }
        }

        return surveys
    }

    
}
