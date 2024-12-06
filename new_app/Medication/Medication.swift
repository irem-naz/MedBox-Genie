import Foundation


final class Medication {
    var medicineName: String          // Name of the medicine
    var frequency: Int                // Doses per day (e.g., 1, 2, 3, 4, 6)
    var startHour: Int                // Hour for the first dose (e.g., 8 for 8:00 AM)
    var startMinute: Int              // Minute for the first dose (e.g., 15 for 8:15 AM)
    var duration: Int                 // Duration of medication in days
    var startDate: Date               // Start date for the medication
    var expiryDate: Date              // Expiry date for the medication
    var totalPills: Int               // Total number of pills in the package
    var surveys: [Survey] = []        // Surveys related to this medication

    init(medicineName: String,
         frequency: Int,
         startHour: Int,
         startMinute: Int,
         duration: Int,
         startDate: Date,
         expiryDate: Date,
         totalPills: Int,
         surveys: [Survey] = []) {
        self.medicineName = medicineName
        self.frequency = frequency
        self.startHour = startHour
        self.startMinute = startMinute
        self.duration = duration
        self.startDate = startDate
        self.expiryDate = Calendar.current.startOfDay(for: expiryDate) // Store only the date
        self.totalPills = totalPills
        self.surveys = surveys
    }
   
    
}

struct Survey {
    var date: Date               // Date of the survey prompt
    var isCompleted: Bool        // Survey status
    var isPrompted: Bool         // Whether the notification was triggered
    var responses: [String: Any] // Responses to the survey questions

    
}
