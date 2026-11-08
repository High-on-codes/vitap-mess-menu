//
//  ContentView.swift
//  VIT-AP Mess Menu
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("Today", systemImage: "fork.knife") }
            WeekView()
                .tabItem { Label("Week", systemImage: "calendar") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .fullScreenCover(isPresented: Binding(
            get: { !hasSeenOnboarding },
            set: { isPresented in hasSeenOnboarding = !isPresented }
        )) {
            OnboardingView { hasSeenOnboarding = true }
        }
    }
}
