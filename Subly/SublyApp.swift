import SwiftUI
import SwiftData

@main
struct SublyApp: App {
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("notificationDaysBefore") private var daysBefore: Int = 3

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Subscription.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    // Re-schedule all notifications on every launch
                    if notificationsEnabled {
                        let context = sharedModelContainer.mainContext
                        let descriptor = FetchDescriptor<Subscription>()
                        let subscriptions = (try? context.fetch(descriptor)) ?? []
                        NotificationManager.shared.rescheduleAll(
                            subscriptions: subscriptions,
                            daysBefore: daysBefore
                        )
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
