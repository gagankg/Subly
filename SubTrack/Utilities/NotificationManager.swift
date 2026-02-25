import Foundation
import UserNotifications

@MainActor
final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    private let center = UNUserNotificationCenter.current()

    // MARK: - Permission

    @discardableResult
    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            print("NotificationManager: permission error — \(error)")
            return false
        }
    }

    var isAuthorized: Bool {
        get async {
            let settings = await center.notificationSettings()
            return settings.authorizationStatus == .authorized
        }
    }

    // MARK: - Schedule

    /// Schedules (or re-schedules) a reminder `daysBefore` days ahead of the renewal date at 9 AM.
    func scheduleNotification(for subscription: Subscription, daysBefore: Int) {
        // Remove any existing notification for this subscription first
        cancelNotification(for: subscription)

        guard subscription.isActive else { return }

        let triggerDate = DateHelpers.notificationDate(
            renewalDate: subscription.renewalDate,
            daysBefore: daysBefore
        )

        // Don't schedule notifications in the past
        guard triggerDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Renewing Soon: \(subscription.name)"
        let currencyCode = Locale.current.currency?.identifier ?? "USD"
        let formatted = subscription.cost.formatted(.currency(code: currencyCode))
        let days = daysBefore == 0 ? "today" : "in \(daysBefore) day\(daysBefore == 1 ? "" : "s")"
        content.body = "\(subscription.name) renews \(days) for \(formatted)."
        content.sound = .default
        content.badge = 1

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: triggerDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: subscription.id.uuidString,
            content: content,
            trigger: trigger
        )

        // Capture primitives to avoid Sendable issues in the callback
        let subName = subscription.name
        center.add(request) { error in
            if let error {
                print("NotificationManager: schedule error for \(subName) — \(error)")
            }
        }
    }

    // MARK: - Cancel

    func cancelNotification(for subscription: Subscription) {
        center.removePendingNotificationRequests(withIdentifiers: [subscription.id.uuidString])
    }

    // MARK: - Reschedule All

    /// Called on app launch and when notification settings change.
    func rescheduleAll(subscriptions: [Subscription], daysBefore: Int) {
        // Remove all pending notifications then re-add
        center.removeAllPendingNotificationRequests()
        for sub in subscriptions where sub.isActive {
            scheduleNotification(for: sub, daysBefore: daysBefore)
        }
    }
}
