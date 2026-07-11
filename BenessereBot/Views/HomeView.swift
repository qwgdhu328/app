import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    moodSection
                    quickActionsSection
                    tipSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 80)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("BenessereBot")
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Ciao! 👋")
                .font(.title.bold())
            Text("Come stai oggi?")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var moodSection: some View {
        VStack(spacing: 12) {
            Text("Come ti senti?")
                .font(.headline)
            HStack(spacing: 16) {
                ForEach(["😊", "😐", "😢", "😡", "😴"], id: \.self) { emoji in
                    Button(emoji) {}
                        .font(.largeTitle)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(.circle)
                }
            }
        }
        .padding(20)
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 20))
    }

    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            Text("Azioni rapide")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                quickActionCard(icon: "brain.head.profile", title: "Mindfulness", color: .blue)
                quickActionCard(icon: "figure.walk", title: "Passeggiata", color: .green)
                quickActionCard(icon: "book.closed", title: "Diario", color: .orange)
                quickActionCard(icon: "music.note", title: "Musica", color: .purple)
            }
        }
    }

    private func quickActionCard(icon: String, title: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(title)
                .font(.callout.weight(.medium))
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 16))
    }

    private var tipSection: some View {
        HStack {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(.yellow)
            Text("Respirare profondamente per 5 secondi aiuta a ridurre lo stress.")
                .font(.subheadline)
        }
        .padding(16)
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 16))
    }
}

#Preview {
    HomeView()
}
