import SwiftUI
import SwiftData

struct SubscriptionListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Subscription.name) private var subscriptions: [Subscription]

    @State private var showAddSheet = false
    @State private var searchText = ""
    @State private var selectedCategory: SubscriptionCategory?

    private let viewModel = SubscriptionViewModel()

    private var filtered: [Subscription] {
        viewModel.filtered(subscriptions, query: searchText, category: selectedCategory)
    }

    var body: some View {
        Group {
            if subscriptions.isEmpty {
                EmptyStateView(
                    systemImage: "rectangle.stack.badge.plus",
                    title: "No Subscriptions",
                    message: "Tap + to add your first subscription."
                )
            } else {
                List {
                    // Category filter chips
                    if !subscriptions.isEmpty {
                        categoryFilterRow
                    }

                    if filtered.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                    } else {
                        ForEach(filtered) { sub in
                            NavigationLink {
                                SubscriptionDetailView(subscription: sub)
                            } label: {
                                SubscriptionRowView(subscription: sub)
                            }
                        }
                        .onDelete(perform: delete)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Subscriptions")
        .searchable(text: $searchText, prompt: "Search subscriptions…")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            if !subscriptions.isEmpty {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddEditSubscriptionView()
        }
    }

    // MARK: - Category Filter Row

    private var categoryFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(label: "All", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(SubscriptionCategory.allCases) { cat in
                    let hasItems = subscriptions.contains { $0.category == cat }
                    if hasItems {
                        filterChip(
                            label: cat.displayName,
                            color: cat.color,
                            isSelected: selectedCategory == cat
                        ) {
                            selectedCategory = (selectedCategory == cat) ? nil : cat
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 6)
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    @ViewBuilder
    private func filterChip(
        label: String,
        color: Color = .accentColor,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color : color.opacity(0.1))
                .foregroundStyle(isSelected ? .white : color)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Delete

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            let sub = filtered[index]
            NotificationManager.shared.cancelNotification(for: sub)
            modelContext.delete(sub)
        }
    }
}

#Preview {
    NavigationStack {
        SubscriptionListView()
    }
    .modelContainer(previewContainer)
}
