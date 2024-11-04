//
//  Medication.swift
//  Medbox Genie
//
//  Created by Irem Naz Celen on 4.11.2024.
//

import Foundation
import SwiftData

@Model
final class Medication {
    var medicineName: String          // Name of the medicine
    var medicineDosage: String        // Dosage description of the medicine
    var numberOfTablets: Int          // Number of tablets
    var prescribedDosage: String      // Prescribed dosage information
    var intakeFrequency: Int       // Frequency of intake (e.g., "twice daily")
    var startDate: Date
    var endDate: Date
    var startEndDate: DateInterval    // Start and end date of the medication course
    var expiryDate: Date              // Expiry date of the medication

    // Custom initializer to create a Medication with separate start and end dates for DateInterval
    init(medicineName: String,
         medicineDosage: String,
         numberOfTablets: Int,
         prescribedDosage: String,
         intakeFrequency: Int,
         startDate: Date,
         endDate: Date,
         expiryDate: Date) {
        
        self.medicineName = medicineName
        self.medicineDosage = medicineDosage
        self.numberOfTablets = numberOfTablets
        self.prescribedDosage = prescribedDosage
        self.intakeFrequency = intakeFrequency
        //you can use startEndDate.start and startEndDate.end to access the start and end dates
        self.startDate = startDate
        self.endDate = endDate
        self.startEndDate = DateInterval(start: startDate, end: endDate)
        self.expiryDate = expiryDate
    }
}
