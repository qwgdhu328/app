import SwiftUI

struct ProfileView: View {
    @State private var showFeatures = false
    @State private var userName: String = UserDefaults.standard.string(forKey: "userName") ?? ""
    @State private var userGoal: String = UserDefaults.standard.string(forKey: "userGoal") ?? "Non impostato"

    var body: some View {
        NavigationStack {
            List {
                Section {
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
                    .listRowBackground(Color.clear)
                }

                Section("Statistiche") {
                    HStack(spacing: 12) {
                        statCard(value: "0", label: "Chat", icon: "message.fill")
                        statCard(value: "0", label: "Giorni", icon: "flame.fill")
                        statCard(value: "0", label: "Umore", icon: "face.smiling.fill")
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }

                Section {
                    Button {
                        showFeatures = true
                    } label: {
                        Label("Scopri le funzioni", systemImage: "sparkles.rectangle.stack")
                    }
                }

                Section("Info") {
                    LabeledContent("Versione", value: "2.0.0")
                    LabeledContent("AI Model", value: "OpenRouter")
                    LabeledContent("Piattaforma", value: "iOS nativo")
                }
            }
            .listStyle(.insetGrouped)
            .scrollBounceBehavior(.basedOnSize)
            .navigationTitle("Profilo")
            .sheet(isPresented: $showFeatures) {
                FeatureIntroView()
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
}

#Preview {
    ProfileView()
}
