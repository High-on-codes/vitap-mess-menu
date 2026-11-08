//
//  RealMenuSeed.swift
//  VIT-AP Mess Menu
//
//  Placeholder menu bundled with the app so every screen has content
//  before a block's operator uploads a real one.
//

import Foundation

enum RealMenuSeed {
    private static let templateEntries: [DayMenu] = MessPlan.allCases.flatMap { plan in
        Weekday.allCases.flatMap { weekday in
            CycleWeek.allCases.map { cycleWeek in
                DayMenu(
                    id: "",
                    plan: plan,
                    weekday: weekday,
                    cycleWeek: cycleWeek,
                    breakfast: ["Sample Breakfast Item", "Tea/Coffee/Milk"],
                    lunch: ["White Rice", "Sample Curry", "Curd"],
                    snacks: ["Sample Snack", "Tea/Coffee/Milk"],
                    dinner: ["Roti", "Sample Curry", "Fruit"]
                )
            }
        }
    }

    /// `templateEntries` re-stamped with every hostel block's own id/block
    /// field — 11 blocks x 28 template entries.
    static var all: [DayMenu] {
        HostelBlock.all.flatMap { block in
            templateEntries.map { entry -> DayMenu in
                var copy = entry
                copy.block = block
                copy.id = DayMenu.docId(block: block, plan: copy.plan, weekday: copy.weekday, cycleWeek: copy.cycleWeek)
                return copy
            }
        }
    }

    static func bundledEntries() -> [String: DayMenu] {
        Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
    }
}
