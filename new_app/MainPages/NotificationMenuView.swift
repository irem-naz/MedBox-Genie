import SwiftUI

struct NotificationsMenuView: View {
    @Binding var showNotifications: Bool
    @State var notifications: [SurveyNotification] = [] // Local state for notifications

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

    func fetchNotifications() {
        // Path to survey.json
        let surveyFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("survey.json")

        // Ensure the file exists
        guard FileManager.default.fileExists(atPath: surveyFileURL.path) else {
            print("[DEBUG] survey.json file does not exist.")
            return
        }

        // Parse survey.json
        do {
            let data = try Data(contentsOf: surveyFileURL)
            if let surveyData = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                var fetchedNotifications: [SurveyNotification] = []

                for surveyDict in surveyData {
                    // Extract survey information
                    guard let medicationName = surveyDict["medicationName"] as? String,
                          let dateString = surveyDict["date"] as? String,
                          let isCompleted = surveyDict["isCompleted"] as? Bool,
                          let isPrompted = surveyDict["isPrompted"] as? Bool,
                          let responses = surveyDict["responses"] as? [String: Any],
                          let surveyDate = ISO8601DateFormatter().date(from: dateString) else {
                        print("[ERROR] Invalid survey data.")
                        continue
                    }

                    // Create Survey object
                    let survey = Survey(
                        date: surveyDate,
                        isCompleted: isCompleted,
                        isPrompted: isPrompted,
                        responses: responses
                    )

                    // Create Medication object
                    let medication = Medication(
                        medicineName: medicationName,
                        frequency: 0, // Replace with actual value if available
                        startHour: 0, // Replace with actual value if available
                        startMinute: 0, // Replace with actual value if available
                        duration: 0, // Replace with actual value if available
                        startDate: surveyDate, // Replace with actual value if available
                        expiryDate: Calendar.current.date(byAdding: .year, value: 1, to: surveyDate)!,
                        totalPills: 0 // Replace with actual value if available
                    )

                    // Filter for surveys that are not completed and have been prompted
                    if !isCompleted && isPrompted {
                        fetchedNotifications.append(SurveyNotification(medication: medication, survey: survey))
                    }
                }

                // Update state with fetched notifications
                DispatchQueue.main.async {
                    self.notifications = fetchedNotifications
                    print("[DEBUG] Fetched \(fetchedNotifications.count) notifications.")
                }
            }
        } catch {
            print("[ERROR] Failed to read or parse survey.json: \(error.localizedDescription)")
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
