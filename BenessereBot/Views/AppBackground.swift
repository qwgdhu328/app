import SwiftUI

struct AppBackground: View {
    var body: some View {
        LinearGradient(colors: [Theme.bgTop, Theme.bgBottom], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
    }
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.padding(16).background(Theme.card).clipShape(.rect(cornerRadius: 16))
    }
}

extension View {
    func card() -> some View { modifier(CardStyle()) }
}
