import Testing
import Foundation
@testable import Subly

// MARK: - BillingCycle Tests

@Suite("BillingCycle")
struct BillingCycleTests {

    @Test("Weekly multiplier is ~4.33")
    func weeklyMultiplier() {
        #expect(BillingCycle.weekly.monthlyMultiplier == 4.33)
    }

    @Test("Monthly multiplier is 1.0")
    func monthlyMultiplier() {
        #expect(BillingCycle.monthly.monthlyMultiplier == 1.0)
    }

    @Test("Yearly multiplier is 1/12")
    func yearlyMultiplier() {
        #expect(abs(BillingCycle.yearly.monthlyMultiplier - (1.0 / 12.0)) < 0.0001)
    }

    @Test("All cases are CaseIterable")
    func allCasesCount() {
        #expect(BillingCycle.allCases.count == 3)
    }
}

// MARK: - Subscription Computed Property Tests

@Suite("Subscription computed properties")
struct SubscriptionComputedTests {

    private func makeSub(
        cost: Double,
        cycle: BillingCycle,
        renewalDaysFromNow: Int = 10
    ) -> Subscription {
        Subscription(
            name: "Test",
            cost: cost,
            renewalDate: Calendar.current.date(
                byAdding: .day, value: renewalDaysFromNow, to: Date()
            )!,
            billingCycle: cycle
        )
    }

    @Test("Monthly cost for monthly billing equals cost")
    func monthlyCostMonthly() {
        let sub = makeSub(cost: 9.99, cycle: .monthly)
        #expect(sub.monthlyCost == 9.99)
    }

    @Test("Monthly cost for yearly billing is cost / 12")
    func monthlyCostYearly() {
        let sub = makeSub(cost: 120.0, cycle: .yearly)
        #expect(abs(sub.monthlyCost - 10.0) < 0.001)
    }

    @Test("Monthly cost for weekly billing is cost × 4.33")
    func monthlyCostWeekly() {
        let sub = makeSub(cost: 1.0, cycle: .weekly)
        #expect(abs(sub.monthlyCost - 4.33) < 0.001)
    }

    @Test("daysUntilRenewal returns correct value")
    func daysUntilRenewal() {
        let sub = makeSub(cost: 1, cycle: .monthly, renewalDaysFromNow: 5)
        #expect(sub.daysUntilRenewal == 5)
    }

    @Test("isRenewingSoon true when within window")
    func isRenewingSoonTrue() {
        let sub = makeSub(cost: 1, cycle: .monthly, renewalDaysFromNow: 3)
        #expect(sub.isRenewingSoon(within: 7) == true)
    }

    @Test("isRenewingSoon false when outside window")
    func isRenewingSoonFalse() {
        let sub = makeSub(cost: 1, cycle: .monthly, renewalDaysFromNow: 10)
        #expect(sub.isRenewingSoon(within: 7) == false)
    }

    @Test("isRenewingSoon false for past dates")
    func isRenewingSoonPast() {
        let sub = makeSub(cost: 1, cycle: .monthly, renewalDaysFromNow: -1)
        #expect(sub.isRenewingSoon(within: 7) == false)
    }
}

// MARK: - SubscriptionViewModel Tests

@Suite("SubscriptionViewModel aggregates")
struct SubscriptionViewModelTests {

    private let vm = SubscriptionViewModel()

    private func sub(
        name: String,
        cost: Double,
        cycle: BillingCycle = .monthly,
        category: SubscriptionCategory = .other,
        isActive: Bool = true,
        daysFromNow: Int = 30
    ) -> Subscription {
        Subscription(
            name: name,
            cost: cost,
            renewalDate: Calendar.current.date(byAdding: .day, value: daysFromNow, to: Date())!,
            billingCycle: cycle,
            category: category,
            isActive: isActive
        )
    }

    @Test("monthlyTotal sums active subscriptions only")
    func monthlyTotalActiveOnly() {
        let subs = [
            sub(name: "A", cost: 10, isActive: true),
            sub(name: "B", cost: 5,  isActive: false),
            sub(name: "C", cost: 20, isActive: true),
        ]
        #expect(vm.monthlyTotal(for: subs) == 30.0)
    }

    @Test("yearlyTotal is monthlyTotal × 12")
    func yearlyTotal() {
        let subs = [sub(name: "A", cost: 10)]
        #expect(vm.yearlyTotal(for: subs) == 120.0)
    }

    @Test("monthlyTotal returns 0 for empty list")
    func monthlyTotalEmpty() {
        #expect(vm.monthlyTotal(for: []) == 0.0)
    }

    @Test("totalByCategory groups correctly")
    func totalByCategory() {
        let subs = [
            sub(name: "A", cost: 10, category: .entertainment),
            sub(name: "B", cost: 5,  category: .entertainment),
            sub(name: "C", cost: 8,  category: .productivity),
        ]
        let breakdown = vm.totalByCategory(for: subs)
        let entertainmentTotal = breakdown.first(where: { $0.category == .entertainment })?.total
        let productivityTotal  = breakdown.first(where: { $0.category == .productivity })?.total
        #expect(entertainmentTotal == 15.0)
        #expect(productivityTotal  == 8.0)
    }

