import Foundation

enum DateHelpers {
    /// Returns the date at 9 AM, `daysBefore` days before `renewalDate`.
    static func notificationDate(renewalDate: Date, daysBefore: Int) -> Date {
        let calendar = Calendar.current
        // Go back `daysBefore` days
        let base = calendar.date(byAdding: .day, value: -daysBefore, to: renewalDate) ?? renewalDate
        // Set to 9 AM
        return calendar.date(
            bySettingHour: 9,
            minute: 0,
            second: 0,
            of: base
        ) ?? base
    }

    /// Human-readable string for daysUntilRenewal.
    static func renewalLabel(daysUntilRenewal: Int) -> String {
        switch daysUntilRenewal {
        case ..<0:  return "Overdue"
        case 0:     return "Today"
        case 1:     return "Tomorrow"
        default:    return "In \(daysUntilRenewal) days"
        }
    }

    /// Returns the next same-day date after today for a given day-of-month (used for auto-advance).
    static func nextRenewalDate(from date: Date, cycle: BillingCycle) -> Date {
        let calendar = Calendar.current
        switch cycle {
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: date) ?? date
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: date) ?? date
        }
    }
}
