import SwiftUI

struct CommunityView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
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
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 80)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Spazio")
        }
    }

    private func communityCard(title: String, subtitle: String, icon: String, color: Color) -> some View {
        HStack(spacing: 16) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: 44, height: 44)
                    .background(color.opacity(0.12))
                    .clipShape(.circle)

                Text("PROSSIMAMENTE")
                    .font(.system(size: 7, weight: .black))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(color)
                    .clipShape(.capsule)
                    .offset(x: 4, y: -4)
            }

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
        .padding(16)
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 16))
        .opacity(0.85)
    }
}

#Preview {
    CommunityView()
}
