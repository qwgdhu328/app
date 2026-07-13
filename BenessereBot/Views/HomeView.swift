import SwiftUI
import SwiftData

struct HomeView: View {
    @State private var selectedMood: String?
    @State private var showAffirmation = false
    @State private var dailyAffirmation = ""
    @State private var animateItems = false
    @State private var ripples: [Ripple] = []
    @State private var word1 = ""; @State private var word2 = ""; @State private var word3 = ""
    @State private var highlightedConstellation: Int?
    @State private var showExplore = false
    @State private var showSoundscape = false
    @EnvironmentObject var breathingService: BreathingService
    @AppStorage("streak") private var streak = 0
    @AppStorage("lastActiveDate") private var lastActiveDate = ""
    @Query var moodEntries: [MoodEntry]
    @Query var entries: [JournalEntry]
    @Query(sort: [SortDescriptor(\JournalEntry.date, order: .reverse)]) var recentEntries: [JournalEntry]
    @Environment(\.modelContext) var context

    private let moodGrid = [
        ("😊", "Felice", Theme.accent), ("😐", "Neutro", Theme.muted),
        ("😢", "Triste", Color(red: 0.4, green: 0.5, blue: 1.0)), ("😡", "Arrabbiato", Color(red: 1.0, green: 0.3, blue: 0.3)),
        ("😴", "Stanco", Color(red: 0.6, green: 0.4, blue: 0.8)), ("🤗", "Riconoscente", Color(red: 1.0, green: 0.7, blue: 0.3))
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                emotionGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        emotionalThermometer
                            .offset(y: animateItems ? 0 : 40).opacity(animateItems ? 1 : 0)
                        if !moodEntries.isEmpty {
                            weekConstellation
                                .offset(y: animateItems ? 0 : 30).opacity(animateItems ? 1 : 0)
                        }
                        moodRipplePicker
                            .offset(y: animateItems ? 0 : 20).opacity(animateItems ? 1 : 0)
                        if showAffirmation { affirmationCard }
                        threeWordSnapshot
                            .offset(y: animateItems ? 0 : 20).opacity(animateItems ? 1 : 0)
                        quickNavHub
                            .offset(y: animateItems ? 0 : 20).opacity(animateItems ? 1 : 0)
                    }
                    .padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 8)
                }
                .scrollBounceBehavior(.basedOnSize)

                ForEach(ripples) { ripple in
                    RippleView(ripple: ripple)
                        .onAppear {
                            withAnimation(.easeOut(duration: 0.1)) { ripples.removeAll { $0.id == ripple.id } }
                        }
                }
            }
            .navigationTitle("")
            .toolbarBackground(.hidden, for: .navigationBar)
            .onAppear {
                checkStreak()
                dailyAffirmation = ["Ogni onda passa. Anche questa.", "Sei esattamente dove devi essere.", "La calma è la tua superpotenza.", "Ascolta ciò che il corpo ti dice.", "Non sei solo in questo viaggio."].randomElement()!
                withAnimation(.easeOut(duration: 0.8)) { animateItems = true }
            }
            .onDisappear { animateItems = false }
        }
    }

    private var emotionGradient: some View {
        let averageColor = averageMoodColor()
        return LinearGradient(colors: [averageColor.opacity(0.25), Theme.glow2.opacity(0.08), Theme.bgTop], startPoint: .top, endPoint: .bottom)
    }

    private var emotionalThermometer: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle().stroke(Theme.cardBorder, lineWidth: 8).frame(width: 72, height: 72)
                Circle()
                    .trim(from: 0, to: 0.01 * Double(streak > 0 ? min(streak * 10 + 20, 100) : 20))
                    .stroke(moodEntries.last.map { moodColor($0.emoji) } ?? Theme.accent, style: .init(lineWidth: 8, lineCap: .round))
                    .frame(width: 72, height: 72).rotationEffect(.degrees(-90))
                    .shadow(color: (moodEntries.last.map { moodColor($0.emoji) } ?? Theme.accent).opacity(0.6), radius: 8)
            }
            VStack(alignment: .leading, spacing: 4) {
                let hour = Calendar.current.component(.hour, from: Date())
                let g = hour < 12 ? "Buongiorno" : hour < 18 ? "Buon pomeriggio" : "Buonasera"
                Text("\(g)! \(moodEntries.last.map { $0.emoji } ?? "")").font(.title2.weight(.bold)).foregroundStyle(Theme.text)
                Text(streak > 0 ? "\(streak) giorni di fila! 🔥" : "Inizia il tuo percorso").font(.subheadline).foregroundStyle(Theme.accentSecondary)
            }
            Spacer()
        }
        .padding(16)
        .glassEffect(.regular, in: .rect(cornerRadius: 24))
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(moodEntries.last.map { moodColor($0.emoji).opacity(0.08) } ?? Color.clear)
        )
    }

    private var weekConstellation: some View {
        VStack(spacing: 12) {
            Text("✨ Costellazione della settimana").font(.headline).foregroundStyle(Theme.text).frame(maxWidth: .infinity, alignment: .leading)
            Canvas { cx, size in
                let w = size.width; let h = size.height
                let days = last7Days()
                guard !days.isEmpty else { return }
                let angles = stride(from: 0, to: 360, by: max(360 / days.count, 1)).map { Double($0) }
                let cx2 = w / 2; let cy = h / 2; let r = min(cx2, cy) - 12
                for i in days.indices {
                    let angle = angles[i] * .pi / 180
                    let x = cx2 + r * cos(angle); let y = cy + r * sin(angle)
                    if days[i].score > 0 {
                        let starR: CGFloat = highlightedConstellation == i ? 12 : 5 + CGFloat(days[i].score) / 25
                        let rect = CGRect(x: x - starR, y: y - starR, width: starR * 2, height: starR * 2)
                        let c = moodColor(days[i].emoji)
                        cx.addFilter(.shadow(color: UIColor(c).cgColor, radius: highlightedConstellation == i ? 12 : 5))
                        cx.fill(Path(ellipseIn: rect), with: .color(c))
                    } else {
                        let rect = CGRect(x: x - 3, y: y - 3, width: 6, height: 6)
                        cx.fill(Path(ellipseIn: rect), with: .color(.gray.opacity(0.3)))
                    }
                }
                for i in 0..<days.count where days[i].score > 0 {
                    for j in (i + 1)..<days.count where days[j].score > 0 {
                        let a1 = angles[i] * .pi / 180; let a2 = angles[j] * .pi / 180
                        let x1 = cx2 + r * cos(a1); let y1 = cy + r * sin(a1)
                        let x2 = cx2 + r * cos(a2); let y2 = cy + r * sin(a2)
                        var linePath = Path()
                        linePath.move(to: CGPoint(x: x1, y: y1))
                        linePath.addLine(to: CGPoint(x: x2, y: y2))
                        cx.stroke(linePath, with: .color(.white.opacity(0.2)), lineWidth: 1)
                    }
                }
            }
            .frame(height: 180)
            .onTapGesture { location in
                let days = last7Days()
                guard !days.isEmpty else { return }
                let w = UIScreen.main.bounds.width - 40; let h: CGFloat = 180
                let angles = stride(from: 0, to: 360, by: max(360 / days.count, 1)).map { Double($0) }
                let cx = w / 2; let cy = h / 2; let r = min(cx, cy) - 12
                for i in days.indices {
                    let angle = angles[i] * .pi / 180
                    let x = cx + r * cos(angle); let y = cy + r * sin(angle)
                    if abs(location.x - x) < 20 && abs(location.y - y) < 20 {
                        withAnimation(.spring) { highlightedConstellation = highlightedConstellation == i ? nil : i }
                        return
                    }
                }
                withAnimation(.spring) { highlightedConstellation = nil }
            }
            if let idx = highlightedConstellation, idx < last7Days().count {
                let d = last7Days()[idx]
                Text("\(d.emoji) \(d.label) — \(d.date.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption).foregroundStyle(Theme.accent).transition(.scale.combined(with: .opacity))
            }
        }
        .padding(16)
        .glassEffect(.regular, in: .rect(cornerRadius: 24))
    }

    private var moodRipplePicker: some View {
        VStack(spacing: 16) {
            Text("Come ti senti ora?").font(.headline).foregroundStyle(Theme.text).frame(maxWidth: .infinity, alignment: .leading)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(moodGrid.indices, id: \.self) { i in
                    let (emoji, label, color) = moodGrid[i]
                    MoodButton(emoji: emoji, label: label, color: color, isSelected: selectedMood == emoji) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            selectedMood = emoji; showAffirmation = true
                            addRipple(color: color)
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                            let entry = MoodEntry(emoji: emoji, label: label, score: (i + 1) * 20)
                            context.insert(entry); try? context.save()
                        }
                    }
                }
            }
        }
        .padding(16)
        .glassEffect(.regular, in: .rect(cornerRadius: 24))
    }

    private var threeWordSnapshot: some View {
        VStack(spacing: 12) {
            HStack {
                Text("📝 Istantanea in 3 parole").font(.headline).foregroundStyle(Theme.text)
                Spacer()
                if !word1.isEmpty || !word2.isEmpty || !word3.isEmpty {
                    Button("Salva") {
                        let combined = [word1, word2, word3].filter { !$0.isEmpty }.joined(separator: ", ")
                        context.insert(JournalEntry(prompt: "3-Word Snapshot", content: combined))
                        try? context.save()
                        word1 = ""; word2 = ""; word3 = ""
                    }.font(.caption.weight(.semibold)).foregroundStyle(Theme.accent)
                }
            }
            HStack(spacing: 8) {
                wordField($word1, placeholder: "parola 1")
                wordField($word2, placeholder: "parola 2")
                wordField($word3, placeholder: "parola 3")
            }
            recentSnapshotCapsules
        }
        .padding(16)
        .glassEffect(.regular, in: .rect(cornerRadius: 24))
    }

    @ViewBuilder
    private var recentSnapshotCapsules: some View {
        let snapshots = recentEntries.filter { $0.prompt == "3-Word Snapshot" }
        if !snapshots.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(snapshots.prefix(5)) { entry in
                        Text(entry.content)
                            .font(.caption2).foregroundStyle(Theme.textSecondary)
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .glassEffect(.regular, in: Capsule())
                    }
                }
            }
        }
    }

    private var affirmationCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "quote.opening").font(.title3).foregroundStyle(Theme.accent)
            Text(dailyAffirmation).font(.subheadline).italic().foregroundStyle(Theme.text).multilineTextAlignment(.center)
            Image(systemName: "quote.closing").font(.title3).foregroundStyle(Theme.accent)
        }
        .padding(16)
        .glassEffect(.regular, in: .rect(cornerRadius: 24))
        .transition(.scale.combined(with: .opacity))
    }

    private var quickNavHub: some View {
        VStack(spacing: 16) {
            Text("🧭 Centro di connessione").font(.headline).foregroundStyle(Theme.text).frame(maxWidth: .infinity, alignment: .leading)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                HubCard(icon: "brain.head.profile", title: "Mindfulness", subtitle: "Respiro guidato", gradient: [Theme.glow1, Theme.accent.opacity(0.5)]) {
                    breathingService.pattern = .simple; breathingService.rounds = 3; breathingService.start()
                }
                HubCard(icon: "waveform", title: "Soundscape", subtitle: "Paesaggio sonoro", gradient: [Theme.glow3, Color(red: 0.3, green: 0.2, blue: 0.8)]) {
                    showSoundscape = true
                }
                HubCard(icon: "chart.line.uptrend.xyaxis", title: "Statistiche", subtitle: "Il tuo progresso", gradient: [Theme.accentSecondary, Color(red: 1.0, green: 0.2, blue: 0.3)]) {
                    let score = computeWellnessScore(moods: moodEntries.count, streak: streak, sessions: 0, entries: entries.count)
                    dailyAffirmation = "Il tuo benessere è a \(score)%! Continua così 💪"
                    withAnimation { showAffirmation = true }
                }
                HubCard(icon: "sparkle.magnifyingglass", title: "Esplora", subtitle: "Tutte le funzioni", gradient: [Theme.glow3, Color(red: 0.7, green: 0.2, blue: 0.9)]) {
                    showExplore = true
                }
            }
        }
        .sheet(isPresented: $showExplore) { FeatureIntroView() }
        .sheet(isPresented: $showSoundscape) { SoundscapeView() }
    }

    private func wordField(_ text: Binding<String>, placeholder: String) -> some View {
        TextField(placeholder, text: text)
            .textFieldStyle(.plain)
            .font(.caption.weight(.medium))
            .foregroundStyle(Theme.text)
            .padding(.horizontal, 10).padding(.vertical, 8)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.glow1.opacity(0.3), lineWidth: 1))
            .multilineTextAlignment(.center)
    }

    private func addRipple(color: Color) {
        let ripple = Ripple(id: UUID(), color: color, position: CGPoint(x: CGFloat.random(in: 50...300), y: CGFloat.random(in: 200...600)))
        ripples.append(ripple)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { ripples.removeAll { $0.id == ripple.id } }
    }

    private func moodColor(_ emoji: String) -> Color {
        moodGrid.first(where: { $0.0 == emoji }).map { $0.2 } ?? Theme.accent
    }

    private func averageMoodColor() -> Color {
        let recent = moodEntries.suffix(7)
        guard !recent.isEmpty else { return Theme.accent }
        var r: CGFloat = 0; var g: CGFloat = 0; var b: CGFloat = 0; var a: CGFloat = 0; var count = 0
        for entry in recent {
            let c = UIColor(moodColor(entry.emoji))
            var cr: CGFloat = 0; var cg: CGFloat = 0; var cb: CGFloat = 0; var ca: CGFloat = 0
            if c.getRed(&cr, green: &cg, blue: &cb, alpha: &ca) {
                r += cr; g += cg; b += cb; count += 1
            }
        }
        guard count > 0 else { return Theme.accent }
        return Color(red: Double(r / CGFloat(count)), green: Double(g / CGFloat(count)), blue: Double(b / CGFloat(count)))
    }

    private func last7Days() -> [(emoji: String, label: String, score: Int, date: Date)] {
        let cal = Calendar.current
        return (0..<7).compactMap { i in
            let d = cal.date(byAdding: .day, value: -i, to: Date())!
            let match = moodEntries.first { cal.isDate($0.date, inSameDayAs: d) }
            return match.map { ($0.emoji, $0.label, $0.score, $0.date) }
        }
    }

    private func checkStreak() {
        let today = formattedDate(Date())
        if lastActiveDate != today {
            let cal = Calendar.current
            if let last = dateFromString(lastActiveDate), let diff = cal.dateComponents([.day], from: last, to: Date()).day {
                streak = diff <= 1 ? streak + 1 : 0
            } else { streak = 1 }
            lastActiveDate = today
        }
    }
    private func updateStreak() {
        let today = formattedDate(Date())
        if lastActiveDate != today { streak += 1; lastActiveDate = today }
    }
    private func formattedDate(_ d: Date) -> String { let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f.string(from: d) }
    private func dateFromString(_ s: String) -> Date? { let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f.date(from: s) }
    private func computeWellnessScore(moods: Int, streak: Int, sessions: Int, entries: Int) -> Int {
        let m = min(moods * 10, 30); let s = min(streak * 5, 30)
        let b = min(sessions * 15, 25); let j = min(entries * 10, 25)
        return min(m + s + b + j, 100)
    }
}

