import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.pie.fill")
                }

            NavigationStack {
                SubscriptionListView()
            }
            .tabItem {
                Label("Subscriptions", systemImage: "list.bullet.rectangle.fill")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Subscription.self, inMemory: true)
}
