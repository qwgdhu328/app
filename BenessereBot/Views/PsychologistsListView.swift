import SwiftUI

struct PsychologistsListView: View {
    let city: String
    @Environment(\.dismiss) var dismiss

    private var filtered: [Psychologist] {
        samplePsychologists.filter { $0.city.localizedCaseInsensitiveContains(city) }
    }

    var body: some View {
        NavigationStack {
            List(filtered.isEmpty ? samplePsychologists : filtered) { psychologist in
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        Image(systemName: psychologist.imageSystemName)
                            .font(.title)
                            .foregroundStyle(AppTint)
                            .frame(width: 44, height: 44)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(psychologist.name)
                                .font(.headline)
                            Text(psychologist.specialty)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Label(psychologist.city, systemImage: "mappin.circle.fill")
                                .font(.caption2)
                                .foregroundStyle(.blue)
                        }
                    }

                    Text(psychologist.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 16) {
                        Button {
                            let tel = psychologist.phone.replacingOccurrences(of: " ", with: "")
                            if let url = URL(string: "tel://\(tel)") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Label("Chiama", systemImage: "phone.fill")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .tint(.green)

                        Button {
                            if let url = URL(string: "mailto:\(psychologist.email)") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Label("Email", systemImage: "envelope.fill")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                    }
                }
                .padding(.vertical, 4)
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(AppBackground())
            .navigationTitle("Psicologi a \(city)")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Chiudi") { dismiss() }
                }
            }
        }
    }
}