private struct MoodButton: View {
    let emoji: String; let label: String; let color: Color; let isSelected: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(emoji).font(.system(size: 32))
                    .scaleEffect(isSelected ? 1.3 : 1)
                    .animation(.spring(response: 0.3), value: isSelected)
                Text(label).font(.caption2).foregroundStyle(isSelected ? color : Theme.muted)
            }
            .frame(maxWidth: .infinity).padding(12)
            .background(
                Group {
                    if isSelected { color.opacity(0.25) }
                    else { color.opacity(0.05) }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? color.opacity(0.6) : color.opacity(0.15), lineWidth: 1)
            )
        }
    }
}

private struct RippleView: View {
    let ripple: Ripple
    @State private var scale: CGFloat = 0.2
    @State private var opacity: Double = 0.6

    var body: some View {
        Circle()
            .fill(ripple.color.opacity(opacity))
            .frame(width: 40, height: 40)
            .scaleEffect(scale)
            .position(ripple.position)
            .onAppear {
                withAnimation(.easeOut(duration: 1.5)) { scale = 12; opacity = 0 }
            }
    }
}

private struct Ripple: Identifiable {
    let id: UUID
    let color: Color
    let position: CGPoint
}

private struct HubCard: View {
    let icon: String; let title: String; let subtitle: String; let gradient: [Color]; let action: () -> Void
    @State private var pressed = false
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon).font(.title2).foregroundStyle(.white)
                Text(title).font(.callout.weight(.semibold)).foregroundStyle(.white)
                Text(subtitle).font(.caption2).foregroundStyle(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity).padding(16)
            .background(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
            .clipShape(.rect(cornerRadius: 20))
        }
        .scaleEffect(pressed ? 0.95 : 1)
        .simultaneousGesture(DragGesture(minimumDistance: 0).onChanged { _ in pressed = true }.onEnded { _ in pressed = false })
    }
}


