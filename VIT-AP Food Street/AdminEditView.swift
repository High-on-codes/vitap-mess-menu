//
//  AdminEditView.swift
//  VIT-AP Mess Menu
//

import SwiftUI
import UniformTypeIdentifiers

struct AdminEditView: View {
    @EnvironmentObject var menuStore: MenuStore
    @EnvironmentObject var adminAuth: AdminAuthManager

    @State private var selectedBlock: HostelBlock = .mh1
    @State private var selectedPlan: MessPlan = .regular
    @State private var selectedCycle: CycleWeek = .current()
    @State private var selectedDay: Weekday = .today()
    @State private var draft: DayMenu = .empty(block: .mh1, plan: .regular, weekday: .monday, cycleWeek: .a)
    @State private var isSaving = false
    @State private var savedConfirmation = false

    @State private var showFilePicker = false
    @State private var parseError: String?
    @State private var reviewPayload: ParsedWorkbook?
    @State private var showReview = false

    private var xlsxType: UTType { UTType(filenameExtension: "xlsx") ?? .data }

    var body: some View {
        Form {
            if let listenerError = menuStore.listenerError {
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Edits aren't saving", systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .font(.subheadline.weight(.semibold))
                        Text(listenerError)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("This usually means the Firestore security rules published in the Firebase Console don't match firestore.rules yet — an edit can look like it saved for a moment, then silently revert. Publish the current rules (Firestore Database -> Rules -> paste firestore.rules -> Publish) and try again.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Section("Hostel Block") {
                if adminAuth.allowedBlocks.count > 1 {
                    Picker("Block", selection: $selectedBlock) {
                        ForEach(adminAuth.allowedBlocks) { block in
                            Text(block.displayName).tag(block)
                        }
                    }
                    .pickerStyle(.menu)
                } else {
                    HStack {
                        Text("Block")
                        Spacer()
                        Text(selectedBlock.displayName).foregroundColor(.secondary)
                    }
                }
            }

            Section("Import from Files") {
                Button {
                    parseError = nil
                    showFilePicker = true
                } label: {
                    Label("Choose Excel File (.xlsx)...", systemImage: "doc.badge.plus")
                }
                if let parseError {
                    Text(parseError).foregroundColor(.red).font(.caption)
                }
                Text("Imports into \(selectedBlock.displayName) — pick the hostel's published mess-menu spreadsheet from Files/iCloud Drive. Read on this device; you'll see exactly what was parsed before anything is saved.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Section {
                Picker("Plan", selection: $selectedPlan) {
                    ForEach(MessPlan.allCases) { p in
                        Text(p.displayName).tag(p)
                    }
                }
                .pickerStyle(.segmented)

                Picker("Week", selection: $selectedCycle) {
                    ForEach(CycleWeek.allCases) { c in
                        Text(c.displayName).tag(c)
                    }
                }
                .pickerStyle(.segmented)

                Picker("Day", selection: $selectedDay) {
                    ForEach(Weekday.weekOrder) { day in
                        Text(day.shortName).tag(day)
                    }
                }
                .pickerStyle(.segmented)
            }

            ForEach(MealType.allCases) { meal in
                Section(meal.displayName) {
                    TextEditor(text: binding(for: meal))
                        .frame(minHeight: 80)
                    Text("One item per line").font(.caption2).foregroundColor(.secondary)
                }
            }

            if let error = menuStore.saveError {
                Section { Text(error).foregroundColor(.red).font(.caption) }
            }

            Section {
                Button {
                    Task {
                        isSaving = true
                        await menuStore.save(draft)
                        isSaving = false
                        if menuStore.saveError == nil { savedConfirmation = true }
                    }
                } label: {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Save \(selectedBlock.displayName) · \(selectedPlan.displayName) · \(selectedDay.displayName) · \(selectedCycle.displayName)")
                    }
                }
                .disabled(isSaving)
            }
        }
        .navigationTitle("Edit Menu")
        .onAppear {
            selectedBlock = adminAuth.allowedBlocks.first ?? .mh1
            loadDraft()
        }
        .onChange(of: selectedBlock) { _, _ in loadDraft() }
        .onChange(of: selectedPlan) { _, _ in loadDraft() }
        .onChange(of: selectedCycle) { _, _ in loadDraft() }
        .onChange(of: selectedDay) { _, _ in loadDraft() }
        .alert("Saved", isPresented: $savedConfirmation) {
            Button("OK", role: .cancel) {}
        }
        .fileImporter(isPresented: $showFilePicker, allowedContentTypes: [xlsxType]) { result in
            switch result {
            case .success(let url):
                do {
                    reviewPayload = try MessMenuXLSXParser.parse(fileURL: url, block: selectedBlock)
                    showReview = true
                } catch {
                    parseError = error.localizedDescription
                }
            case .failure(let error):
                parseError = error.localizedDescription
            }
        }
        .navigationDestination(isPresented: $showReview) {
            if let reviewPayload {
                ImportReviewView(menus: reviewPayload.menus, unresolved: reviewPayload.unresolved)
            }
        }
    }

    private func loadDraft() {
        draft = menuStore.menu(block: selectedBlock, plan: selectedPlan, weekday: selectedDay, cycleWeek: selectedCycle)
    }

    private func binding(for meal: MealType) -> Binding<String> {
        Binding(
            get: { draft.items(for: meal).joined(separator: "\n") },
            set: { newValue in
                let items = newValue
                    .components(separatedBy: .newlines)
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }
                draft.setItems(items, for: meal)
            }
        )
    }
}
