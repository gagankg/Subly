import SwiftUI
import SwiftData

struct SubscriptionRowView: View {
    let subscription: Subscription

    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(subscription.category.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: subscription.category.iconName)
                    .font(.system(size: 20))
                    .foregroundStyle(subscription.category.color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(subscription.name)
                    .font(.headline)
                    .foregroundStyle(subscription.isActive ? .primary : .secondary)
                HStack(spacing: 6) {
                    CategoryBadge(category: subscription.category)
                    if !subscription.isActive {
                        Text("Inactive")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(subscription.cost, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .font(.subheadline.weight(.semibold))
                Text(subscription.billingCycle.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .opacity(subscription.isActive ? 1 : 0.6)
    }
}

#Preview {
    List {
        SubscriptionRowView(subscription: .preview)
    }
    .modelContainer(for: Subscription.self, inMemory: true)
}
