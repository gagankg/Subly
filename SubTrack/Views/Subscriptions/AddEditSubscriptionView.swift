import SwiftUI
import SwiftData

struct AddEditSubscriptionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // When non-nil we're in edit mode
    var existing: Subscription?

    // MARK: - Form State

    @State private var name: String = ""
    @State private var cost: Double = 0.0
    @State private var costText: String = ""
    @State private var billingCycle: BillingCycle = .monthly
    @State private var renewalDate: Date = Date().addingTimeInterval(60 * 60 * 24 * 30)
    @State private var category: SubscriptionCategory = .other
    @State private var notes: String = ""
    @State private var isActive: Bool = true

    @AppStorage("notificationDaysBefore") private var daysBefore: Int = 3
    @State private var showCostError = false

    private var isEditing: Bool { existing != nil }
    private var title: String { isEditing ? "Edit Subscription" : "Add Subscription" }

    private var isSaveDisabled: Bool {
        name.trimmingCharacters(in: .whitespaces).isEmpty || cost <= 0
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                // Basic info
                Section("Details") {
                    TextField("Name (e.g. Netflix)", text: $name)
                        .textInputAutocapitalization(.words)

                    HStack {
                        Text("Cost")
                        Spacer()
                        TextField("0.00", text: $costText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                            .onChange(of: costText) { _, newValue in
                                cost = Double(newValue) ?? 0
                                showCostError = !newValue.isEmpty && cost <= 0
                            }
                    }
                    if showCostError {
                        Text("Enter a valid cost")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    Picker("Billing Cycle", selection: $billingCycle) {
                        ForEach(BillingCycle.allCases) { cycle in
                            Text(cycle.displayName).tag(cycle)
                        }
                    }

                    DatePicker("Next Renewal", selection: $renewalDate, displayedComponents: .date)
                }

                // Category
                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(SubscriptionCategory.allCases) { cat in
                            Label(cat.displayName, systemImage: cat.iconName)
                                .tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                }

                // Status
                Section("Status") {
                    Toggle("Active", isOn: $isActive)
                }

                // Notes
                Section("Notes") {
                    TextField("Optional notes…", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(isSaveDisabled)
                }
            }
            .onAppear { populateIfEditing() }
        }
    }

    // MARK: - Helpers

    private func populateIfEditing() {
        guard let sub = existing else { return }
        name         = sub.name
        cost         = sub.cost
        costText     = String(sub.cost)
        billingCycle = sub.billingCycle
        renewalDate  = sub.renewalDate
        category     = sub.category
        notes        = sub.notes
        isActive     = sub.isActive
    }

    private func save() {
        if let sub = existing {
            // Edit mode — update in place
            sub.name         = name.trimmingCharacters(in: .whitespaces)
            sub.cost         = cost
            sub.billingCycle = billingCycle
            sub.renewalDate  = renewalDate
            sub.category     = category
            sub.notes        = notes
            sub.isActive     = isActive
            NotificationManager.shared.scheduleNotification(for: sub, daysBefore: daysBefore)
        } else {
            // Add mode — insert new
            let sub = Subscription(
                name: name.trimmingCharacters(in: .whitespaces),
                cost: cost,
                renewalDate: renewalDate,
                billingCycle: billingCycle,
                category: category,
                notes: notes,
                isActive: isActive
            )
            modelContext.insert(sub)
            NotificationManager.shared.scheduleNotification(for: sub, daysBefore: daysBefore)
        }
        dismiss()
    }
}

#Preview("Add Mode") {
    AddEditSubscriptionView()
        .modelContainer(for: Subscription.self, inMemory: true)
}

#Preview("Edit Mode") {
    AddEditSubscriptionView(existing: .preview)
        .modelContainer(for: Subscription.self, inMemory: true)
}
