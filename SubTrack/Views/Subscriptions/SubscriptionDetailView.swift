import SwiftUI
import SwiftData

struct SubscriptionDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let subscription: Subscription

    @State private var showEditSheet = false
    @State private var showDeleteConfirm = false

    var body: some View {
        List {
            // Header
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(subscription.category.color.opacity(0.15))
                                .frame(width: 72, height: 72)
                            Image(systemName: subscription.category.iconName)
                                .font(.system(size: 36))
                                .foregroundStyle(subscription.category.color)
                        }
                        Text(subscription.name)
                            .font(.title2.bold())
                        CategoryBadge(category: subscription.category)
                    }
                    Spacer()
                }
                .listRowBackground(Color.clear)
                .padding(.vertical, 8)
            }

            // Cost
            Section("Cost") {
                LabeledContent("Amount") {
                    Text(subscription.cost, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                }
                LabeledContent("Billing Cycle") {
                    Text(subscription.billingCycle.displayName)
                }
                LabeledContent("Monthly Equivalent") {
                    Text(subscription.monthlyCost, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .foregroundStyle(.secondary)
                }
            }

            // Renewal
            Section("Renewal") {
                LabeledContent("Next Renewal") {
                    Text(subscription.renewalDate, format: .dateTime.day().month().year())
                }
                LabeledContent("Days Until Renewal") {
                    let days = subscription.daysUntilRenewal
                    Text(days >= 0 ? "\(days) days" : "Overdue by \(-days) days")
                        .foregroundStyle(days < 0 ? .red : days <= 7 ? .orange : .primary)
                }
            }

            // Info
            Section("Info") {
                LabeledContent("Status") {
                    Text(subscription.isActive ? "Active" : "Inactive")
                        .foregroundStyle(subscription.isActive ? .green : .secondary)
                }
                LabeledContent("Added") {
                    Text(subscription.createdAt, format: .dateTime.day().month().year())
                }
            }

            // Notes
            if !subscription.notes.isEmpty {
                Section("Notes") {
                    Text(subscription.notes)
                        .foregroundStyle(.secondary)
                }
            }

            // Danger zone
            Section {
                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Label("Delete Subscription", systemImage: "trash")
                }
            }
        }
        .navigationTitle(subscription.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { showEditSheet = true }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            AddEditSubscriptionView(existing: subscription)
        }
        .confirmationDialog(
            "Delete \"\(subscription.name)\"?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                delete()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private func delete() {
        NotificationManager.shared.cancelNotification(for: subscription)
        modelContext.delete(subscription)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        SubscriptionDetailView(subscription: .preview)
    }
    .modelContainer(for: Subscription.self, inMemory: true)
}
