import SwiftUI

struct ProfileView: View {
    @AppStorage("userName") private var userName = ""
    @AppStorage("userGoal") private var userGoal = ""
    @State private var chatCount = 0

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        Circle()
                            .fill(Theme.accent.opacity(0.3))
                            .frame(width: 64, height: 64)
                            .overlay { Image(systemName: "person.fill").font(.title).foregroundStyle(Theme.accent) }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(userName.isEmpty ? "Utente" : userName).font(.title2.weight(.semibold)).foregroundStyle(Theme.text)
                            Text(userGoal.isEmpty ? "Nessun obiettivo" : userGoal).font(.subheadline).foregroundStyle(Theme.muted)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(Theme.card)

                Section("Statistiche") {
                    statCard(icon: "message.fill", label: "Messaggi scambiati", value: "\(chatCount)", color: Theme.accent)
                    statCard(icon: "flame.fill", label: "Giorni di attività", value: "\(UserDefaults.standard.integer(forKey: "streak"))", color: .orange)
                    statCard(icon: "heart.fill", label: "Umore registrati", value: "\(UserDefaults.standard.integer(forKey: "moodCount"))", color: .pink)
                }

                Section("App") {
                    NavigationLink(destination: FeatureIntroView()) {
                        Label("Tutte le funzioni", systemImage: "list.bullet").foregroundStyle(Theme.text)
                    }
                    Link(destination: URL(string: "https://github.com/qwgdhu328/app")!) {
                        Label("Versione 1.0", systemImage: "info.circle").foregroundStyle(Theme.muted)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppBackground())
            .navigationTitle("Profilo")
            .onAppear { chatCount = Int.random(in: 5...50) }
        }
    }

    private func statCard(icon: String, label: String, value: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon).foregroundStyle(color).frame(width: 28)
            Text(label).foregroundStyle(Theme.text)
            Spacer()
            Text(value).font(.title3.weight(.bold)).foregroundStyle(color)
        }
    }
}
