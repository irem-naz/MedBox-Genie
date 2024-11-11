import FirebaseFirestore

class MedicationManager {
    static let shared = MedicationManager() // Singleton
    private let db = Firestore.firestore()

    private init() {}

    func fetchMedications(for userId: String, completion: @escaping ([Medication]) -> Void) {
        Firestore.firestore().collection("users").document(userId).collection("medications").getDocuments { snapshot, error in
            if let error = error {
                print("[ERROR] Failed to fetch medications: \(error.localizedDescription)")
                completion([])
                return
            }

            guard let documents = snapshot?.documents, !documents.isEmpty else {
                print("[INFO] No medications found for user.")
                completion([])
                return
            }

            print("[DEBUG] Retrieved Medications: \(documents.map { $0.data() })") // Debug log

            var medications: [Medication] = []
            for document in documents {
                if let medication = self.parseMedication(from: document) {
                    medications.append(medication)
                }
            }
            completion(medications)
        }
    }


    // Parse Firebase data into a Medication object
    private func parseMedication(from document: QueryDocumentSnapshot) -> Medication? {
        let data = document.data()
        guard
            let medicineName = data["medicineName"] as? String,
            let expiryDate = (data["expiryDate"] as? Timestamp)?.dateValue() // Only the date is fetched
        else {
            print("[ERROR] Missing required fields for medication.")
            return nil
        }
        
        return Medication(
            medicineName: medicineName,
            medicineDosage: "",
            numberOfTablets: 0,
            prescribedDosage: "",
            intakeFrequency: 0,
            startDate: Date(),
            endDate: Date(), 
            expiryDate: expiryDate
        )
    }

    // Fetch medications and schedule expiry notifications
    func fetchAndScheduleNotifications(for userId: String) {
        fetchMedications(for: userId) { medications in
            for medication in medications {
                NotificationManager.shared.scheduleNotificationWithActions(for: medication.medicineName, at: medication.expiryDate, userId: userId)
            }
        }
    }

    // Listen for real-time changes in medications
    func listenToMedicationChanges(for userId: String) {
        db.collection("users").document(userId).collection("medications").addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                print("[ERROR] Failed to listen to medication changes: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                switch change.type {
                case .added:
                    if let medication = self.parseMedication(from: change.document) {
                        NotificationManager.shared.scheduleNotificationWithActions(for: medication.medicineName, at: medication.expiryDate, userId: userId)
                    }
                case .removed:
                    let medicationName = change.document.data()["medicineName"] as? String ?? "Unknown"
                    let notificationIdentifier = "\(userId)_\(medicationName)_expiry"
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
                default:
                    break
                }
            }
        }
    }
}
