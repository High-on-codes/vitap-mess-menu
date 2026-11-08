//
//  TodayView.swift
//  VIT-AP Mess Menu
//

import SwiftUI
import Combine

struct TodayView: View {
    @EnvironmentObject var menuStore: MenuStore
    @AppStorage("messPlan", store: WidgetSharedStore.sharedDefaults) private var messPlanRaw = MessPlan.regular.rawValue
    @AppStorage("myHostelBlock", store: WidgetSharedStore.sharedDefaults) private var myBlockRaw = HostelBlock.mh1.rawValue
    @State private var now = Date()
    @State private var showCycleInfo = false
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    private var plan: MessPlan { MessPlan(rawValue: messPlanRaw) ?? .regular }
    private var block: HostelBlock { HostelBlock(rawValue: myBlockRaw) ?? .mh1 }
    private var today: Weekday { Weekday.today(now: now) }
    private var cycleWeek: CycleWeek { CycleWeek.current(for: now) }
    private var menu: DayMenu { menuStore.menu(block: block, plan: plan, weekday: today, cycleWeek: cycleWeek) }

    private var currentMeal: MealType? {
        MealType.allCases.first { $0.defaultWindow.contains(now) }
    }

    private var nextMeal: MealType? {
        MealType.allCases
            .filter { !$0.defaultWindow.hasEnded(by: now) }
            .min { a, b in
                (a.defaultWindow.startHour, a.defaultWindow.startMinute) < (b.defaultWindow.startHour, b.defaultWindow.startMinute)
            }
    }

    private var highlightedMeal: MealType? { currentMeal ?? nextMeal }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.pageBackground.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        header

                        if !menuStore.isBlockLive(block) {
                            notUploadedBanner
                        }

                        if let highlightedMeal {
                            MealCard(
                                meal: highlightedMeal,
                                items: menu.items(for: highlightedMeal),
                                status: currentMeal != nil ? .now : .next
                            )
                        } else {
                            doneForTodayBanner
                        }

                        ForEach(MealType.allCases) { meal in
                            if meal != highlightedMeal {
                                MealRow(meal: meal, items: menu.items(for: meal), isPast: meal.defaultWindow.hasEnded(by: now))
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Today")
            .onReceive(timer) { now = $0 }
            .alert("What are Week A / Week B?", isPresented: $showCycleInfo) {
                Button("Got it", role: .cancel) {}
            } message: {
                Text("VIT-AP's mess menu repeats on a two-week cycle instead of a plain weekly one. Each weekday has two different menus that alternate — e.g. Tuesdays on the 1st, 15th and 29th get one menu, while the 8th and 22nd get another. Week A / Week B just shows which of the two is active today; it's calculated from the date automatically.")
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(today.displayName).font(.system(size: 28, weight: .bold))
                Spacer()
                Button {
                    showCycleInfo = true
                } label: {
                    HStack(spacing: 4) {
                        Text(cycleWeek.displayName)
                        Image(systemName: "info.circle")
                    }
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Theme.accent.opacity(0.15))
                    .foregroundColor(Theme.accent)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            Text(now.formatted(date: .long, time: .omitted)).foregroundColor(.secondary)
            Text(block.displayName + (plan != .regular ? " · \(plan.displayName)" : ""))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var notUploadedBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.icloud").foregroundColor(.orange)
            Text("\(block.displayName)'s menu hasn't been uploaded yet — showing sample data.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.12))
        .cornerRadius(10)
    }

    private var doneForTodayBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill").foregroundColor(.secondary)
            Text("That's all the meals for today.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

enum MealStatus { case now, next }

struct MealCard: View {
    let meal: MealType
    let items: [String]
    let status: MealStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: meal.icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Theme.gradient(Theme.color(forMeal: meal)))
                    .clipShape(Circle())
                VStack(alignment: .leading) {
                    Text(status == .now ? "Now Serving" : "Up Next")
                        .font(.caption.weight(.bold))
                        .foregroundColor(Theme.color(forMeal: meal))
                    Text(meal.displayName).font(.title3.weight(.bold))
                }
                Spacer()
                Text(meal.defaultWindow.timeRangeText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            if items.isEmpty {
                Text("No items added yet").foregroundColor(.secondary).font(.subheadline)
            } else {
                FoodChipGroup(items: items, color: Theme.color(forMeal: meal))
            }
        }
        .cardStyle()
        .appears()
    }
}

struct MealRow: View {
    let meal: MealType
    let items: [String]
    let isPast: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: meal.icon).foregroundColor(Theme.color(forMeal: meal))
                Text(meal.displayName).font(.subheadline.weight(.semibold))
                Spacer()
                Text(meal.defaultWindow.timeRangeText).font(.caption2).foregroundColor(.secondary)
            }
            if items.isEmpty {
                Text("No items added").font(.caption).foregroundColor(.secondary)
            } else {
                FoodChipGroup(items: items, color: Theme.color(forMeal: meal), compact: true)
            }
        }
        .cardStyle(padding: 12)
        .opacity(isPast ? 0.7 : 1)
    }
}
