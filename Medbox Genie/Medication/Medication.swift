import Foundation
import FirebaseFirestore

final class Medication {
    var medicineName: String          // Name of the medicine
    var medicineDosage: String        // Dosage description of the medicine
    var numberOfTablets: Int          // Number of tablets
    var prescribedDosage: String      // Prescribed dosage information
    var intakeFrequency: Int          // Frequency of intake (e.g., "twice daily")
    var startDate: Date
    var endDate: Date
    var expiryDate: Date              // Expiry date (only date portion stored)
    var reminderDays: Set<String> // Example: ["Mon", "Wed", "Fri"]

    init(medicineName: String,
         medicineDosage: String,
         numberOfTablets: Int,
         prescribedDosage: String,
         intakeFrequency: Int,
         startDate: Date,
         endDate: Date,
         expiryDate: Date,
         reminderDays: Set<String> = []) {
        
        
        
        
        self.medicineName = medicineName
        self.medicineDosage = medicineDosage
        self.numberOfTablets = numberOfTablets
        self.prescribedDosage = prescribedDosage
        self.intakeFrequency = intakeFrequency
        self.startDate = startDate
        self.endDate = endDate
        self.expiryDate = Calendar.current.startOfDay(for: expiryDate) // Store only date
        self.reminderDays = reminderDays
    }
    
    // Convert the medication object into a Firestore-compatible dictionary
    func toDictionary() -> [String: Any] {
        return [
            "medicineName": medicineName,
            "medicineDosage": medicineDosage,
            "numberOfTablets": numberOfTablets,
            "prescribedDosage": prescribedDosage,
            "intakeFrequency": intakeFrequency,
            "startDate": Timestamp(date: startDate),  // Firestore-compatible
            "endDate": Timestamp(date: endDate),      // Firestore-compatible
            "expiryDate": Timestamp(date: expiryDate), // Store as Firestore timestamp
            "reminderDays": Array(reminderDays)
        ]
    }

    // Parse Firestore data back into a Medication object
    static func fromDictionary(_ data: [String: Any]) -> Medication? {
        guard let medicineName = data["medicineName"] as? String,
              let medicineDosage = data["medicineDosage"] as? String,
              let numberOfTablets = data["numberOfTablets"] as? Int,
              let prescribedDosage = data["prescribedDosage"] as? String,
              let intakeFrequency = data["intakeFrequency"] as? Int,
              let startDate = (data["startDate"] as? Timestamp)?.dateValue(),
              let endDate = (data["endDate"] as? Timestamp)?.dateValue(),
              let expiryDate = (data["expiryDate"] as? Timestamp)?.dateValue() else {
            print("[ERROR] Missing or invalid fields while parsing Medication.")
            return nil
        }
        
        return Medication(
            medicineName: medicineName,
            medicineDosage: medicineDosage,
            numberOfTablets: numberOfTablets,
            prescribedDosage: prescribedDosage,
            intakeFrequency: intakeFrequency,
            startDate: startDate,
            endDate: endDate,
            expiryDate: expiryDate
        )
    }
}
