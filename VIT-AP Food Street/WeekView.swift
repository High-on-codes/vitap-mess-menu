//
//  WeekView.swift
//  VIT-AP Mess Menu
//

import SwiftUI

struct WeekView: View {
    @EnvironmentObject var menuStore: MenuStore
    @AppStorage("messPlan", store: WidgetSharedStore.sharedDefaults) private var messPlanRaw = MessPlan.regular.rawValue
    @AppStorage("myHostelBlock", store: WidgetSharedStore.sharedDefaults) private var myBlockRaw = HostelBlock.mh1.rawValue
    @State private var selectedCycle: CycleWeek = .current()
    @State private var expandedDay: Weekday = .today()
    @State private var showCycleInfo = false

    private var plan: MessPlan { MessPlan(rawValue: messPlanRaw) ?? .regular }
    private var block: HostelBlock { HostelBlock(rawValue: myBlockRaw) ?? .mh1 }
    private let today = Weekday.today()
    private let currentCycle = CycleWeek.current()

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.pageBackground.ignoresSafeArea()
                VStack(spacing: 0) {
                    HStack {
                        Picker("Cycle Week", selection: $selectedCycle) {
                            ForEach(CycleWeek.allCases) { cycle in
                                Text(cycle == currentCycle ? "\(cycle.displayName) (Now)" : cycle.displayName).tag(cycle)
                            }
                        }
                        .pickerStyle(.segmented)
                        Button {
                            showCycleInfo = true
                        } label: {
                            Image(systemName: "info.circle")
                        }
                    }
                    .padding()

                    if !menuStore.isBlockLive(block) {
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
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }

                    List {
                        ForEach(Weekday.weekOrder) { day in
                            Section {
                                DisclosureGroup(isExpanded: Binding(
                                    get: { expandedDay == day },
                                    set: { isOpen in expandedDay = isOpen ? day : expandedDay }
                                )) {
                                    let menu = menuStore.menu(block: block, plan: plan, weekday: day, cycleWeek: selectedCycle)
                                    ForEach(MealType.allCases) { meal in
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Image(systemName: meal.icon).foregroundColor(Theme.color(forMeal: meal))
                                                Text(meal.displayName).font(.subheadline.weight(.semibold))
                                                Spacer()
                                                Text(meal.defaultWindow.timeRangeText).font(.caption2).foregroundColor(.secondary)
                                            }
                                            let items = menu.items(for: meal)
                                            if items.isEmpty {
                                                Text("No items added").font(.caption).foregroundColor(.secondary)
                                            } else {
                                                FoodChipGroup(items: items, color: Theme.color(forMeal: meal), compact: true)
                                            }
                                        }
                                        .padding(.vertical, 4)
                                    }
                                } label: {
                                    HStack {
                                        Text(day.displayName).font(.headline)
                                        if day == today && selectedCycle == currentCycle {
                                            Text("Today")
                                                .font(.caption2.weight(.bold))
                                                .padding(.horizontal, 8).padding(.vertical, 2)
                                                .background(Theme.accent.opacity(0.15))
                                                .foregroundColor(Theme.accent)
                                                .clipShape(Capsule())
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("\(block.displayName)" + (plan == .regular ? "" : " · \(plan.displayName)"))
            .alert("What are Week A / Week B?", isPresented: $showCycleInfo) {
                Button("Got it", role: .cancel) {}
            } message: {
                Text("VIT-AP's mess menu repeats on a two-week cycle instead of a plain weekly one. Each weekday has two different menus that alternate — e.g. Tuesdays on the 1st, 15th and 29th get one menu, while the 8th and 22nd get another. Week A / Week B just shows which of the two is active; it's calculated from the date automatically.")
            }
        }
    }
}
