import Foundation
import FirebaseFirestore

final class Medication {
    var medicineName: String          // Name of the medicine
    var frequency: Int                // Doses per day (e.g., 1, 2, 3, 4, 6)
    var startHour: Int                // Hour for the first dose (e.g., 8 for 8:00 AM)
    var startMinute: Int              // Minute for the first dose (e.g., 15 for 8:15 AM)
    var duration: Int                 // Duration of medication in days
    var startDate: Date               // Start date for the medication
    var expiryDate: Date              // Expiry date for the medication
    var totalPills: Int               // Total number of pills in the package

    init(medicineName: String,
         frequency: Int,
         startHour: Int,
         startMinute: Int,
         duration: Int,
         startDate: Date,
         expiryDate: Date,
         totalPills: Int) {
        self.medicineName = medicineName
        self.frequency = frequency
        self.startHour = startHour
        self.startMinute = startMinute
        self.duration = duration
        self.startDate = startDate
        self.expiryDate = Calendar.current.startOfDay(for: expiryDate) // Store only the date
        self.totalPills = totalPills
    }
    
    // Convert the medication object into a Firestore-compatible dictionary
    func toDictionary() -> [String: Any] {
        return [
            "medicineName": medicineName,
            "frequency": frequency,
            "startHour": startHour,
            "startMinute": startMinute,
            "duration": duration,
            "startDate": Timestamp(date: startDate),  // Firestore-compatible
            "expiryDate": Timestamp(date: expiryDate), // Firestore-compatible
            "totalPills": totalPills
        ]
    }

    // Parse Firestore data back into a Medication object
    static func fromDictionary(_ data: [String: Any]) -> Medication? {
        guard let medicineName = data["medicineName"] as? String,
              let frequency = data["frequency"] as? Int,
              let startHour = data["startHour"] as? Int,
              let startMinute = data["startMinute"] as? Int,
              let duration = data["duration"] as? Int,
              let startDate = (data["startDate"] as? Timestamp)?.dateValue(),
              let expiryDate = (data["expiryDate"] as? Timestamp)?.dateValue(),
              let totalPills = data["totalPills"] as? Int else {
            print("[ERROR] Missing or invalid fields while parsing Medication.")
            return nil
        }
        
        return Medication(
            medicineName: medicineName,
            frequency: frequency,
            startHour: startHour,
            startMinute: startMinute,
            duration: duration,
            startDate: startDate,
            expiryDate: expiryDate,
            totalPills: totalPills
        )
    }
}
