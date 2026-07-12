import SwiftUI

enum Theme {
    static let accent = Color(red: 0.18, green: 0.78, blue: 0.73)
    static let accentSecondary = Color(red: 1.0, green: 0.65, blue: 0.25)
    static let accentTertiary = Color(red: 0.65, green: 0.45, blue: 1.0)
    static let breathing = Color(red: 0.18, green: 0.78, blue: 0.73)
    static let bgTop = Color(red: 0.04, green: 0.04, blue: 0.10)
    static let bgMid = Color(red: 0.08, green: 0.07, blue: 0.18)
    static let bgBottom = Color(red: 0.12, green: 0.06, blue: 0.22)
    static let card = Color(red: 0.12, green: 0.14, blue: 0.24).opacity(0.6)
    static let cardBorder = Color(red: 0.25, green: 0.30, blue: 0.50).opacity(0.2)
    static let cardBorderHighlight = Color(red: 0.18, green: 0.78, blue: 0.73).opacity(0.3)
    static let text = Color(red: 0.96, green: 0.96, blue: 0.98)
    static let textSecondary = Color(red: 0.75, green: 0.78, blue: 0.88)
    static let muted = Color(red: 0.50, green: 0.54, blue: 0.65)
    static let surface = Color(red: 0.08, green: 0.10, blue: 0.20).opacity(0.8)
    static let moods: [Color] = [
        Color(red: 1.0, green: 0.5, blue: 0.5),
        Color(red: 1.0, green: 0.7, blue: 0.4),
        Color(red: 1.0, green: 0.85, blue: 0.4),
        Color(red: 0.5, green: 0.9, blue: 0.5),
        Color(red: 0.4, green: 0.7, blue: 1.0),
        Color(red: 0.65, green: 0.45, blue: 1.0),
    ]
    static let glassGradient = LinearGradient(colors: [.white.opacity(0.08), .white.opacity(0.02)], startPoint: .topLeading, endPoint: .bottomTrailing)
    static let glowGradient = LinearGradient(colors: [accent.opacity(0.3), accentTertiary.opacity(0.1)], startPoint: .top, endPoint: .bottom)
}

struct GlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Theme.surface)
            .background(Theme.glassGradient)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.cardBorder, lineWidth: 1))
            .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 4)
    }
}

extension View {
    func glass() -> some View { modifier(GlassCard()) }
    func glassCard<C: View>(@ViewBuilder content: () -> C) -> some View {
        content().glass()
    }
}
