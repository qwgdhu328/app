import SwiftUI

struct PsychologistsListView: View {
    let psychologists = samplePsychologists
    @State private var searchCity = ""

    var filtered: [Psychologist] {
        guard !searchCity.isEmpty else { return psychologists }
        return psychologists.filter { $0.city.lowercased().contains(searchCity.lowercased()) }
    }

    var body: some View {
        NavigationStack {
            List(filtered) { p in
                VStack(alignment: .leading, spacing: 4) {
                    Text(p.name).font(.headline).foregroundStyle(Theme.text)
                    Text(p.specialty).font(.subheadline).foregroundStyle(Theme.muted)
                    Text(p.city).font(.caption).foregroundStyle(Theme.accent)
                    HStack(spacing: 16) {
                        Link("Chiama", destination: URL(string: "tel:\(p.phone)")!)
                            .font(.callout)
                        Link("Email", destination: URL(string: "mailto:\(p.email)")!)
                            .font(.callout)
                    }
                    .padding(.top, 4)
                }
                .padding(.vertical, 4)
            }
            .searchable(text: $searchCity, prompt: "Cerca per città")
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(AppBackground())
            .navigationTitle("Psicologi")
        }
    }
}
