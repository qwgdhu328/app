import SwiftUI

struct AppBackground: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [Theme.bgTop, Theme.bgMid, Theme.bgBottom], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            RadialGradient(colors: [Theme.accent.opacity(animate ? 0.15 : 0.05), .clear], center: .topLeading, startRadius: 0, endRadius: 400)
                .ignoresSafeArea()
            RadialGradient(colors: [Theme.accentTertiary.opacity(animate ? 0.10 : 0.03), .clear], center: .bottomTrailing, startRadius: 0, endRadius: 500)
                .ignoresSafeArea()
        }
        .onAppear { withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) { animate.toggle() } }
    }
}

struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Theme.text)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Theme.surface)
            .background(Theme.glassGradient)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Theme.cardBorder, lineWidth: 1))
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
