import SwiftUI

enum Theme {
    static let accent = Color(red: 0.3, green: 0.65, blue: 0.85)
    static let breathing = Color(red: 0.4, green: 0.8, blue: 0.7)
    static let bgTop = Color(red: 0.08, green: 0.09, blue: 0.15)
    static let bgBottom = Color(red: 0.15, green: 0.12, blue: 0.25)
    static let card = Color(red: 0.15, green: 0.17, blue: 0.27)
    static let text = Color(red: 0.95, green: 0.95, blue: 0.98)
    static let muted = Color(red: 0.6, green: 0.63, blue: 0.73)
    static let moods: [Color] = [
        Color(red: 1.0, green: 0.5, blue: 0.5),
        Color(red: 1.0, green: 0.7, blue: 0.4),
        Color(red: 1.0, green: 0.85, blue: 0.4),
        Color(red: 0.5, green: 0.9, blue: 0.5),
        Color(red: 0.4, green: 0.7, blue: 1.0),
        Color(red: 0.65, green: 0.45, blue: 1.0),
    ]
}
