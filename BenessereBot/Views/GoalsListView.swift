import SwiftUI
import SwiftData

struct GoalsListView: View {
    @Query var goals: [Goal]
    @Query var habits: [Habit]
    @State private var showNewGoal = false
    @State private var showNewHabit = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                List {
                    Section("Obiettivi") {
                        if goals.isEmpty {
                            Text("Nessun obiettivo. Aggiungine uno!").foregroundStyle(Theme.muted).listRowBackground(Theme.card)
                        }
                        ForEach(goals) { g in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Image(systemName: g.icon).foregroundStyle(Theme.accent)
                                    Text(g.title).font(.headline).foregroundStyle(Theme.text)
                                    Spacer()
                                    Text("\(Int(g.progress / g.target * 100))%").font(.caption).foregroundStyle(Theme.muted)
                                }
                                ProgressView(value: g.progress, total: g.target).tint(Theme.breathing)
                            }
                            .listRowBackground(Theme.card)
                        }
                        Button { showNewGoal = true } label: {
                            Label("Nuovo obiettivo", systemImage: "plus.circle").foregroundStyle(Theme.accent)
                        }.listRowBackground(Theme.card)
                    }
                    Section("Abitudini") {
                        if habits.isEmpty {
                            Text("Nessuna abitudine. Creane una!").foregroundStyle(Theme.muted).listRowBackground(Theme.card)
                        }
                        ForEach(habits) { h in
                            HStack {
                                Image(systemName: h.icon).foregroundStyle(Theme.breathing)
                                Text(h.title).foregroundStyle(Theme.text)
                                Spacer()
                                Text("\(h.streak) gg").font(.caption).foregroundStyle(Theme.accent)
                                Button { toggleHabit(h) } label: {
                                    Image(systemName: "checkmark.circle\(h.lastCompleted.map { Calendar.current.isDateInToday($0) ? ".fill" : "" } ?? "")").foregroundStyle(Theme.breathing)
                                }
                            }
                            .listRowBackground(Theme.card)
                        }
                        Button { showNewHabit = true } label: {
                            Label("Nuova abitudine", systemImage: "plus.circle").foregroundStyle(Theme.breathing)
                        }.listRowBackground(Theme.card)
                    }
                }
                .listStyle(.insetGrouped).scrollContentBackground(.hidden)
            }
            .navigationTitle("Obiettivi")
            .sheet(isPresented: $showNewGoal) { NewGoalView() }
            .sheet(isPresented: $showNewHabit) { NewHabitView() }
        }
    }

    private func toggleHabit(_ h: Habit) {
        if let last = h.lastCompleted, Calendar.current.isDateInToday(last) { return }
        if let last = h.lastCompleted, Calendar.current.isDateInYesterday(last) { h.streak += 1 }
        else if h.lastCompleted == nil { h.streak = 1 }
        h.lastCompleted = Date()
    }
}

struct NewGoalView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    @State private var title = ""
    @State private var icon = "target"

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                Form {
                    TextField("Titolo", text: $title).listRowBackground(Theme.card)
                    Picker("Icona", selection: $icon) {
                        Text("🎯").tag("target"); Text("💪").tag("figure.strengthtraining.traditional"); Text("🧘").tag("figure.mind.and.body")
                        Text("📚").tag("book.fill"); Text("❤️").tag("heart.fill"); Text("🌟").tag("star.fill")
                    }.listRowBackground(Theme.card)
                    Button("Salva") {
                        guard !title.isEmpty else { return }
                        context.insert(Goal(title: title, icon: icon))
                        try? context.save()
                        dismiss()
                    }.foregroundStyle(Theme.accent)
                }.scrollContentBackground(.hidden)
            }
            .navigationTitle("Nuovo obiettivo")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Chiudi") { dismiss() }.foregroundStyle(Theme.muted) } }
        }
    }
}

struct NewHabitView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    @State private var title = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                Form {
                    TextField("Abitudine", text: $title).listRowBackground(Theme.card)
                    Button("Salva") {
                        guard !title.isEmpty else { return }
                        context.insert(Habit(title: title))
                        try? context.save()
                        dismiss()
                    }.foregroundStyle(Theme.accent)
                }.scrollContentBackground(.hidden)
            }
            .navigationTitle("Nuova abitudine")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Chiudi") { dismiss() }.foregroundStyle(Theme.muted) } }
        }
    }
}
