//
//  WidgetSharedStore.swift
//  VIT-AP Mess Menu
//
//  A widget runs in its own process and has no access to MenuStore's live
//  Firestore listener (and shouldn't embed the Firestore SDK itself — it's
//  too heavy for a widget's memory budget). Instead, the main app writes a
//  snapshot of the current menu here, into a container shared via an App
//  Group, and the widget just reads that snapshot. Compiled into both the
//  main app and the MessMenuWidget extension targets.
//
//  The App Group ("group.com.example.VITAPMenu") must be added as
//  a capability on both targets in Xcode (Signing & Capabilities) — it
//  can't be created by editing this file alone.
//

import Foundation

enum WidgetSharedStore {
    static let appGroupID = "group.com.example.VITAPMenu"

    private static let entriesKey = "widgetEntries"
    private static let planKey = "messPlan"
    private static let blockKey = "myHostelBlock"

    /// Falls back to `.standard` if the App Group isn't provisioned yet
    /// (e.g. the capability hasn't been added in Xcode), so the app never
    /// crashes over this — the widget just won't have fresh data until it is.
    static var sharedDefaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }

    static func saveEntries(_ entries: [String: DayMenu]) {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        sharedDefaults.set(data, forKey: entriesKey)
    }

    static func loadEntries() -> [String: DayMenu] {
        guard let data = sharedDefaults.data(forKey: entriesKey),
              let decoded = try? JSONDecoder().decode([String: DayMenu].self, from: data) else {
            return RealMenuSeed.bundledEntries()
        }
        return decoded
    }

    static func loadPlan() -> MessPlan {
        MessPlan(rawValue: sharedDefaults.string(forKey: planKey) ?? "") ?? .regular
    }

    static func loadBlock() -> HostelBlock {
        HostelBlock(rawValue: sharedDefaults.string(forKey: blockKey) ?? "") ?? .mh1
    }
}
