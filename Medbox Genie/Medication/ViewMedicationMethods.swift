//
//  ViewMedicationMethods.swift
//  Medbox Genie
//
//  Created by Irem Naz Celen on 5.11.2024.
//

import SwiftUI

// this is the list view in the main page
// this has to be developed further to correctly list the earliest dose of medication
struct MedicationRow: View {
    let medication: Medication

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(medication.medicineName)
                    .font(.headline)
                Text("Earliest Dose: \(medication.startDate, style: .date)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}

// this is the detail view when you click on the list view of the medication
struct MedicationDetailView: View {
    let medication: Medication

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(medication.medicineName)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Dosage: \(medication.medicineDosage)")
            Text("Number of Tablets: \(medication.numberOfTablets)")
            Text("Prescribed Dosage: \(medication.prescribedDosage)")
            Text("Intake Frequency: \(medication.intakeFrequency)")
            
            Text("Start Date: \(medication.startDate, style: .date)")
            Text("End Date: \(medication.endDate, style: .date)")
            Text("Expiry Date: \(medication.expiryDate, style: .date)")
            
            Spacer()
        }
        .padding()
        .navigationTitle("Medication Details")
    }
}
