import SwiftUI

struct CommunityView: View {
    var body: some View {
        NavigationStack {
            List {
                communityCard(title: "Gruppo di Supporto", subtitle: "Condividi le tue esperienze", icon: "person.3.fill", color: Theme.accent)
                communityCard(title: "Sfida Benessere", subtitle: "30 giorni di mindfulness", icon: "star.fill", color: .orange)
                communityCard(title: "Articoli", subtitle: "Leggi i nostri contenuti", icon: "doc.text.fill", color: .purple)
                communityCard(title: "Eventi", subtitle: "Workshop e incontri", icon: "calendar", color: Theme.breathing)
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            .background(AppBackground())
            .navigationTitle("Spazio")
        }
    }

    private func communityCard(title: String, subtitle: String, icon: String, color: Color) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.15))
                .clipShape(.circle)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Theme.text)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(Theme.muted)
        }
        .padding(4)
    }
}
