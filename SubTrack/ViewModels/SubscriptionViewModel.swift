import Foundation
import SwiftData
import SwiftUI

/// Stateless helper — all real persistence goes through SwiftData @Query / modelContext.
/// This class centralises computed aggregates so views stay thin.
@Observable
final class SubscriptionViewModel {

    // MARK: - Aggregates

    func monthlyTotal(for subscriptions: [Subscription]) -> Double {
        subscriptions
            .filter(\.isActive)
            .reduce(0) { $0 + $1.monthlyCost }
    }

    func yearlyTotal(for subscriptions: [Subscription]) -> Double {
        monthlyTotal(for: subscriptions) * 12
    }

    func totalByCategory(
        for subscriptions: [Subscription]
    ) -> [(category: SubscriptionCategory, total: Double)] {
        let active = subscriptions.filter(\.isActive)
        return SubscriptionCategory.allCases.compactMap { category in
            let total = active
                .filter { $0.category == category }
                .reduce(0) { $0 + $1.monthlyCost }
            guard total > 0 else { return nil }
            return (category, total)
        }
        .sorted { $0.total > $1.total }
    }

    func renewingSoon(
        from subscriptions: [Subscription],
        within days: Int = 7
    ) -> [Subscription] {
        subscriptions
            .filter { $0.isActive && $0.isRenewingSoon(within: days) }
            .sorted { $0.daysUntilRenewal < $1.daysUntilRenewal }
    }

    // MARK: - Filtering / Sorting

    func filtered(
        _ subscriptions: [Subscription],
        query: String,
        category: SubscriptionCategory?
    ) -> [Subscription] {
        subscriptions.filter { sub in
            let matchesQuery = query.isEmpty
                || sub.name.localizedCaseInsensitiveContains(query)
            let matchesCategory = category == nil || sub.category == category
            return matchesQuery && matchesCategory
        }
    }
}
