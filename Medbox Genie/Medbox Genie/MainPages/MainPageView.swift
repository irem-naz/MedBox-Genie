import SwiftUI
import FirebaseFirestore
import FirebaseAuth


struct MainPageView: View {
    @Binding var isLoggedIn: Bool  // Binding to control login state
    @State private var showProfile = false  // Control profile view
    @State private var showNotifications = false  // Control notifications menu
    @State private var showAddMedication = false  // Control add medication view
    
    @State private var medications: [Medication] = []  // Store medications here
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
                    .onDelete(perform: deleteMedications)
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
                        }) {
                            Image(systemName: "bell")
                                .imageScale(.medium)
                                .font(.system(size: 22))
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
                    .transition(.move(edge: .trailing)) // Slide in from the right
                    .zIndex(1)
            }
        }
        .onAppear(perform: fetchMedications)  // Fetch medications when view appears
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
                       let medicineDosage = data["medicineDosage"] as? String,
                       let numberOfTablets = data["numberOfTablets"] as? Int,
                       let prescribedDosage = data["prescribedDosage"] as? String,
                       let intakeFrequency = data["intakeFrequency"] as? Int,
                       let startDateTimestamp = data["startDate"] as? Timestamp,
                       let endDateTimestamp = data["endDate"] as? Timestamp,
                       let expiryDateTimestamp = data["expiryDate"] as? Timestamp {
                        
                        let startDate = startDateTimestamp.dateValue()
                        let endDate = endDateTimestamp.dateValue()
                        let expiryDate = expiryDateTimestamp.dateValue()
                        
                        let medication = Medication(
                            medicineName: medicineName,
                            medicineDosage: medicineDosage,
                            numberOfTablets: numberOfTablets,
                            prescribedDosage: prescribedDosage,
                            intakeFrequency: intakeFrequency,
                            startDate: startDate,
                            endDate: endDate,
                            expiryDate: expiryDate
                        )
                        
                        fetchedMedications.append(medication)
                    } else {
                        print("Skipping document due to missing or invalid data.")
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.medications = fetchedMedications
            }
        }
    }

    private func deleteMedications(at offsets: IndexSet) {
        // Implement delete functionality if needed
    }
}

struct MainPage_Previews: PreviewProvider {
    static var previews: some View {
        MainPageView(isLoggedIn: .constant(true))
    }
}
