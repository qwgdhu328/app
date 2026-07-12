import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView().tag(Tab.home)
                ChatView().tag(Tab.chat)
                WellbeingView().tag(Tab.wellbeing)
                ProfileView().tag(Tab.profile)
            }
            .tabViewStyle(.tabBarOnly)
            .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 64) }

            customTabBar
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
        }
        .ignoresSafeArea(.keyboard)
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                let isSelected = selectedTab == tab
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { selectedTab = tab }
                } label: {
                    VStack(spacing: 4) {
                        ZStack {
                            if isSelected {
                                Circle()
                                    .fill(Theme.accent.opacity(0.15))
                                    .frame(width: 40, height: 40)
                                    .transition(.scale.combined(with: .opacity))
                            }
                            Image(systemName: tab.icon)
                                .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                                .foregroundStyle(isSelected ? Theme.accent : Theme.muted)
                        }
                        Text(tab.rawValue)
                            .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                            .foregroundStyle(isSelected ? Theme.accent : Theme.muted)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(.ultraThinMaterial)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(Theme.cardBorder, lineWidth: 1))
        .shadow(color: .black.opacity(0.4), radius: 24, x: 0, y: 8)
    }
}
