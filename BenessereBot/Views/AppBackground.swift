import SwiftUI

struct AppBackground: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [Theme.bgTop, Theme.bgMid, Theme.bgBottom], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            RadialGradient(colors: [Theme.glow1.opacity(animate ? 0.2 : 0.05), .clear], center: .topLeading, startRadius: 0, endRadius: 350)
                .ignoresSafeArea()
            RadialGradient(colors: [Theme.glow2.opacity(animate ? 0.15 : 0.03), .clear], center: .center, startRadius: 0, endRadius: 400)
                .ignoresSafeArea()
            RadialGradient(colors: [Theme.glow3.opacity(animate ? 0.12 : 0.03), .clear], center: .bottomTrailing, startRadius: 0, endRadius: 450)
                .ignoresSafeArea()
        }
        .onAppear { withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) { animate.toggle() } }
    }
}