    @Test("totalByCategory excludes inactive subscriptions")
    func totalByCategoryExcludesInactive() {
        let subs = [
            sub(name: "A", cost: 10, category: .entertainment, isActive: true),
            sub(name: "B", cost: 50, category: .entertainment, isActive: false),
        ]
        let breakdown = vm.totalByCategory(for: subs)
        let total = breakdown.first(where: { $0.category == .entertainment })?.total
        #expect(total == 10.0)
    }

    @Test("totalByCategory omits categories with zero spend")
    func totalByCategoryOmitsZero() {
        let subs = [sub(name: "A", cost: 10, category: .entertainment)]
        let breakdown = vm.totalByCategory(for: subs)
        let hasOther = breakdown.contains(where: { $0.category == .other })
        #expect(hasOther == false)
    }

    @Test("renewingSoon returns subs within window sorted by days")
    func renewingSoon() {
        let subs = [
            sub(name: "Far",   cost: 1, daysFromNow: 20),
            sub(name: "Soon1", cost: 1, daysFromNow: 3),
            sub(name: "Soon2", cost: 1, daysFromNow: 1),
        ]
        let result = vm.renewingSoon(from: subs, within: 7)
        #expect(result.count == 2)
        #expect(result[0].name == "Soon2")
        #expect(result[1].name == "Soon1")
    }

    @Test("renewingSoon excludes inactive subscriptions")
    func renewingSoonExcludesInactive() {
        let subs = [
            sub(name: "Active",   cost: 1, isActive: true,  daysFromNow: 2),
            sub(name: "Inactive", cost: 1, isActive: false, daysFromNow: 2),
        ]
        let result = vm.renewingSoon(from: subs, within: 7)
        #expect(result.count == 1)
        #expect(result[0].name == "Active")
    }

    @Test("filtered matches name case-insensitively")
    func filteredByName() {
        let subs = [
            sub(name: "Netflix",  cost: 1),
            sub(name: "Spotify",  cost: 1),
        ]
        let result = vm.filtered(subs, query: "net", category: nil)
        #expect(result.count == 1)
        #expect(result[0].name == "Netflix")
    }

    @Test("filtered by category")
    func filteredByCategory() {
        let subs = [
            sub(name: "A", cost: 1, category: .entertainment),
            sub(name: "B", cost: 1, category: .productivity),
        ]
        let result = vm.filtered(subs, query: "", category: .entertainment)
        #expect(result.count == 1)
        #expect(result[0].name == "A")
    }

    @Test("filtered returns all when query empty and category nil")
    func filteredNoFilters() {
        let subs = [sub(name: "A", cost: 1), sub(name: "B", cost: 1)]
        #expect(vm.filtered(subs, query: "", category: nil).count == 2)
    }
}

// MARK: - DateHelpers Tests

@Suite("DateHelpers")
struct DateHelpersTests {

    @Test("notificationDate is daysBefore days before renewal at 9 AM")
    func notificationDate() {
        let calendar = Calendar.current
        let renewal = calendar.date(from: DateComponents(year: 2026, month: 3, day: 10))!
        let trigger = DateHelpers.notificationDate(renewalDate: renewal, daysBefore: 3)
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: trigger)
        #expect(components.day   == 7)
        #expect(components.month == 3)
        #expect(components.year  == 2026)
        #expect(components.hour  == 9)
    }

    @Test("notificationDate with daysBefore 0 is same day at 9 AM")
    func notificationDateZeroDays() {
        let calendar = Calendar.current
        let renewal = calendar.date(from: DateComponents(year: 2026, month: 6, day: 15))!
        let trigger = DateHelpers.notificationDate(renewalDate: renewal, daysBefore: 0)
        let components = calendar.dateComponents([.day, .hour], from: trigger)
        #expect(components.day  == 15)
        #expect(components.hour == 9)
    }

    @Test("nextRenewalDate adds one month for monthly cycle")
    func nextRenewalMonthly() {
        let calendar = Calendar.current
        let base = calendar.date(from: DateComponents(year: 2026, month: 1, day: 15))!
        let next = DateHelpers.nextRenewalDate(from: base, cycle: .monthly)
        let components = calendar.dateComponents([.month, .day], from: next)
        #expect(components.month == 2)
        #expect(components.day   == 15)
    }

    @Test("nextRenewalDate adds one year for yearly cycle")
    func nextRenewalYearly() {
        let calendar = Calendar.current
        let base = calendar.date(from: DateComponents(year: 2025, month: 6, day: 1))!
        let next = DateHelpers.nextRenewalDate(from: base, cycle: .yearly)
        let components = calendar.dateComponents([.year], from: next)
        #expect(components.year == 2026)
    }
}

// MARK: - SubscriptionCategory Tests

@Suite("SubscriptionCategory")
struct SubscriptionCategoryTests {

    @Test("All cases have non-empty icon names")
    func iconNames() {
        for cat in SubscriptionCategory.allCases {
            #expect(!cat.iconName.isEmpty)
        }
    }

    @Test("All cases have non-empty display names")
    func displayNames() {
        for cat in SubscriptionCategory.allCases {
            #expect(!cat.displayName.isEmpty)
        }
    }

    @Test("Category count is 9")
    func caseCount() {
        #expect(SubscriptionCategory.allCases.count == 9)
    }
}
