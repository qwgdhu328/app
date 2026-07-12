import SwiftUI

struct AppBackground: View {
    var body: some View {
        LinearGradient(colors: [Color(red: 0.08, green: 0.09, blue: 0.15), Color(red: 0.15, green: 0.12, blue: 0.25)], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
    }
}

struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Color(red: 0.15, green: 0.17, blue: 0.27))
            .clipShape(.rect(cornerRadius: 16))
    }
}

extension View {
    func cardBg() -> some View {
        modifier(CardBackground())
    }
}
