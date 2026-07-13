import SwiftUI

enum Theme {
    static let accent = Color(red: 0.0, green: 0.75, blue: 0.70)
    static let accentSecondary = Color(red: 0.90, green: 0.60, blue: 0.20)
    static let accentTertiary = Color(red: 0.55, green: 0.35, blue: 0.90)
    static let breathing = Color(red: 0.0, green: 0.75, blue: 0.70)
    static let bgTop = Color(red: 0.08, green: 0.08, blue: 0.15)
    static let bgMid = Color(red: 0.12, green: 0.10, blue: 0.22)
    static let bgBottom = Color(red: 0.16, green: 0.12, blue: 0.28)
    static let card = Color(red: 0.18, green: 0.18, blue: 0.30).opacity(0.55)
    static let cardBorder = Color(red: 0.30, green: 0.30, blue: 0.50).opacity(0.20)
    static let cardBorderHighlight = Color(red: 0.0, green: 0.75, blue: 0.70).opacity(0.30)
    static let text = Color(red: 1.0, green: 1.0, blue: 1.0)
    static let textSecondary = Color(red: 0.82, green: 0.84, blue: 0.92)
    static let muted = Color(red: 0.60, green: 0.62, blue: 0.75)
    static let surface = Color(red: 0.12, green: 0.12, blue: 0.24).opacity(0.70)
    static let moods: [Color] = [
        Color(red: 0.95, green: 0.35, blue: 0.35),
        Color(red: 0.90, green: 0.60, blue: 0.25),
        Color(red: 0.90, green: 0.80, blue: 0.25),
        Color(red: 0.25, green: 0.85, blue: 0.45),
        Color(red: 0.25, green: 0.55, blue: 0.95),
        Color(red: 0.65, green: 0.35, blue: 0.95),
    ]
}
