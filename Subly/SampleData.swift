#if DEBUG
import SwiftData
import Foundation

// MARK: - Subscription Preview Helper

extension Subscription {
    /// A single preview instance (no persistence required).
    static var preview: Subscription {
        Subscription(
            name: "Netflix",
            cost: 15.99,
            renewalDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
            billingCycle: .monthly,
            category: .entertainment,
            notes: "Family plan — 4 screens"
        )
    }
}

// MARK: - Preview ModelContainer

@MainActor
let previewContainer: ModelContainer = {
    let schema = Schema([Subscription.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    insertSampleData(into: container.mainContext)
    return container
}()

@MainActor
private func insertSampleData(into context: ModelContext) {
    let calendar = Calendar.current
    let today = Date()

    func date(addingDays days: Int) -> Date {
        calendar.date(byAdding: .day, value: days, to: today)!
    }

    let samples: [Subscription] = [
        Subscription(
            name: "Netflix",
            cost: 15.99,
            renewalDate: date(addingDays: 5),
            billingCycle: .monthly,
            category: .entertainment,
            notes: "Family plan"
        ),
        Subscription(
            name: "Spotify",
            cost: 9.99,
            renewalDate: date(addingDays: 12),
            billingCycle: .monthly,
            category: .entertainment,
            notes: "Student discount"
        ),
        Subscription(
            name: "iCloud+",
            cost: 2.99,
            renewalDate: date(addingDays: 3),
            billingCycle: .monthly,
            category: .utilities,
            notes: "50 GB plan"
        ),
        Subscription(
            name: "NYT",
            cost: 17.00,
            renewalDate: date(addingDays: 30),
            billingCycle: .monthly,
            category: .news,
            notes: ""
        ),
        Subscription(
            name: "Duolingo Plus",
            cost: 79.99,
            renewalDate: date(addingDays: 180),
            billingCycle: .yearly,
            category: .education,
            notes: "Annual plan"
        ),
    ]

    for sub in samples {
        context.insert(sub)
    }
}
#endif
