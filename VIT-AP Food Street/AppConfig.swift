//
//  AppConfig.swift
//  VIT-AP Mess Menu
//
//  Switches kept in one place so they don't get lost inside a view file.
//

import Foundation

enum AppConfig {
    /// Only this signed-in email can write to `messMenu` in Firestore
    /// (mirrored in firestore.rules — change both together).
    static let adminEmail = "admin@example.com"

    /// How long before a meal window starts to fire the local reminder.
    static let reminderLeadMinutes = 20
}
