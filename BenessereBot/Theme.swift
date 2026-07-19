import SwiftUI

enum Theme {
    static let accent = Color(red: 0.94, green: 0.66, blue: 0.60)
    static let accentSecondary = Color(red: 0.72, green: 0.66, blue: 0.79)
    static let accentTertiary = Color(red: 0.56, green: 0.66, blue: 0.56)
    static let gold = Color(red: 0.91, green: 0.79, blue: 0.54)

    static let bgTop = Color(red: 0.10, green: 0.10, blue: 0.10)
    static let bgMid = Color(red: 0.13, green: 0.11, blue: 0.14)
    static let bgBottom = Color(red: 0.16, green: 0.12, blue: 0.17)

    static let card = Color(red: 0.18, green: 0.16, blue: 0.17).opacity(0.70)
    static let cardBorder = Color(red: 0.50, green: 0.45, blue: 0.45).opacity(0.15)
    static let cardHighlight = Color(red: 0.94, green: 0.66, blue: 0.60).opacity(0.20)

    static let text = Color(red: 0.96, green: 0.93, blue: 0.88)
    static let textSecondary = Color(red: 0.78, green: 0.74, blue: 0.70)
    static let muted = Color(red: 0.56, green: 0.54, blue: 0.52)

    static let surface = Color(red: 0.16, green: 0.15, blue: 0.16).opacity(0.75)

    static let moods: [Color] = [
        Color(red: 0.95, green: 0.35, blue: 0.35),
        Color(red: 0.90, green: 0.55, blue: 0.30),
        Color(red: 0.88, green: 0.75, blue: 0.35),
        Color(red: 0.35, green: 0.80, blue: 0.50),
        Color(red: 0.40, green: 0.55, blue: 0.90),
        Color(red: 0.75, green: 0.50, blue: 0.90),
    ]

    static let gradientAccent = LinearGradient(colors: [accent, gold], startPoint: .leading, endPoint: .trailing)
    static let gradientCard = LinearGradient(colors: [accent.opacity(0.08), accentTertiary.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
}
