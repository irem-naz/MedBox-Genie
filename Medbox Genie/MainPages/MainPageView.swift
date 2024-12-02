import SwiftUI
import FirebaseFirestore
import FirebaseAuth


struct MainPageView: View {
    @Binding var isLoggedIn: Bool  // Binding to control login state
    @State private var showProfile = false  // Control profile view
    @State private var showNotifications = false  // Control notifications menu
    @State private var showAddMedication = false  // Control add medication view
    
    @State private var medications: [Medication] = []  // Store medications here
    @State private var unreadNotificationsCount: Int = 0  // Track unread notifications
    private let db = Firestore.firestore()  // Reference to Firestore
    
    var body: some View {
        ZStack {
            NavigationView {
                List {
                    ForEach(medications, id: \.medicineName) { medication in
                        NavigationLink(destination: MedicationDetailView(medication: medication)) {
                            MedicationRow(medication: medication) // Use MedicationRow here
                                .padding(.vertical, 4)
                                .listRowInsets(EdgeInsets())
                        }
                    }
                    
                }
                .navigationBarTitle("Medications", displayMode: .inline)
                .navigationBarItems(
                    leading: Button(action: {
                        showProfile = true // Open profile view
                    }) {
                        Image(systemName: "person.circle")
                            .font(.title) // Profile icon
                    },
                    trailing: HStack {
                        Button(action: {
                            showNotifications = true // Toggle notification menu
                            unreadNotificationsCount = 0 // Reset unread count when menu is opened
                        }) {
                            ZStack {
                                Image(systemName: "bell")
                                    .imageScale(.medium)
                                    .font(.system(size: 22))
                                if unreadNotificationsCount > 0 {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 10, height: 10)
                                        .offset(x: 10, y: -10) // Position the red dot
                                }
                            }
                        }
                        Button(action: {
                            showAddMedication = true // Show add medication view
                        }) {
                            Image(systemName: "plus")
                                .font(.title) // Plus icon
                        }
                    }
                )
                .listStyle(PlainListStyle()) // Use plain style for a cleaner look
            }
            .sheet(isPresented: $showAddMedication) {
                AddMedicationView(onSave: fetchMedications) // Present AddMedicationView as a sheet
            }
            .sheet(isPresented: $showProfile) {
                ProfileView(isLoggedIn: $isLoggedIn) // Present ProfileView as a sheet
            }
            
            // Slide-in Notification Menu
            if showNotifications {
                NotificationsMenuView(showNotifications: $showNotifications)
                    .transition(.move(edge: .trailing))
                    .zIndex(1)
            }
        }
        .onAppear(perform: fetchMedications)  // Fetch medications when view appears
        .onAppear(perform: setupNotificationListener)
    }
    
    // Fetch Medications from Firestore
    private func fetchMedications() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }

        db.collection("users").document(userId).collection("medications").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching medications: \(error.localizedDescription)")
                return
            }

            var fetchedMedications: [Medication] = []

            if let documents = snapshot?.documents {
                for document in documents {
                    let data = document.data()

                    if let medicineName = data["medicineName"] as? String,
                       let frequency = data["frequency"] as? Int,
                       let startHour = data["startHour"] as? Int,
                       let startMinute = data["startMinute"] as? Int,
                       let duration = data["duration"] as? Int,
                       let totalPills = data["totalPills"] as? Int,
                       let startDateTimestamp = data["startDate"] as? Timestamp,
                       let expiryDateTimestamp = data["expiryDate"] as? Timestamp,
                       let surveyDictionaries = data["surveys"] as? [[String: Any]] {
                        
                        let startDate = startDateTimestamp.dateValue()
                        let expiryDate = expiryDateTimestamp.dateValue()

                        // Create Medication object
                        let medication = Medication(
                            medicineName: medicineName,
                            frequency: frequency,
                            startHour: startHour,
                            startMinute: startMinute,
                            duration: duration,
                            startDate: startDate,
                            expiryDate: expiryDate,
                            totalPills: totalPills
                        )

                        // Populate surveys
                        medication.surveys = surveyDictionaries.compactMap { Survey.fromDictionary($0) }
                        print("[DEBUG] Populated surveys for \(medicineName): \(medication.surveys.map { $0.date })")

                        fetchedMedications.append(medication)
                    } else {
                        print("[DEBUG] Skipping medication due to missing data: \(data)")
                    }
                }
            }

            // Update the medications array on the main thread
            DispatchQueue.main.async {
                self.medications = fetchedMedications
            }
        }
    }


    
    private func setupNotificationListener() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name("NewSurveyNotification"), object: nil, queue: .main) { notification in
            guard let userInfo = notification.userInfo,
                  let medicationName = userInfo["medicationName"] as? String,
                  let surveyDate = userInfo["surveyDate"] as? Date else {
                print("[ERROR] Missing notification details.")
                return
            }

            // Find the medication and survey to mark as prompted
            if let medicationIndex = self.medications.firstIndex(where: { $0.medicineName == medicationName }),
               let surveyIndex = self.medications[medicationIndex].surveys.firstIndex(where: {
                   Calendar.current.isDate($0.date, equalTo: surveyDate, toGranularity: .second)
               }) {
                self.medications[medicationIndex].surveys[surveyIndex].isPrompted = true
                print("[DEBUG] Marked survey as prompted for \(medicationName) on \(surveyDate)")

                // Update Firestore
                guard let userId = Auth.auth().currentUser?.uid else {
                    print("[ERROR] User not authenticated.")
                    return
                }

                let db = Firestore.firestore()
                let medicationRef = db.collection("users").document(userId).collection("medications").document(medicationName)
                let surveyRef = medicationRef.collection("surveys").document("\(surveyDate)")

                surveyRef.updateData(["isPrompted": true]) { error in
                    if let error = error {
                        print("[ERROR] Failed to update isPrompted in Firestore: \(error.localizedDescription)")
                    } else {
                        print("[DEBUG] isPrompted updated in Firestore for \(medicationName) on \(surveyDate)")
                    }
                }
            } else {
                print("[DEBUG] Medication or survey not found for notification.")
            }

            // Increment unread notifications count
            self.unreadNotificationsCount += 1
            print("[DEBUG] Unread survey notifications count: \(self.unreadNotificationsCount)")
        }
    }



}

struct MainPage_Previews: PreviewProvider {
    static var previews: some View {
        MainPageView(isLoggedIn: .constant(true))
    }
}
