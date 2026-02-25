import SwiftUI

struct CostCard: View {
    let title: String
    let amount: Double
    let subtitle: String
    var color: Color = .accentColor
    var systemImage: String = "creditcard.fill"

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: systemImage)
                    .font(.subheadline)
                    .foregroundStyle(color)
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            Text(amount, format: .currency(code: currencyCode))
                .font(.title.bold())
                .foregroundStyle(.primary)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    HStack(spacing: 12) {
        CostCard(
            title: "Monthly",
            amount: 49.97,
            subtitle: "Across 5 subscriptions",
            color: .blue,
            systemImage: "calendar"
        )
        CostCard(
            title: "Yearly",
            amount: 599.64,
            subtitle: "Estimated annual spend",
            color: .purple,
            systemImage: "chart.line.uptrend.xyaxis"
        )
    }
    .padding()
}
