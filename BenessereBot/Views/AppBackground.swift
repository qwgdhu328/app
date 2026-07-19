import SwiftUI

struct AppBackground: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [Theme.bgTop, Theme.bgMid, Theme.bgBottom], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            RadialGradient(colors: [Theme.accent.opacity(animate ? 0.10 : 0.03), .clear], center: .topTrailing, startRadius: 0, endRadius: 500)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: animate)

            RadialGradient(colors: [Theme.accentSecondary.opacity(animate ? 0.06 : 0.02), .clear], center: .bottomLeading, startRadius: 0, endRadius: 600)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 7).repeatForever(autoreverses: true).delay(1), value: animate)

            RadialGradient(colors: [Theme.gold.opacity(animate ? 0.04 : 0.01), .clear], center: .center, startRadius: 0, endRadius: 400)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true).delay(2), value: animate)
        }
        .onAppear { animate = true }
    }
}
