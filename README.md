# Subly

A native iOS app for tracking personal subscriptions — Netflix, Spotify, iCloud, and anything else that bills you regularly.

## Features

- **Dashboard** — monthly and yearly spend totals, per-category breakdown with progress bars, and a "Renewing Soon" list for anything due in the next 7 days
- **Subscription list** — full list with search and category filter chips, swipe to delete
- **Add / Edit** — form covering name, cost, billing cycle (weekly / monthly / yearly), renewal date, category, and notes
- **Renewal reminders** — local notifications scheduled at 9 AM a configurable number of days before each renewal
- **Settings** — toggle notifications on/off, choose how many days in advance to be reminded

## Tech Stack

| Layer | Technology |
|---|---|
| UI | SwiftUI |
| Persistence | SwiftData |
| Notifications | UserNotifications |
| Min deployment | iOS 17.0 |
| Dependencies | None |

## Project Structure

```
Subly/
├── SublyApp.swift
├── ContentView.swift
├── Models/
│   ├── Subscription.swift
│   └── SubscriptionCategory.swift
├── ViewModels/
│   └── SubscriptionViewModel.swift
├── Views/
│   ├── Dashboard/DashboardView.swift
│   ├── Subscriptions/
│   │   ├── SubscriptionListView.swift
│   │   ├── SubscriptionRowView.swift
│   │   ├── AddEditSubscriptionView.swift
│   │   └── SubscriptionDetailView.swift
│   └── Settings/SettingsView.swift
├── Utilities/
│   ├── NotificationManager.swift
│   └── DateHelpers.swift
└── Components/
    ├── CategoryBadge.swift
    ├── CostCard.swift
    └── EmptyStateView.swift
```

## Getting Started

1. Open `Subly.xcodeproj` in Xcode 15 or later
2. Select an iPhone simulator (iOS 17+)
3. Press **Cmd+R** to build and run

To enable renewal notifications, go to the **Settings** tab inside the app and tap **Request Permission**.

## Running Tests

```
Cmd+U
```

29 unit tests cover billing cycle math, monthly cost normalisation, ViewModel aggregates, date helpers, and category metadata.
