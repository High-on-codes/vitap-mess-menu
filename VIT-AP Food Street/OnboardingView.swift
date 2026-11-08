//
//  OnboardingView.swift
//  VIT-AP Mess Menu
//
//  First-launch welcome tour: what the app does, how the Week A/B cycle
//  works, and who it's for right now. Shown once (AppConfig-backed
//  `hasSeenOnboarding` flag) and re-watchable from Settings.
//
//  The "fluid" feel is a few small reactive touches rather than one big
//  trick: each page's icon scales/fades based on distance from the current
//  page (so it visibly settles into focus as you swipe, like a carousel),
//  the background tints toward that page's color, the dash-style page
//  indicator springs between widths, and the button label crossfades
//  instead of jump-cutting when it changes text.
//

import SwiftUI

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
}

private let onboardingPages: [OnboardingPage] = [
    OnboardingPage(
        icon: "fork.knife.circle.fill",
        color: Theme.Accent.orange,
        title: "Welcome to VIT AP Menu",
        subtitle: "No more asking around the hostel — see exactly what the mess is serving, right when you open the app."
    ),
    OnboardingPage(
        icon: "sun.max.fill",
        color: Theme.Accent.amber,
        title: "Today, At a Glance",
        subtitle: "Whatever meal is happening now — or coming up next — is front and center. Breakfast, lunch, snacks, dinner, all in one place."
    ),
    OnboardingPage(
        icon: "calendar.badge.clock",
        color: Theme.Accent.blue,
        title: "Built Around VIT-AP's Cycle",
        subtitle: "The mess menu alternates every other week — Week A, Week B. The app figures out which one applies today automatically, no guessing."
    ),
    OnboardingPage(
        icon: "graduationcap.fill",
        color: Theme.Accent.green,
        title: "Made for Freshers — For Now",
        subtitle: "This first version is built to help incoming freshers find their footing at VIT-AP. It's just the start — more is on the way."
    ),
]

struct OnboardingView: View {
    var onFinish: () -> Void

    @State private var currentPage = 0

    private var isLastPage: Bool { currentPage == onboardingPages.count - 1 }

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: currentPage)

            VStack(spacing: 0) {
                skipBar

                TabView(selection: $currentPage) {
                    ForEach(Array(onboardingPages.enumerated()), id: \.element.id) { index, page in
                        pageView(page, index: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5, dampingFraction: 0.85), value: currentPage)

                pageIndicator
                    .padding(.bottom, 20)

                continueButton
                    .padding(.horizontal, 32)
                    .padding(.bottom, 24)
            }
            .frame(maxWidth: 480)
        }
    }

    private var backgroundGradient: some View {
        let color = onboardingPages[currentPage].color
        return LinearGradient(
            colors: [Color(uiColor: .systemBackground), color.opacity(0.14)],
            startPoint: .top, endPoint: .bottom
        )
    }

    private var skipBar: some View {
        HStack {
            Spacer()
            if !isLastPage {
                Button("Skip") { finish() }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .frame(height: 44)
    }

    private func pageView(_ page: OnboardingPage, index: Int) -> some View {
        let distance = Double(index - currentPage)
        let isActive = index == currentPage

        return VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Theme.gradient(page.color))
                    .frame(width: 120, height: 120)
                    .shadow(color: page.color.opacity(0.35), radius: 20, y: 10)
                Image(systemName: page.icon)
                    .font(.system(size: 52, weight: .semibold))
                    .foregroundColor(.white)
                    .symbolEffect(.bounce, value: isActive)
            }
            .scaleEffect(isActive ? 1 : 0.72)
            .opacity(isActive ? 1 : 0.35)
            .rotation3DEffect(.degrees(distance * 25), axis: (x: 0, y: 1, z: 0))

            VStack(spacing: 12) {
                Text(page.title)
                    .font(.system(size: 26, weight: .bold))
                    .multilineTextAlignment(.center)
                Text(page.subtitle)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
            }
            .opacity(isActive ? 1 : 0)
            .offset(y: isActive ? 0 : 12)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(onboardingPages.indices, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? onboardingPages[currentPage].color : Color.secondary.opacity(0.25))
                    .frame(width: index == currentPage ? 22 : 8, height: 8)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentPage)
    }

    private var continueButton: some View {
        Button {
            if isLastPage {
                finish()
            } else {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                    currentPage += 1
                }
            }
        } label: {
            Text(isLastPage ? "Let's Eat" : "Continue")
                .contentTransition(.opacity)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Theme.gradient(onboardingPages[currentPage].color))
                .clipShape(Capsule())
                .animation(.easeInOut(duration: 0.3), value: currentPage)
        }
        .pressable(scale: 0.97)
    }

    private func finish() {
        withAnimation {
            onFinish()
        }
    }
}
