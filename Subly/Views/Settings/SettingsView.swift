import SwiftUI
import SwiftData
import UserNotifications

struct SettingsView: View {
    @Query private var subscriptions: [Subscription]

    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("notificationDaysBefore") private var daysBefore: Int = 3

    @State private var permissionStatus: String = "Unknown"
    @State private var showPermissionDeniedAlert = false

    var body: some View {
        Form {
            // Notifications
            Section {
                Toggle("Renewal Reminders", isOn: $notificationsEnabled)
                    .onChange(of: notificationsEnabled) { _, enabled in
                        if enabled {
                            Task { await requestAndSchedule() }
                        } else {
                            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                        }
                    }

                if notificationsEnabled {
                    Stepper(
                        "Remind \(daysBefore) day\(daysBefore == 1 ? "" : "s") before",
                        value: $daysBefore,
                        in: 0...14
                    )
                    .onChange(of: daysBefore) { _, _ in
                        if notificationsEnabled {
                            NotificationManager.shared.rescheduleAll(
                                subscriptions: subscriptions,
                                daysBefore: daysBefore
                            )
                        }
                    }
                }
            } header: {
                Label("Notifications", systemImage: "bell.fill")
            } footer: {
                Text("You'll receive a reminder before each subscription renews.")
            }

            // Permission
            Section {
                HStack {
                    Text("Permission Status")
                    Spacer()
                    Text(permissionStatus)
                        .foregroundStyle(permissionStatus == "Granted" ? .green : .secondary)
                }

                Button("Request Permission") {
                    Task { await requestAndSchedule() }
                }
                .disabled(permissionStatus == "Granted")
            } header: {
                Label("System", systemImage: "lock.shield.fill")
            }

            // About
            Section("About") {
                LabeledContent("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                LabeledContent("Build", value: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                LabeledContent("Subscriptions tracked", value: "\(subscriptions.count)")
            }
        }
        .navigationTitle("Settings")
        .alert("Notifications Denied", isPresented: $showPermissionDeniedAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable notifications for Subly in iOS Settings to receive renewal reminders.")
        }
        .task { await refreshPermissionStatus() }
    }

    // MARK: - Helpers

    private func requestAndSchedule() async {
        let granted = await NotificationManager.shared.requestPermission()
        await refreshPermissionStatus()
        if granted {
            NotificationManager.shared.rescheduleAll(subscriptions: subscriptions, daysBefore: daysBefore)
        } else {
            showPermissionDeniedAlert = true
            notificationsEnabled = false
        }
    }

    private func refreshPermissionStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            permissionStatus = "Granted"
        case .denied:
            permissionStatus = "Denied"
        case .notDetermined:
            permissionStatus = "Not Asked"
        @unknown default:
            permissionStatus = "Unknown"
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(for: Subscription.self, inMemory: true)
}
