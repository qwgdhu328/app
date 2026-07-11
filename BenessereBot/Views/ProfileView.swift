import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    profileHeader
                    settingsSection
                    aboutSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 80)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Tu")
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(.primary.opacity(0.3))
            Text("Il tuo benessere")
                .font(.title2.bold())
            Text("Personalizza la tua esperienza")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 20))
    }

    private var settingsSection: some View {
        VStack(spacing: 0) {
            settingRow(icon: "bell.fill", title: "Notifiche")
            Divider().padding(.leading, 52)
            settingRow(icon: "moon.fill", title: "Modalità scura")
            Divider().padding(.leading, 52)
            settingRow(icon: "globe", title: "Lingua")
        }
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 16))
    }

    private func settingRow(icon: String, title: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.primary)
                .frame(width: 28)
            Text(title)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(14)
    }

    private var aboutSection: some View {
        VStack(spacing: 0) {
            aboutRow(title: "Versione", value: "1.0.0")
            Divider().padding(.leading, 16)
            aboutRow(title: "Crediti", value: "SwiftUI + OpenRouter")
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
