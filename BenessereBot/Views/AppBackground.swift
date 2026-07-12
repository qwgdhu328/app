import SwiftUI

struct AppBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(.systemBackground),
                AppTint.opacity(0.06),
                Color(.systemBackground).opacity(0.9)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 16))
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardBackground())
    }
}
