//
//  Models.swift
//  VIT-AP Mess Menu
//

import Foundation

// MARK: - Weekday

enum Weekday: String, CaseIterable, Identifiable, Codable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
    var shortName: String { String(displayName.prefix(3)) }

    /// Firestore doc IDs sort alphabetically, not by week order, so every
    /// list that shows all seven days needs this instead of `allCases`.
    static let weekOrder: [Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]

    static func today(now: Date = Date()) -> Weekday {
        let systemWeekday = Calendar.current.component(.weekday, from: now) // 1 = Sunday ... 7 = Saturday
        let map: [Int: Weekday] = [1: .sunday, 2: .monday, 3: .tuesday, 4: .wednesday, 5: .thursday, 6: .friday, 7: .saturday]
        return map[systemWeekday] ?? .monday
    }
}

// MARK: - Fortnightly cycle

/// VIT-AP's mess menu isn't a plain 7-day repeat — each weekday alternates
/// between two different spreads every other week (confirmed against the
/// official September 2026 menu: e.g. Tuesdays on the 1st/15th/29th get one
/// menu, the 8th/22nd get another). Which one applies is determined purely
/// by the date, with no admin input needed.
enum CycleWeek: String, CaseIterable, Identifiable, Codable {
    case a, b

    var id: String { rawValue }
    var displayName: String { self == .a ? "Week A" : "Week B" }

    /// The 1st/3rd/5th occurrence of a weekday in the month is Week A, the
    /// 2nd/4th is Week B — this holds for any month, not just September.
    static func current(for date: Date = Date(), calendar: Calendar = .current) -> CycleWeek {
        let day = calendar.component(.day, from: date)
        let occurrence = (day - 1) / 7 + 1
        return occurrence % 2 == 1 ? .a : .b
    }
}

// MARK: - Hostel block

/// VIT-AP's mess menu isn't campus-wide — each hostel block runs its own.
/// Seven men's hostels (MH-1...MH-7) and four ladies' hostels (LH-1...LH-4).
enum HostelBlock: String, CaseIterable, Identifiable, Codable {
    case mh1, mh2, mh3, mh4, mh5, mh6, mh7
    case lh1, lh2, lh3, lh4

    var id: String { rawValue }

    var displayName: String {
        let number = rawValue.drop { !$0.isNumber }
        return rawValue.hasPrefix("mh") ? "MH-\(number)" : "LH-\(number)"
    }

    var kind: Kind {
        rawValue.hasPrefix("mh") ? .mensHostel : .ladiesHostel
    }

    enum Kind { case mensHostel, ladiesHostel }

    static let mensHostels: [HostelBlock] = [.mh1, .mh2, .mh3, .mh4, .mh5, .mh6, .mh7]
    static let ladiesHostels: [HostelBlock] = [.lh1, .lh2, .lh3, .lh4]
    /// Display order (MH-1...7 then LH-1...4) — `allCases` is alphabetical,
    /// which would put lh1 before mh2.
    static let all: [HostelBlock] = mensHostels + ladiesHostels
}

// MARK: - Mess plan

/// VIT-AP runs two parallel menus: the standard mess, and a "Special Mess"
/// plan with extra items (fresh juice, cereal, soup) some students opt into.
enum MessPlan: String, CaseIterable, Identifiable, Codable {
    case regular, special

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .regular: return "Regular Mess"
        case .special: return "Special Mess"
        }
    }
}

// MARK: - Meals

enum MealType: String, CaseIterable, Identifiable, Codable {
    case breakfast, lunch, snacks, dinner

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }

    var icon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .snacks: return "cup.and.saucer.fill"
        case .dinner: return "moon.stars.fill"
        }
    }

    /// VIT-AP mess timings.
    var defaultWindow: MealWindow {
        switch self {
        case .breakfast: return MealWindow(startHour: 7, startMinute: 0, endHour: 9, endMinute: 0)
        case .lunch: return MealWindow(startHour: 12, startMinute: 30, endHour: 14, endMinute: 0)
        case .snacks: return MealWindow(startHour: 16, startMinute: 0, endHour: 18, endMinute: 0)
        case .dinner: return MealWindow(startHour: 19, startMinute: 0, endHour: 21, endMinute: 0)
        }
    }
}

struct MealWindow {
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int

    func contains(_ date: Date, calendar: Calendar = .current) -> Bool {
        let comps = calendar.dateComponents([.hour, .minute], from: date)
        guard let hour = comps.hour, let minute = comps.minute else { return false }
        let minutesNow = hour * 60 + minute
        let start = startHour * 60 + startMinute
        let end = endHour * 60 + endMinute
        return minutesNow >= start && minutesNow < end
    }

    func hasEnded(by date: Date, calendar: Calendar = .current) -> Bool {
        let comps = calendar.dateComponents([.hour, .minute], from: date)
        guard let hour = comps.hour, let minute = comps.minute else { return false }
        let minutesNow = hour * 60 + minute
        return minutesNow >= endHour * 60 + endMinute
    }

    var timeRangeText: String {
        "\(Self.format(startHour, startMinute)) – \(Self.format(endHour, endMinute))"
    }

    private static func format(_ hour: Int, _ minute: Int) -> String {
        var comps = DateComponents()
        comps.hour = hour
        comps.minute = minute
        let date = Calendar.current.date(from: comps) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Day menu

/// One (block, plan, weekday, cycle-week) combination's spread across all
/// four meals. Stored in Firestore under `messMenu/{id}`,
/// id = "<block>_<plan>_<weekday>_<cycleWeek>".
///
/// `block` defaults to `.mh1` so existing call sites/literals that predate
/// per-hostel menus (RealMenuSeed's generated entries) keep compiling —
/// callers that care about a specific block pass it explicitly.
struct DayMenu: Codable, Identifiable, Equatable {
    var id: String
    var block: HostelBlock = .mh1
    var plan: MessPlan
    var weekday: Weekday
    var cycleWeek: CycleWeek
    var breakfast: [String] = []
    var lunch: [String] = []
    var snacks: [String] = []
    var dinner: [String] = []

    func items(for meal: MealType) -> [String] {
        switch meal {
        case .breakfast: return breakfast
        case .lunch: return lunch
        case .snacks: return snacks
        case .dinner: return dinner
        }
    }

    mutating func setItems(_ items: [String], for meal: MealType) {
        switch meal {
        case .breakfast: breakfast = items
        case .lunch: lunch = items
        case .snacks: snacks = items
        case .dinner: dinner = items
        }
    }

    static func docId(block: HostelBlock, plan: MessPlan, weekday: Weekday, cycleWeek: CycleWeek) -> String {
        "\(block.rawValue)_\(plan.rawValue)_\(weekday.rawValue)_\(cycleWeek.rawValue)"
    }

    static func empty(block: HostelBlock, plan: MessPlan, weekday: Weekday, cycleWeek: CycleWeek) -> DayMenu {
        DayMenu(id: docId(block: block, plan: plan, weekday: weekday, cycleWeek: cycleWeek), block: block, plan: plan, weekday: weekday, cycleWeek: cycleWeek)
    }
}
