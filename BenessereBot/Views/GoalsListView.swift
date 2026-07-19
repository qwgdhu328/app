import SwiftUI
import SwiftData

struct GoalsListView: View {
    @Query var goals: [Goal]
    @Query var habits: [Habit]
    @State private var showNewGoal = false
    @State private var showNewHabit = false

    var body: some View {
        ZStack {
            AppBackground()
            ScrollView {
                VStack(spacing: 16) {
                    sectionCard(icon: "target", title: "Obiettivi") {
                        if goals.isEmpty {
                            Text("Nessun obiettivo. Aggiungine uno!")
                                .font(.subheadline).foregroundStyle(Theme.muted)
                        }
                        ForEach(goals) { g in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: g.icon).foregroundStyle(Theme.accent)
                                    Text(g.title).font(.subheadline.weight(.semibold)).foregroundStyle(Theme.text)
                                    Spacer()
                                    Text("\(g.target > 0 ? Int(g.progress / g.target * 100) : 0)%")
                                        .font(.caption).foregroundStyle(Theme.accent)
                                }
                                ProgressView(value: g.progress, total: g.target).tint(Theme.accent)
                            }
                        }
                        Button { showNewGoal = true } label: {
                            Label("Nuovo obiettivo", systemImage: "plus.circle")
                                .font(.subheadline.weight(.medium)).foregroundStyle(Theme.accent)
                                .padding(12).frame(maxWidth: .infinity)
                                .background(Theme.accent.opacity(0.06))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.accent.opacity(0.2), lineWidth: 1))
                        }
                    }

                    sectionCard(icon: "star.fill", title: "Abitudini") {
                        if habits.isEmpty {
                            Text("Nessuna abitudine. Creane una!")
                                .font(.subheadline).foregroundStyle(Theme.muted)
                        }
                        ForEach(habits) { h in
                            HStack {
                                Image(systemName: h.icon).foregroundStyle(Theme.accent)
                                Text(h.title).font(.subheadline).foregroundStyle(Theme.text)
                                Spacer()
                                Text("\(h.streak) gg").font(.caption).foregroundStyle(Theme.gold)
                                Button { toggleHabit(h) } label: {
                                    Image(systemName: "checkmark.circle\(h.lastCompleted.map { Calendar.current.isDateInToday($0) ? ".fill" : "" } ?? "")")
                                        .foregroundStyle(Theme.accent).font(.title3)
                                }
                            }
                        }
                        Button { showNewHabit = true } label: {
                            Label("Nuova abitudine", systemImage: "plus.circle")
                                .font(.subheadline.weight(.medium)).foregroundStyle(Theme.accent)
                                .padding(12).frame(maxWidth: .infinity)
                                .background(Theme.accent.opacity(0.06))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.accent.opacity(0.2), lineWidth: 1))
                        }
                    }
                }
                .padding()
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .navigationTitle("Obiettivi")
        .sheet(isPresented: $showNewGoal) { NewGoalView() }
        .sheet(isPresented: $showNewHabit) { NewHabitView() }
    }

    private func sectionCard<Content: View>(icon: String, title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon).font(.subheadline).foregroundStyle(Theme.accent)
                Text(title).font(.headline.weight(.semibold)).foregroundStyle(Theme.text)
                Spacer()
            }
            content()
        }
        .padding(16)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.cardBorder, lineWidth: 1))
    }

    private func toggleHabit(_ h: Habit) {
        if let last = h.lastCompleted, Calendar.current.isDateInToday(last) { return }
        if let last = h.lastCompleted, Calendar.current.isDateInYesterday(last) { h.streak += 1 }
        else if h.lastCompleted == nil { h.streak = 1 }
        h.lastCompleted = Date()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
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
                VStack(spacing: 16) {
                    TextField("Titolo obiettivo", text: $title)
                        .textFieldStyle(.plain).padding(14)
                        .background(Theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.cardBorder, lineWidth: 1))
                        .foregroundStyle(Theme.text)

                    Picker("Icona", selection: $icon) {
                        Text("🎯").tag("target"); Text("💪").tag("figure.strengthtraining.traditional")
                        Text("🧘").tag("figure.mind.and.body"); Text("📚").tag("book.fill")
                        Text("❤️").tag("heart.fill"); Text("🌟").tag("star.fill")
                    }
                    .pickerStyle(.segmented)

                    Button("Salva") {
                        guard !title.isEmpty else { return }
                        context.insert(Goal(title: title, icon: icon))
                        try? context.save(); dismiss()
                    }
                    .foregroundStyle(Theme.text)
                    .padding(.horizontal, 32).padding(.vertical, 12)
                    .background(Theme.accent)
                    .clipShape(Capsule())
                    .disabled(title.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Nuovo obiettivo")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") { dismiss() }.foregroundStyle(Theme.muted)
                }
            }
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
                VStack(spacing: 16) {
                    TextField("Nome abitudine", text: $title)
                        .textFieldStyle(.plain).padding(14)
                        .background(Theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.cardBorder, lineWidth: 1))
                        .foregroundStyle(Theme.text)

                    Button("Salva") {
                        guard !title.isEmpty else { return }
                        context.insert(Habit(title: title))
                        try? context.save(); dismiss()
                    }
                    .foregroundStyle(Theme.text)
                    .padding(.horizontal, 32).padding(.vertical, 12)
                    .background(Theme.accent)
                    .clipShape(Capsule())
                    .disabled(title.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Nuova abitudine")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") { dismiss() }.foregroundStyle(Theme.muted)
                }
            }
        }
    }
}
