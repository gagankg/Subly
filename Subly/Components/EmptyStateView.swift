import SwiftUI

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let message: String

    var body: some View {
        ContentUnavailableView(
            label: {
                Label(title, systemImage: systemImage)
            },
            description: {
                Text(message)
            }
        )
    }
}

#Preview {
    EmptyStateView(
        systemImage: "rectangle.stack.badge.plus",
        title: "No Subscriptions",
        message: "Tap + to add your first subscription."
    )
}
