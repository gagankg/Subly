import SwiftUI

struct CategoryBadge: View {
    let category: SubscriptionCategory
    var showIcon: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            if showIcon {
                Image(systemName: category.iconName)
                    .font(.system(size: 10, weight: .semibold))
            }
            Text(category.displayName)
                .font(.caption2.weight(.semibold))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(category.color.opacity(0.15))
        .foregroundStyle(category.color)
        .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 8) {
        ForEach(SubscriptionCategory.allCases) { cat in
            CategoryBadge(category: cat, showIcon: true)
        }
    }
    .padding()
}
