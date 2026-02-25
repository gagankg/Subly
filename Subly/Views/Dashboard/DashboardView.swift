import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \Subscription.name) private var subscriptions: [Subscription]

    private let viewModel = SubscriptionViewModel()

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    if subscriptions.isEmpty {
                        EmptyStateView(
                            systemImage: "chart.pie",
                            title: "No Data Yet",
                            message: "Add subscriptions from the Subscriptions tab."
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    } else {
                        // Summary cards
                        summarySection

                        // Category breakdown
                        categorySection

                        // Renewing soon
                        renewingSoonSection
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .navigationTitle("Dashboard")
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Summary Cards

    private var summarySection: some View {
        HStack(spacing: 12) {
            CostCard(
                title: "Monthly",
                amount: viewModel.monthlyTotal(for: subscriptions),
                subtitle: "\(subscriptions.filter(\.isActive).count) active subscription\(subscriptions.filter(\.isActive).count == 1 ? "" : "s")",
                color: .blue,
                systemImage: "calendar"
            )
            CostCard(
                title: "Yearly",
                amount: viewModel.yearlyTotal(for: subscriptions),
                subtitle: "Estimated annual spend",
                color: .purple,
                systemImage: "chart.line.uptrend.xyaxis"
            )
        }
    }

    // MARK: - Category Breakdown

    private var categorySection: some View {
        let breakdown = viewModel.totalByCategory(for: subscriptions)

        return VStack(alignment: .leading, spacing: 12) {
            sectionHeader("By Category", systemImage: "square.grid.2x2.fill")

            if breakdown.isEmpty {
                Text("No active subscriptions")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(breakdown.enumerated()), id: \.element.category) { index, item in
                        categoryRow(item: item, breakdown: breakdown)
                        if index < breakdown.count - 1 {
                            Divider().padding(.leading, 44)
                        }
                    }
                }
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    private func categoryRow(
        item: (category: SubscriptionCategory, total: Double),
        breakdown: [(category: SubscriptionCategory, total: Double)]
    ) -> some View {
        let maxTotal = breakdown.first?.total ?? 1
        let fraction = item.total / max(maxTotal, 1)

        return HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(item.category.color.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: item.category.iconName)
                    .font(.system(size: 16))
                    .foregroundStyle(item.category.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.category.displayName)
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Text(item.total, format: .currency(code: currencyCode))
                        .font(.subheadline.weight(.semibold))
                }
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(item.category.color.opacity(0.3))
                        .frame(width: geo.size.width)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(item.category.color)
                        .frame(width: max(4, geo.size.width * fraction))
                }
                .frame(height: 4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Renewing Soon

    @ViewBuilder
    private var renewingSoonSection: some View {
        let soon = viewModel.renewingSoon(from: subscriptions)
        if !soon.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader("Renewing Soon", systemImage: "bell.fill", color: .orange)

                VStack(spacing: 0) {
                    ForEach(Array(soon.enumerated()), id: \.element.id) { index, sub in
                        renewalRow(sub: sub)
                        if index < soon.count - 1 {
                            Divider().padding(.leading, 56)
                        }
                    }
                }
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    private func renewalRow(sub: Subscription) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(sub.category.color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: sub.category.iconName)
                    .font(.system(size: 18))
                    .foregroundStyle(sub.category.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(sub.name)
                    .font(.subheadline.weight(.medium))
                Text(sub.renewalDate, format: .dateTime.day().month())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(sub.cost, format: .currency(code: currencyCode))
                    .font(.subheadline.weight(.semibold))
                daysLabel(sub.daysUntilRenewal)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func daysLabel(_ days: Int) -> some View {
        let text: String
        let color: Color
        switch days {
        case 0:
            text = "Today"
            color = .red
        case 1:
            text = "Tomorrow"
            color = .orange
        default:
            text = "In \(days) days"
            color = days <= 3 ? .orange : .secondary
        }
        return Text(text)
            .font(.caption.weight(.medium))
            .foregroundStyle(color)
    }

    // MARK: - Section Header

    private func sectionHeader(
        _ title: String,
        systemImage: String,
        color: Color = .secondary
    ) -> some View {
        Label(title, systemImage: systemImage)
            .font(.headline)
            .foregroundStyle(color == .secondary ? .primary : color)
    }
}

#Preview {
    DashboardView()
        .modelContainer(previewContainer)
}
