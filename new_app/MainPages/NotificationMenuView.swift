// NotificationMenuView.swift
import SwiftUI

struct NotificationMenuView: View {
    @Binding var showNotifications: Bool

    var body: some View {
        VStack {
            Text("No notifications available.")
                .padding()

            Button("Close") {
                showNotifications = false
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.2))
    }
}
