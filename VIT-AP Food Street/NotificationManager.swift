//
//  NotificationManager.swift
//  VIT-AP Mess Menu
//
//  Daily local reminders shortly before each meal window opens. Generic by
//  design ("Lunch is starting soon") rather than naming dishes, since that
//  would need a background fetch of the day's Firestore data at schedule
//  time — a repeating calendar trigger covers the common case with none of
//  that complexity.
//

import Foundation
import UserNotifications

enum NotificationManager {
    private static let identifierPrefix = "mess-reminder-"
    private static let enabledKey = "notificationsEnabled"

    static var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: enabledKey) }
        set { UserDefaults.standard.set(newValue, forKey: enabledKey) }
    }

    static func requestAuthorizationAndSchedule() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            isEnabled = true
            scheduleAll()
        }
    }

    static func disable() {
        isEnabled = false
        cancelAll()
    }

    static func scheduleAll() {
        cancelAll()
        guard isEnabled else { return }

        let center = UNUserNotificationCenter.current()
        for meal in MealType.allCases {
            let window = meal.defaultWindow
            var leadMinute = window.startMinute - AppConfig.reminderLeadMinutes
            var leadHour = window.startHour
            while leadMinute < 0 {
                leadMinute += 60
                leadHour -= 1
            }
            leadHour = (leadHour + 24) % 24

            let content = UNMutableNotificationContent()
            content.title = "\(meal.displayName) time soon"
            content.body = "\(meal.displayName) starts at \(window.timeRangeText.components(separatedBy: " – ").first ?? "") — check today's menu."
            content.sound = .default

            var trigger = DateComponents()
            trigger.hour = leadHour
            trigger.minute = leadMinute

            let request = UNNotificationRequest(
                identifier: identifierPrefix + meal.rawValue,
                content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: trigger, repeats: true)
            )
            center.add(request)
        }
    }

    static func cancelAll() {
        let ids = MealType.allCases.map { identifierPrefix + $0.rawValue }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }
}
