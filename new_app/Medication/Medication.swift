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
    var medicineName: String
    var medicineDosage: String
    var numberOfTablets: Int
    var prescribedDosage: String
    var intakeFrequency: Int
    var startDate: Date
    var endDate: Date
    var expiryDate: Date

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
        self.startDate = startDate
        self.endDate = endDate
        self.expiryDate = expiryDate
    }
}
