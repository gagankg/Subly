import SwiftUI

// MARK: - BillingCycle

enum BillingCycle: String, Codable, CaseIterable, Identifiable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"

    var id: String { rawValue }

    var displayName: String { rawValue }

    /// Multiplier to convert cost → monthly equivalent
    var monthlyMultiplier: Double {
        switch self {
        case .weekly:  return 4.33
        case .monthly: return 1.0
        case .yearly:  return 1.0 / 12.0
        }
    }
}

// MARK: - SubscriptionCategory

enum SubscriptionCategory: String, Codable, CaseIterable, Identifiable {
    case entertainment = "Entertainment"
    case productivity  = "Productivity"
    case health        = "Health"
    case education     = "Education"
    case news          = "News"
    case utilities     = "Utilities"
    case gaming        = "Gaming"
    case finance       = "Finance"
    case other         = "Other"

    var id: String { rawValue }

    var displayName: String { rawValue }

    var iconName: String {
        switch self {
        case .entertainment: return "play.circle.fill"
        case .productivity:  return "briefcase.fill"
        case .health:        return "heart.fill"
        case .education:     return "book.fill"
        case .news:          return "newspaper.fill"
        case .utilities:     return "wrench.and.screwdriver.fill"
        case .gaming:        return "gamecontroller.fill"
        case .finance:       return "dollarsign.circle.fill"
        case .other:         return "ellipsis.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .entertainment: return .red
        case .productivity:  return .blue
        case .health:        return .green
        case .education:     return .orange
        case .news:          return .purple
        case .utilities:     return .gray
        case .gaming:        return .indigo
        case .finance:       return .teal
        case .other:         return .secondary
        }
    }
}
