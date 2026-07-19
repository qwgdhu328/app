import SwiftUI

struct PsychologistsListView: View {
    let city: String
    @Environment(\.dismiss) var dismiss

    private var filtered: [Psychologist] {
        samplePsychologists.filter { $0.city.localizedCaseInsensitiveContains(city) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                if filtered.isEmpty {
                    ContentUnavailableView("Nessun psicologo a \(city)", systemImage: "person.2.slash",
                        description: Text("Ecco tutti i professionisti disponibili"))
                        .foregroundStyle(Theme.muted)
                }
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(filtered.isEmpty ? samplePsychologists : filtered) { psychologist in
                            psychologistCard(psychologist)
                        }
                    }
                    .padding()
                }
                .scrollBounceBehavior(.basedOnSize)
            }
            .navigationTitle("Psicologi a \(city)")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Chiudi") { dismiss() }
                }
            }
        }
    }

    private func psychologistCard(_ p: Psychologist) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(Theme.accent.opacity(0.1)).frame(width: 48, height: 48)
                    Image(systemName: p.imageSystemName)
                        .font(.title2).foregroundStyle(Theme.accent)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(p.name).font(.headline).foregroundStyle(Theme.text)
                    Text(p.specialty).font(.caption).foregroundStyle(Theme.muted)
                    Label(p.city, systemImage: "mappin.circle.fill")
                        .font(.caption2).foregroundStyle(Theme.accent)
                }
            }
            Text(p.description).font(.subheadline).foregroundStyle(Theme.textSecondary)
            HStack(spacing: 12) {
                Button {
                    let tel = p.phone.replacingOccurrences(of: " ", with: "")
                    if let url = URL(string: "tel://\(tel)") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("Chiama", systemImage: "phone.fill").font(.caption)
                        .padding(.horizontal, 14).padding(.vertical, 6)
                        .background(Theme.accent.opacity(0.12))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Theme.accent.opacity(0.3), lineWidth: 1))
                }
                Button {
                    if let url = URL(string: "mailto:\(p.email)") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("Email", systemImage: "envelope.fill").font(.caption)
                        .padding(.horizontal, 14).padding(.vertical, 6)
                        .background(Theme.accent.opacity(0.12))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Theme.accent.opacity(0.3), lineWidth: 1))
                }
            }
        }
        .padding(16)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.cardBorder, lineWidth: 1))
    }
}
