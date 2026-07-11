import SwiftUI

struct ProfileView: View {
    @State private var showFeatures = false
    @State private var userName: String = UserDefaults.standard.string(forKey: "userName") ?? ""
    @State private var userGoal: String = UserDefaults.standard.string(forKey: "userGoal") ?? "Non impostato"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    profileHeader
                    statsSection
                    settingsSection
                    aboutSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 80)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Profilo")
            .sheet(isPresented: $showFeatures) {
                FeatureIntroView()
            }
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(.tint.opacity(0.4))

            Text(userName.isEmpty ? "Il tuo profilo" : userName)
                .font(.title2.bold())

            Text("Obiettivo: \(userGoal)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 20))
    }

    private var statsSection: some View {
        VStack(spacing: 12) {
            Text("Statistiche")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                statCard(value: "0", label: "Chat", icon: "message.fill")
                statCard(value: "0", label: "Giorni", icon: "flame.fill")
                statCard(value: "0", label: "Umore", icon: "face.smiling.fill")
            }
        }
    }

    private func statCard(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.tint)
            Text(value)
                .font(.title2.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 16))
    }

    private var settingsSection: some View {
        VStack(spacing: 0) {
            Button {
                showFeatures = true
            } label: {
                HStack {
                    Image(systemName: "sparkles.rectangle.stack")
                        .foregroundStyle(.tint)
                        .frame(width: 28)
                    Text("Scopri le funzioni")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(14)
                .foregroundStyle(.primary)
            }
        }
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 16))
    }

    private var aboutSection: some View {
        VStack(spacing: 0) {
            aboutRow(title: "Versione", value: "2.0.0")
            Divider().padding(.leading, 16)
            aboutRow(title: "AI Model", value: "OpenRouter GPT-4o")
            Divider().padding(.leading, 16)
            aboutRow(title: "Piattaforma", value: "iOS nativo")
        }
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 16))
    }

    private func aboutRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .foregroundStyle(.primary)
        }
        .padding(14)
    }
}

#Preview {
    ProfileView()
}
