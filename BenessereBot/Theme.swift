import SwiftUI

let AppTint = Color(red: 0.3, green: 0.65, blue: 0.85)

struct AppColors {
    static let accent = LinearGradient(colors: [Color(red: 0.3, green: 0.65, blue: 0.85), Color(red: 0.6, green: 0.3, blue: 0.85)], startPoint: .leading, endPoint: .trailing)
    static let backgroundStart = Color(red: 0.08, green: 0.09, blue: 0.15)
    static let backgroundEnd = Color(red: 0.12, green: 0.14, blue: 0.22)
    static let cardBg = Color(red: 0.15, green: 0.17, blue: 0.27)
    static let cardBgLight = Color(red: 0.85, green: 0.87, blue: 0.93)
    static let textPrimary = Color(red: 0.95, green: 0.95, blue: 0.98)
    static let textSecondary = Color(red: 0.65, green: 0.68, blue: 0.78)
    static let breathingAccent = Color(red: 0.5, green: 0.8, blue: 0.7)
    static let moodColors: [Color] = [
        Color(red: 1.0, green: 0.6, blue: 0.6),
        Color(red: 1.0, green: 0.75, blue: 0.5),
        Color(red: 1.0, green: 0.9, blue: 0.5),
        Color(red: 0.6, green: 0.9, blue: 0.6),
        Color(red: 0.5, green: 0.75, blue: 1.0),
        Color(red: 0.7, green: 0.5, blue: 1.0),
    ]
}

extension Color {
    static let appBg = AppColors.backgroundStart
    static let appCard = AppColors.cardBg
    static let appText = AppColors.textPrimary
    static let appMuted = AppColors.textSecondary
}
