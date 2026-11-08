//
//  MessMenuWidget.swift
//  MessMenuWidget
//
//  Home Screen widget showing the current (or next) mess meal. Reads from
//  WidgetSharedStore — a snapshot the main app keeps up to date — rather
//  than talking to Firestore itself, since widgets run under a tight
//  memory budget the Firestore SDK isn't a great fit for.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline

private enum MealStatus { case now, next, done }

private struct MealEntry: TimelineEntry {
    let date: Date
    let plan: MessPlan
    let weekday: Weekday
    let cycleWeek: CycleWeek
    let menu: DayMenu
    let meal: MealType?
    let status: MealStatus
}

private struct MessMenuTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> MealEntry {
        entry(at: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (MealEntry) -> Void) {
        completion(entry(at: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MealEntry>) -> Void) {
        let now = Date()
        var dates = [now]

        // A fresh entry right at each remaining meal boundary today, so the
        // widget flips from "Up Next" to "Now Serving" (and on to the next
        // meal) on its own, without waiting for the system's next refresh.
        let calendar = Calendar.current
        for meal in MealType.allCases {
            let window = meal.defaultWindow
            if let start = calendar.date(bySettingHour: window.startHour, minute: window.startMinute, second: 0, of: now), start > now {
                dates.append(start)
            }
            if let end = calendar.date(bySettingHour: window.endHour, minute: window.endMinute, second: 0, of: now), end > now {
                dates.append(end)
            }
        }

        let entries = dates.sorted().map { entry(at: $0) }
        let refreshAfter = calendar.date(byAdding: .hour, value: 6, to: now) ?? now.addingTimeInterval(6 * 3600)
        completion(Timeline(entries: entries, policy: .after(refreshAfter)))
    }

    private func entry(at date: Date) -> MealEntry {
        let allEntries = WidgetSharedStore.loadEntries()
        let plan = WidgetSharedStore.loadPlan()
        let block = WidgetSharedStore.loadBlock()
        let weekday = Weekday.today(now: date)
        let cycleWeek = CycleWeek.current(for: date)
        let menu = allEntries[DayMenu.docId(block: block, plan: plan, weekday: weekday, cycleWeek: cycleWeek)]
            ?? DayMenu.empty(block: block, plan: plan, weekday: weekday, cycleWeek: cycleWeek)

        let current = MealType.allCases.first { $0.defaultWindow.contains(date) }
        let next = MealType.allCases
            .filter { !$0.defaultWindow.hasEnded(by: date) }
            .min { a, b in
                (a.defaultWindow.startHour, a.defaultWindow.startMinute) < (b.defaultWindow.startHour, b.defaultWindow.startMinute)
            }

        let meal = current ?? next
        let status: MealStatus = current != nil ? .now : (next != nil ? .next : .done)
        return MealEntry(date: date, plan: plan, weekday: weekday, cycleWeek: cycleWeek, menu: menu, meal: meal, status: status)
    }
}

// MARK: - View

private func color(for meal: MealType) -> Color {
    switch meal {
    case .breakfast: return Color(red: 0.95, green: 0.68, blue: 0.15)
    case .lunch: return Color(red: 0.93, green: 0.45, blue: 0.22)
    case .snacks: return Color(red: 0.53, green: 0.30, blue: 0.72)
    case .dinner: return Color(red: 0.20, green: 0.45, blue: 0.78)
    }
}

private struct MessMenuWidgetView: View {
    let entry: MealEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .systemLarge:
            largeBody
        case .systemMedium:
            mediumBody
        default:
            smallBody
        }
    }

    private var smallBody: some View {
        VStack(alignment: .leading, spacing: 6) {
            highlightedMealBlock(itemLimit: 3, lineLimit: 3)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .widgetBackground()
    }

    private var mediumBody: some View {
        VStack(alignment: .leading, spacing: 6) {
            highlightedMealBlock(itemLimit: nil, lineLimit: 4)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .widgetBackground()
    }

    /// Shows every meal for today, not just the current/next one, so the
    /// whole day's menu is readable at a glance in the large size.
    private var largeBody: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(entry.weekday.displayName)
                .font(.system(size: 18, weight: .bold))

            VStack(alignment: .leading, spacing: 10) {
                ForEach(MealType.allCases) { meal in
                    mealRow(meal)
                    if meal != MealType.allCases.last {
                        Divider()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .widgetBackground()
    }

    @ViewBuilder
    private func mealRow(_ meal: MealType) -> some View {
        let isHighlighted = meal == entry.meal
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: meal.icon)
                    .foregroundColor(color(for: meal))
                Text(meal.displayName)
                    .font(.system(size: 13, weight: .semibold))
                if isHighlighted {
                    Text(entry.status == .now ? "NOW" : "NEXT")
                        .font(.system(size: 9, weight: .bold))
                        .padding(.horizontal, 5).padding(.vertical, 1)
                        .background(color(for: meal).opacity(0.18))
                        .foregroundColor(color(for: meal))
                        .clipShape(Capsule())
                }
                Spacer()
                Text(meal.defaultWindow.timeRangeText)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            let items = entry.menu.items(for: meal)
            if items.isEmpty {
                Text("No items added")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            } else {
                Text(items.joined(separator: ", "))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
    }

    @ViewBuilder
    private func highlightedMealBlock(itemLimit: Int?, lineLimit: Int) -> some View {
        if let meal = entry.meal {
            HStack(spacing: 4) {
                Image(systemName: meal.icon)
                Text(entry.status == .now ? "NOW SERVING" : "UP NEXT")
            }
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(color(for: meal))

            Text(meal.displayName)
                .font(.system(size: 18, weight: .bold))

            let allItems = entry.menu.items(for: meal)
            let items = itemLimit.map { Array(allItems.prefix($0)) } ?? allItems
            if items.isEmpty {
                Text("No items added yet")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text(items.joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(lineLimit)
            }
        } else {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.secondary)
            Text("That's all the meals\nfor today")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

private extension View {
    /// `containerBackground` is iOS 17+; this keeps the widget buildable
    /// even if the extension's deployment target ever moves lower.
    @ViewBuilder
    func widgetBackground() -> some View {
        if #available(iOS 17.0, *) {
            containerBackground(for: .widget) { Color(uiColor: .systemBackground) }
        } else {
            background(Color(uiColor: .systemBackground))
        }
    }
}

// MARK: - Widget

struct MessMenuWidget: Widget {
    let kind = "MessMenuWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MessMenuTimelineProvider()) { entry in
            MessMenuWidgetView(entry: entry)
        }
        .configurationDisplayName("VIT AP Menu")
        .description("Shows the current or next mess meal.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

@main
struct MessMenuWidgetBundle: WidgetBundle {
    var body: some Widget {
        MessMenuWidget()
    }
}
