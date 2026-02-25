import Foundation
import SwiftData

@Model
final class Subscription {
    var id: UUID
    var name: String
    var cost: Double
    var renewalDate: Date
    var billingCycle: BillingCycle
    var category: SubscriptionCategory
    var notes: String
    var isActive: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        cost: Double,
        renewalDate: Date,
        billingCycle: BillingCycle = .monthly,
        category: SubscriptionCategory = .other,
        notes: String = "",
        isActive: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.cost = cost
        self.renewalDate = renewalDate
        self.billingCycle = billingCycle
        self.category = category
        self.notes = notes
        self.isActive = isActive
        self.createdAt = createdAt
    }

    // MARK: - Computed Properties

    /// Normalises the subscription cost to a monthly equivalent.
    var monthlyCost: Double {
        cost * billingCycle.monthlyMultiplier
    }

    /// Number of calendar days from today until the next renewal date.
    var daysUntilRenewal: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let renewal = calendar.startOfDay(for: renewalDate)
        let components = calendar.dateComponents([.day], from: today, to: renewal)
        return components.day ?? 0
    }

    /// True when renewal is within the given number of days (inclusive).
    func isRenewingSoon(within days: Int = 7) -> Bool {
        let d = daysUntilRenewal
        return d >= 0 && d <= days
    }
}
