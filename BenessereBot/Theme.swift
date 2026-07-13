import SwiftUI

enum Theme {
    static let accent = Color(red: 0.0, green: 0.95, blue: 0.85)
    static let accentSecondary = Color(red: 1.0, green: 0.75, blue: 0.15)
    static let accentTertiary = Color(red: 0.8, green: 0.35, blue: 1.0)
    static let breathing = Color(red: 0.0, green: 0.95, blue: 0.85)
    static let bgTop = Color(red: 0.02, green: 0.01, blue: 0.08)
    static let bgMid = Color(red: 0.06, green: 0.03, blue: 0.18)
    static let bgBottom = Color(red: 0.12, green: 0.02, blue: 0.25)
    static let card = Color(red: 0.10, green: 0.10, blue: 0.22).opacity(0.5)
    static let cardBorder = Color(red: 0.3, green: 0.5, blue: 0.9).opacity(0.25)
    static let cardBorderHighlight = Color(red: 0.0, green: 0.95, blue: 0.85).opacity(0.4)
    static let text = Color(red: 1.0, green: 1.0, blue: 1.0)
    static let textSecondary = Color(red: 0.85, green: 0.88, blue: 0.95)
    static let muted = Color(red: 0.55, green: 0.58, blue: 0.72)
    static let surface = Color(red: 0.06, green: 0.06, blue: 0.18).opacity(0.7)
    static let glow1 = Color(red: 0.0, green: 0.95, blue: 0.85)
    static let glow2 = Color(red: 1.0, green: 0.4, blue: 0.6)
    static let glow3 = Color(red: 0.6, green: 0.3, blue: 1.0)
    static let moods: [Color] = [
        Color(red: 1.0, green: 0.3, blue: 0.3),
        Color(red: 1.0, green: 0.6, blue: 0.2),
        Color(red: 1.0, green: 0.9, blue: 0.2),
        Color(red: 0.2, green: 0.95, blue: 0.4),
        Color(red: 0.2, green: 0.6, blue: 1.0),
        Color(red: 0.7, green: 0.3, blue: 1.0),
    ]
}
