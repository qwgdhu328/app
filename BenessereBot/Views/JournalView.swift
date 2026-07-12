import SwiftUI
import SwiftData

struct JournalView: View {
    @Query(sort: \JournalEntry.date, order: .reverse) var entries: [JournalEntry]
    @State private var showWrite = false

    private let prompts = [
        "Cosa ti ha reso grato oggi?", "Come ti sei preso cura di te?", "Cosa hai imparato di nuovo?",
        "Quale momento ti ha fatto sorridere?", "Cosa faresti diversamente oggi?", "Chi ti ha ispirato oggi?",
        "Quale sfida hai affrontato?", "Cosa rende oggi speciale?", "Descrivi il tuo momento di pace.",
        "Quale atto di gentilezza hai visto o fatto?"
    ]

    var body: some View {
        ZStack {
            AppBackground()
            if entries.isEmpty {
                ContentUnavailableView("Nessun pensiero", systemImage: "book", description: Text("Inizia a scrivere il tuo diario")).foregroundStyle(Theme.muted)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(entries) { entry in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(entry.prompt).font(.caption).foregroundStyle(Theme.accent)
                                Text(entry.content).font(.body).foregroundStyle(Theme.text).lineLimit(4)
                                Text(entry.date.formatted(date: .abbreviated, time: .shortened)).font(.caption2).foregroundStyle(Theme.muted)
                            }
                            .glass()
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Diario")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showWrite = true } label: { Image(systemName: "square.and.pencil").foregroundStyle(Theme.accent) }
            }
        }
        .sheet(isPresented: $showWrite) { JournalWriteView(prompts: prompts) }
    }
}

struct JournalWriteView: View {
    let prompts: [String]
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    @State private var prompt = ""
    @State private var content = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                VStack(spacing: 16) {
                    Text(prompt).font(.headline).foregroundStyle(Theme.accent).multilineTextAlignment(.center).padding(.top)
                    TextEditor(text: $content)
                        .scrollContentBackground(.hidden).padding(14)
                        .background(Theme.surface).background(Theme.glassGradient)
                        .clipShape(.rect(cornerRadius: 16))
                        .overlay(.rect(cornerRadius: 16).stroke(Theme.cardBorder, lineWidth: 1))
                        .foregroundStyle(Theme.text)
                    HStack {
                        Button("Salta") { prompt = prompts.randomElement() ?? "Scrivi cosa vuoi..."; content = "" }.foregroundStyle(Theme.muted).buttonStyle(.plain)
                        Spacer()
                        Button("Salva") {
                            guard !content.isEmpty else { return }
                            context.insert(JournalEntry(prompt: prompt, content: content))
                            try? context.save(); dismiss()
                        }.foregroundStyle(Theme.accent).fontWeight(.semibold).buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Nuovo pensiero")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Chiudi") { dismiss() }.foregroundStyle(Theme.muted) } }
        }
        .onAppear { prompt = prompts.randomElement() ?? prompts[0] }
    }
}
