import SwiftUI

struct NotificationsMenuView: View {
    @Binding var showNotifications: Bool  // Binding to control visibility
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    showNotifications = false // Close the notification menu
                }) {
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
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("No new notifications")
                        .foregroundColor(.gray)
                        .padding()
                    
                    
                }
                .padding()
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color.white)
        .shadow(radius: 10)
        .onTapGesture {
            showNotifications = false // Dismiss menu when tapping outside
        }
    }
}
