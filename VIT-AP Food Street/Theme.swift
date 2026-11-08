//
//  Theme.swift
//  VIT-AP Mess Menu
//
//  Small shared design system so screens read as one product: a warm
//  gradient, a consistent card style, and simple motion helpers.
//

import SwiftUI

enum Theme {
    static let accent = Color("TerracottaAccent")

    static let pageBackground = LinearGradient(
        colors: [Color(uiColor: .systemGroupedBackground), Color("TerracottaAccent").opacity(0.06)],
        startPoint: .top, endPoint: .bottom
    )

    static let heroGradient = LinearGradient(
        colors: [Color("TerracottaAccent"), Color(red: 0.94, green: 0.55, blue: 0.30)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    enum Accent {
        static let orange = Color(red: 0.93, green: 0.45, blue: 0.22)
        static let green = Color(red: 0.18, green: 0.60, blue: 0.42)
        static let blue = Color(red: 0.20, green: 0.45, blue: 0.78)
        static let purple = Color(red: 0.53, green: 0.30, blue: 0.72)
        static let amber = Color(red: 0.95, green: 0.68, blue: 0.15)
    }

    static func gradient(_ color: Color) -> LinearGradient {
        LinearGradient(colors: [color, color.opacity(0.72)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static func color(forMeal meal: MealType) -> Color {
        switch meal {
        case .breakfast: return Accent.amber
        case .lunch: return Accent.orange
        case .snacks: return Accent.purple
        case .dinner: return Accent.blue
        }
    }

    /// Best-effort emoji for a dish name, just for a bit of visual texture
    /// in the item lists.
    static func emoji(forDish name: String) -> String {
        let n = name.lowercased()
        let keywords: [(String, String)] = [
            ("idli", "🍚"), ("dosa", "🥞"), ("uttapam", "🥞"), ("pesarattu", "🥞"),
            ("chai", "☕️"), ("tea", "☕️"), ("coffee", "☕️"),
            ("juice", "🧃"), ("lassi", "🥛"), ("milk", "🥛"),
            ("rice", "🍚"), ("biryani", "🍛"), ("curry", "🍲"), ("dal", "🍲"), ("sambar", "🍲"),
            ("noodle", "🍜"), ("maggi", "🍜"), ("pasta", "🍝"),
            ("chapati", "🫓"), ("roti", "🫓"), ("naan", "🫓"), ("paratha", "🫓"), ("bread", "🍞"),
            ("samosa", "🥟"), ("momo", "🥟"),
            ("burger", "🍔"), ("sandwich", "🥪"), ("fries", "🍟"), ("pizza", "🍕"),
            ("egg", "🥚"), ("omelette", "🥚"), ("chicken", "🍗"), ("mutton", "🍖"), ("fish", "🐟"),
            ("paneer", "🧀"), ("curd", "🥣"), ("salad", "🥗"),
            ("ice cream", "🍨"), ("sweet", "🍬"), ("cake", "🍰"), ("fruit", "🍎"),
        ]
        for (key, emoji) in keywords where n.contains(key) {
            return emoji
        }
        return "🍽️"
    }
}

// MARK: - Motion

extension Animation {
    static var pop: Animation { .spring(response: 0.34, dampingFraction: 0.68) }
    static var soft: Animation { .spring(response: 0.45, dampingFraction: 0.85) }
}

struct PressableStyle: ButtonStyle {
    var scale: CGFloat = 0.96
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(.pop, value: configuration.isPressed)
    }
}

extension View {
    func pressable(scale: CGFloat = 0.96) -> some View {
        buttonStyle(PressableStyle(scale: scale))
    }

    func appears(after delay: Double = 0) -> some View {
        modifier(AppearAnimation(delay: delay))
    }
}

struct AppearAnimation: ViewModifier {
    let delay: Double
    @State private var shown = false

    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .offset(y: shown ? 0 : 14)
            .onAppear {
                withAnimation(.soft.delay(delay)) { shown = true }
            }
    }
}

struct CardBackground: ViewModifier {
    var padding: CGFloat = 16
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

extension View {
    func cardStyle(padding: CGFloat = 16) -> some View {
        modifier(CardBackground(padding: padding))
    }
}

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.system(size: 15, weight: .bold))
            if let subtitle {
                Text(subtitle).font(.caption).foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Wrapping chip layout

/// Lays out its children left-to-right, wrapping to a new line when a child
/// would overflow the available width — used to lay food items out as
/// wrapping bubbles instead of one truncated line of comma-separated text.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var maxRowWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0, x + size.width > maxWidth {
                totalHeight += rowHeight + lineSpacing
                maxRowWidth = max(maxRowWidth, x - spacing)
                x = 0
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        totalHeight += rowHeight
        maxRowWidth = max(maxRowWidth, x - spacing)
        return CGSize(width: maxWidth.isFinite ? maxWidth : maxRowWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > bounds.minX, x + size.width > bounds.minX + bounds.width {
                x = bounds.minX
                y += rowHeight + lineSpacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

/// A single food item shown as a clean, high-contrast bubble. Uses `.primary`
/// for the label (not `.secondary`) so it stays legible in both light and
/// dark mode — only the tint behind it varies by meal.
struct FoodChip: View {
    let text: String
    var color: Color
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            Text(Theme.emoji(forDish: text))
                .font(compact ? .caption : .body)
            Text(text)
                .font(compact ? .caption.weight(.semibold) : .subheadline.weight(.semibold))
                .foregroundColor(.primary)
                .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, compact ? 10 : 14)
        .padding(.vertical, compact ? 7 : 10)
        .background(color.opacity(0.20))
        .overlay(Capsule().stroke(color.opacity(0.35), lineWidth: 1))
        .clipShape(Capsule())
    }
}

struct FoodChipGroup: View {
    let items: [String]
    var color: Color
    var compact: Bool = false

    var body: some View {
        FlowLayout(spacing: compact ? 6 : 8, lineSpacing: compact ? 6 : 8) {
            ForEach(items, id: \.self) { item in
                FoodChip(text: item, color: color, compact: compact)
            }
        }
    }
}
