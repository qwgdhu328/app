import SwiftUI

struct CommunityView: View {
    var body: some View {
        NavigationStack {
            List {
                communityCard(
                    title: "Gruppo di Supporto",
                    subtitle: "Condividi le tue esperienze",
                    icon: "person.3.fill",
                    color: .blue
                )
                communityCard(
                    title: "Sfida Benessere",
                    subtitle: "30 giorni di mindfulness",
                    icon: "star.fill",
                    color: .orange
                )
                communityCard(
                    title: "Articoli",
                    subtitle: "Leggi i nostri contenuti",
                    icon: "doc.text.fill",
                    color: .purple
                )
                communityCard(
                    title: "Eventi",
                    subtitle: "Workshop e incontri",
                    icon: "calendar",
                    color: .green
                )
            }
            .listStyle(.insetGrouped)
            .scrollBounceBehavior(.basedOnSize)
            .navigationTitle("Spazio")
        }
    }

    private func communityCard(title: String, subtitle: String, icon: String, color: Color) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.12))
                .clipShape(.circle)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding(4)
    }
}

#Preview {
    CommunityView()
}
