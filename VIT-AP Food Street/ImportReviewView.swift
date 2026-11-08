//
//  ImportReviewView.swift
//  VIT-AP Mess Menu
//
//  Shown after picking an .xlsx and before anything touches Firestore —
//  lets the admin actually see what got parsed (as the same chip UI
//  students see) rather than trusting a bare "N entries found" count.
//  Anything the deterministic parser couldn't read shows up here too,
//  with an on-device Apple Intelligence retry instead of silently
//  vanishing.
//

import SwiftUI

struct ImportReviewView: View {
    @EnvironmentObject var menuStore: MenuStore
    @Environment(\.dismiss) private var dismiss

    @State var menus: [DayMenu]
    @State var unresolved: [UnresolvedMenuBlock]

    @State private var resolvingBlockID: UnresolvedMenuBlock.ID?
    @State private var aiErrorByBlock: [UnresolvedMenuBlock.ID: String] = [:]
    @State private var isImporting = false
    @State private var importDone = false

    private var aiAvailable: Bool {
        if #available(iOS 26.0, *) {
            return AIMenuExtractor.isAvailable
        }
        return false
    }

    private var aiUnavailableReason: String? {
        if #available(iOS 26.0, *) {
            return AIMenuExtractor.unavailableReason
        }
        return "Needs iOS 26 or later."
    }

    var body: some View {
        List {
            Section {
                summaryRow
            }

            if !unresolved.isEmpty {
                Section("Needs Review (\(unresolved.count))") {
                    ForEach(unresolved) { block in
                        unresolvedRow(block)
                    }
                }
            }

            if !menus.isEmpty {
                Section("Parsed Entries (\(menus.count))") {
                    ForEach(menus.sorted(by: { $0.id < $1.id })) { menu in
                        entryRow(menu)
                    }
                }
            }
        }
        .navigationTitle("Review Import")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    Task {
                        isImporting = true
                        await menuStore.importParsed(menus)
                        isImporting = false
                        if menuStore.saveError == nil { importDone = true }
                    }
                } label: {
                    if isImporting {
                        ProgressView()
                    } else {
                        Text("Import \(menus.count)")
                    }
                }
                .disabled(isImporting || menus.isEmpty)
            }
        }
        .alert("Imported", isPresented: $importDone) {
            Button("Done") { dismiss() }
        } message: {
            Text("\(menus.count) entries are now live.")
        }
        .alert("Save Failed", isPresented: Binding(
            get: { menuStore.saveError != nil },
            set: { isPresented in if !isPresented { menuStore.saveError = nil } }
        )) {
            Button("OK") {}
        } message: {
            Text(menuStore.saveError ?? "")
        }
    }

    private var summaryRow: some View {
        HStack(spacing: 12) {
            Image(systemName: unresolved.isEmpty ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.title2)
                .foregroundColor(unresolved.isEmpty ? .green : .orange)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(menus.count) entries parsed automatically").font(.subheadline.weight(.semibold))
                if !unresolved.isEmpty {
                    Text("\(unresolved.count) block\(unresolved.count == 1 ? "" : "s") need a closer look before importing.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("Everything in the file was understood.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func entryRow(_ menu: DayMenu) -> some View {
        DisclosureGroup {
            ForEach(MealType.allCases) { meal in
                let items = menu.items(for: meal)
                if !items.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(meal.displayName).font(.caption.weight(.semibold)).foregroundColor(.secondary)
                        FoodChipGroup(items: items, color: Theme.color(forMeal: meal), compact: true)
                    }
                    .padding(.vertical, 4)
                }
            }
        } label: {
            HStack(spacing: 8) {
                Text(menu.weekday.displayName).font(.subheadline.weight(.semibold))
                Text(menu.cycleWeek.displayName)
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(Theme.accent.opacity(0.15))
                    .foregroundColor(Theme.accent)
                    .clipShape(Capsule())
                Spacer()
                Text(menu.plan.displayName).font(.caption2).foregroundColor(.secondary)
            }
        }
    }

    private func unresolvedRow(_ block: UnresolvedMenuBlock) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(block.headerText.replacingOccurrences(of: "\n", with: "  ·  "))
                .font(.subheadline.weight(.semibold))
            Text(block.rawText)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(4)

            if let error = aiErrorByBlock[block.id] {
                Text(error).font(.caption2).foregroundColor(.red)
            }

            HStack {
                if resolvingBlockID == block.id {
                    ProgressView()
                } else if aiAvailable {
                    Button {
                        Task { await tryResolveWithAI(block) }
                    } label: {
                        Label("Try with Apple Intelligence", systemImage: "sparkles")
                    }
                    .font(.caption.weight(.semibold))
                } else if let reason = aiUnavailableReason {
                    Text(reason).font(.caption2).foregroundColor(.secondary)
                }
                Spacer()
                Text(block.plan.displayName).font(.caption2).foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func tryResolveWithAI(_ block: UnresolvedMenuBlock) async {
        guard #available(iOS 26.0, *) else { return }
        resolvingBlockID = block.id
        aiErrorByBlock[block.id] = nil
        defer { resolvingBlockID = nil }
        do {
            let menu = try await AIMenuExtractor.resolve(block)
            menus.append(menu)
            unresolved.removeAll { $0.id == block.id }
        } catch {
            aiErrorByBlock[block.id] = "Apple Intelligence couldn't read this one either — add it manually from Edit Menu instead."
        }
    }
}
