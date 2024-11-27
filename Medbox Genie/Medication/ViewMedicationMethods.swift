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
                Text("Next Dose: \(calculateNextDoseTime(for: medication))")
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

    // Format the time as a user-friendly string
    private func formattedTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    // Calculate the next dose time
    private func calculateNextDoseTime(for medication: Medication) -> String {
        let calendar = Calendar.current
        let now = Date()

        // Base start time for the medication
        let startOfDay = calendar.startOfDay(for: now)
        let startTime = calendar.date(bySettingHour: medication.startHour, minute: medication.startMinute, second: 0, of: startOfDay)!

        // Calculate time intervals for doses
        let intervalBetweenDoses = 24 / medication.frequency
        var nextDose: Date?

        for doseIndex in 0..<medication.frequency {
            let doseTime = calendar.date(byAdding: .hour, value: doseIndex * intervalBetweenDoses, to: startTime)!

            if doseTime > now {
                nextDose = doseTime
                break
            }
        }

        // If all doses for today have passed, show the first dose of the next day
        if nextDose == nil {
            nextDose = calendar.date(byAdding: .day, value: 1, to: startTime)
        }

        // Format and return the next dose time
        if let nextDose = nextDose {
            return formattedTime(from: nextDose)
        } else {
            return "N/A"
        }
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

            Text("Frequency: \(medication.frequency) dose(s) per day")
            Text("Start Time: \(formattedTime(hour: medication.startHour, minute: medication.startMinute))")
            Text("Duration: \(medication.duration) day(s)")
            Text("Start Date: \(medication.startDate, style: .date)")
            Text("Expiry Date: \(medication.expiryDate, style: .date)")

            Spacer()
        }
        .padding()
        .navigationTitle("Medication Details")
    }

    private func formattedTime(hour: Int, minute: Int) -> String {
        let dateComponents = DateComponents(hour: hour, minute: minute)
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        if let date = Calendar.current.date(from: dateComponents) {
            return formatter.string(from: date)
        }
        return "\(hour):\(String(format: "%02d", minute))"
    }
}
