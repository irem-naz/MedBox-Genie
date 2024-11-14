// MainPageView.swift
import SwiftUI

struct MainPageView: View {
    @Binding var isLoggedIn: Bool
    @State var showAddMedication = false
    @State var medications: [[String: Any]] = []

    var body: some View {
        NavigationView {
            List(medications.indices, id: \.self) { index in
                let medication = medications[index]
                VStack(alignment: .leading) {
                    Text(medication["medicineName"] as? String ?? "")
                        .font(.headline)
                    Text("Dosage: \(medication["medicineDosage"] as? String ?? "")")
                        .font(.subheadline)
                }
            }

            .navigationBarTitle("Medications")
            .navigationBarItems(
                trailing: Button("Add") {
                    showAddMedication = true
                }
            )
            .onAppear(perform: loadMedications)
        }
        .sheet(isPresented: $showAddMedication) {
            AddMedicationView(onSave: loadMedications)
        }
    }

    func loadMedications() {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("medications.json")

        guard let data = try? Data(contentsOf: fileURL),
              let loadedMedications = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
            medications = []
            return
        }

        medications = loadedMedications
    }
}

struct MainPage_Previews: PreviewProvider {
    static var previews: some View {
        MainPageView(isLoggedIn: .constant(true))
    }
}
