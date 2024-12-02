import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct NotificationsMenuView: View {
    @Binding var showNotifications: Bool
    @State private var notifications: [SurveyNotification] = [] // Local state for notifications

    var body: some View {
        NavigationView {
            VStack {
                // Header
                HStack {
                    Button(action: { showNotifications = false }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                        Text("Notifications")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.primary)
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))

                Divider()

                // Notifications List
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(notifications, id: \.id) { notification in
                            NavigationLink(
                                destination: SurveyDetailView(
                                    survey: notification.survey,
                                    medication: notification.medication
                                )
                            ) {
                                NotificationCard(
                                    medicationName: notification.medication.medicineName,
                                    surveyDate: notification.survey.date
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }

                Spacer()
            }
            .onAppear(perform: fetchNotifications)
        }
    }

    private func fetchNotifications() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("[ERROR] User not authenticated")
            return
        }

        let db = Firestore.firestore()
        var fetchedNotifications: [SurveyNotification] = []
        let dispatchGroup = DispatchGroup()

        // Fetch medications
        db.collection("users").document(userId).collection("medications").getDocuments { snapshot, error in
            if let error = error {
                print("[ERROR] Failed to fetch medications: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("[DEBUG] No medications found.")
                return
            }

            let medications = documents.compactMap { document -> Medication? in
                var medication = Medication.fromDictionary(document.data())
                medication?.medicineName = document.documentID // Use document ID as medication name
                return medication
            }

            // Fetch surveys for each medication
            for medication in medications {
                let medicationRef = db.collection("users")
                    .document(userId)
                    .collection("medications")
                    .document(medication.medicineName)

                dispatchGroup.enter()
                medicationRef.collection("surveys")
                    .whereField("isCompleted", isEqualTo: false)
                    .whereField("isPrompted", isEqualTo: true)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            print("[ERROR] Failed to fetch surveys for \(medication.medicineName): \(error.localizedDescription)")
                            dispatchGroup.leave()
                            return
                        }

                        guard let documents = snapshot?.documents else {
                            print("[DEBUG] No surveys found for \(medication.medicineName).")
                            dispatchGroup.leave()
                            return
                        }

                        let surveys = documents.compactMap { Survey.fromDictionary($0.data()) }
                        surveys.forEach { survey in
                            fetchedNotifications.append(SurveyNotification(medication: medication, survey: survey))
                        }

                        dispatchGroup.leave()
                    }
            }

            // Update state once all queries are complete
            dispatchGroup.notify(queue: .main) {
                self.notifications = fetchedNotifications
                print("[DEBUG] Fetched \(fetchedNotifications.count) notifications.")
            }
        }
    }
}

// Data structure to represent a notification
struct SurveyNotification: Identifiable {
    var id: String { "\(medication.medicineName)_\(survey.date)" }
    let medication: Medication
    let survey: Survey
}


struct NotificationCard: View {
    let medicationName: String
    let surveyDate: Date
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        HStack {
            Image(systemName: "doc.text.fill")
                .font(.title)
                .foregroundColor(.blue)
            VStack(alignment: .leading, spacing: 4) {
                Text("\(medicationName)")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("Survey Due")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("\(surveyDate, formatter: dateFormatter)")
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
