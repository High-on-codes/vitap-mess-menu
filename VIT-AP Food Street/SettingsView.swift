//
//  SettingsView.swift
//  VIT-AP Mess Menu
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var adminAuth: AdminAuthManager
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("messPlan", store: WidgetSharedStore.sharedDefaults) private var messPlanRaw = MessPlan.regular.rawValue
    @AppStorage("myHostelBlock", store: WidgetSharedStore.sharedDefaults) private var myBlockRaw = HostelBlock.mh1.rawValue
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    private var plan: Binding<MessPlan> {
        Binding(
            get: { MessPlan(rawValue: messPlanRaw) ?? .regular },
            set: { messPlanRaw = $0.rawValue }
        )
    }

    private var myBlock: Binding<HostelBlock> {
        Binding(
            get: { HostelBlock(rawValue: myBlockRaw) ?? .mh1 },
            set: { myBlockRaw = $0.rawValue }
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Your Hostel") {
                    Picker("Block", selection: myBlock) {
                        Section("Men's Hostel") {
                            ForEach(HostelBlock.mensHostels) { b in
                                Text(b.displayName).tag(b)
                            }
                        }
                        Section("Ladies Hostel") {
                            ForEach(HostelBlock.ladiesHostels) { b in
                                Text(b.displayName).tag(b)
                            }
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Your Mess Plan") {
                    Picker("Plan", selection: plan) {
                        ForEach(MessPlan.allCases) { p in
                            Text(p.displayName).tag(p)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Reminders") {
                    Toggle("Meal reminders", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { _, isOn in
                            if isOn {
                                NotificationManager.requestAuthorizationAndSchedule()
                            } else {
                                NotificationManager.disable()
                            }
                        }
                }

                Section("Admin") {
                    if adminAuth.hasAccess {
                        NavigationLink("Edit Menu") { AdminEditView() }
                        Text(adminAuth.isSuperAdmin ? "Signed in as super admin" : "Operator for \(adminAuth.allowedBlocks.first?.displayName ?? "")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Button("Sign Out", role: .destructive) { adminAuth.signOut() }
                    } else {
                        NavigationLink("Admin Sign In") { AdminLoginView() }
                    }
                }

                Section {
                    Button("Show Welcome Tour") { hasSeenOnboarding = false }
                }

                Section("About") {
                    Link(destination: URL(string: "https://high-on-codes.github.io/VIT-APmenu/support.html")!) {
                        Label("Support", systemImage: "questionmark.circle")
                    }
                    Link(destination: URL(string: "https://high-on-codes.github.io/VIT-APmenu/privacy.html")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                }

                Section {
                    Text("VIT-AP Mess Menu shows the weekly breakfast, lunch, snacks and dinner spread for both the Regular and Special mess plans. Menu is maintained by the admin and updates for everyone automatically.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
