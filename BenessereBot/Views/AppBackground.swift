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
