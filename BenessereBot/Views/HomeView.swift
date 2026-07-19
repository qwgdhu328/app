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
    @State private var wellnessScore = 0
    @EnvironmentObject var breathingService: BreathingService
    @AppStorage("streak") private var streak = 0
    @AppStorage("lastActiveDate") private var lastActiveDate = ""
    @Query var moodEntries: [MoodEntry]
    @Query var entries: [JournalEntry]
    @Query(sort: [SortDescriptor(\JournalEntry.date, order: .reverse)]) var recentEntries: [JournalEntry]
    @Environment(\.modelContext) var context

    private let moodGrid = [
        ("😊", "Felice", Theme.moods[0]), ("😐", "Neutro", Theme.moods[1]),
        ("😢", "Triste", Theme.moods[2]), ("😡", "Arrabbiato", Theme.moods[3]),
        ("😴", "Stanco", Theme.moods[4]), ("🤗", "Riconoscente", Theme.moods[5])
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                ScrollView {
                    VStack(spacing: 20) {
                        greetingCard
                            .offset(y: animateItems ? 0 : 30).opacity(animateItems ? 1 : 0)

                        if !moodEntries.isEmpty {
                            weekConstellation
                                .offset(y: animateItems ? 0 : 25).opacity(animateItems ? 1 : 0)
                        }

                        moodRipplePicker
                            .offset(y: animateItems ? 0 : 20).opacity(animateItems ? 1 : 0)

                        if showAffirmation { affirmationCard }

                        threeWordSnapshot
                            .offset(y: animateItems ? 0 : 20).opacity(animateItems ? 1 : 0)

                        wellnessScoreCard
                            .offset(y: animateItems ? 0 : 15).opacity(animateItems ? 1 : 0)

                        quickNavHub
                            .offset(y: animateItems ? 0 : 15).opacity(animateItems ? 1 : 0)
                    }
                    .padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 24)
                }
                .scrollBounceBehavior(.basedOnSize)

                ForEach(ripples) { ripple in
                    RippleView(ripple: ripple)
                }
            }
            .navigationTitle("")
            .toolbarBackground(.hidden, for: .navigationBar)
            .onAppear {
                checkStreak()
                dailyAffirmation = affirmations.randomElement()!
                wellnessScore = computeWellnessScore()
                withAnimation(.easeOut(duration: 0.8)) { animateItems = true }
            }
            .onDisappear { animateItems = false }
        }
    }

    private let affirmations = [
        "Ogni onda passa. Anche questa.",
        "Sei esattamente dove devi essere.",
        "La calma è la tua superpotenza.",
        "Ascolta ciò che il corpo ti dice.",
        "Non sei solo in questo viaggio.",
        "Il respiro è il tuo ancora.",
        "Ogni passo conta, anche il più piccolo."
    ]

    private var greetingCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Theme.cardBorder, lineWidth: 5)
                    .frame(width: 60, height: 60)
                Circle()
                    .trim(from: 0, to: 0.01 * Double(min(max(streak * 8 + 15, 15), 100)))
                    .stroke(Theme.gradientAccent, style: .init(lineWidth: 5, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring, value: streak)
                Image(systemName: streak > 0 ? "flame.fill" : "leaf.fill")
                    .font(.title3)
                    .foregroundStyle(streak > 0 ? Theme.gold : Theme.accentSecondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                let hour = Calendar.current.component(.hour, from: Date())
                let g = hour < 12 ? "Buongiorno" : hour < 18 ? "Buon pomeriggio" : "Buonasera"
                Text(g).font(.title3.weight(.semibold)).foregroundStyle(Theme.text)
                Text(streak > 0 ? "\(streak) giorni di fila" : "Inizia il tuo percorso")
                    .font(.subheadline).foregroundStyle(Theme.textSecondary)
            }

            Spacer()

            if streak > 0 {
                VStack(spacing: 2) {
                    Text("\(streak)")
                        .font(.title2.weight(.bold)).foregroundStyle(Theme.gold)
                    Text("giorni")
                        .font(.caption2).foregroundStyle(Theme.muted)
                }
            }
        }
        .padding(20)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Theme.cardHighlight, lineWidth: 1))
    }

    private var weekConstellation: some View {
        VStack(spacing: 10) {
            Text("Costellazione della settimana")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Canvas { cx, size in
                let w = size.width; let h = size.height
                let days = last7Days()
                guard !days.isEmpty else { return }
                let angles = stride(from: 0, to: 360, by: max(360 / days.count, 1)).map { Double($0) }
                let cx2 = w / 2; let cy = h / 2; let r = min(cx2, cy) - 16

                for i in days.indices {
                    let angle = angles[i] * .pi / 180
                    let x = cx2 + r * cos(angle); let y = cy + r * sin(angle)
                    let dotR: CGFloat = days[i].score > 0 ? 5 + CGFloat(days[i].score) / 25 : 3
                    let rect = CGRect(x: x - dotR, y: y - dotR, width: dotR * 2, height: dotR * 2)
                    cx.fill(Path(ellipseIn: rect), with: .color(days[i].score > 0 ? moodColor(days[i].emoji) : .gray.opacity(0.2)))
                    if highlightedConstellation == i {
                        let glow = CGRect(x: x - dotR - 4, y: y - dotR - 4, width: (dotR + 4) * 2, height: (dotR + 4) * 2)
                        cx.stroke(Path(ellipseIn: glow), with: .color(Theme.gold.opacity(0.4)), lineWidth: 2)
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
                        cx.stroke(linePath, with: .color(Theme.gold.opacity(0.12)), lineWidth: 0.8)
                    }
                }
            }
            .frame(height: 170)
            .onTapGesture { location in
                let days = last7Days()
                guard !days.isEmpty else { return }
                let w = UIScreen.main.bounds.width - 32; let h: CGFloat = 170
                let angles = stride(from: 0, to: 360, by: max(360 / days.count, 1)).map { Double($0) }
                let cx = w / 2; let cy = h / 2; let r = min(cx, cy) - 16
                for i in days.indices {
                    let angle = angles[i] * .pi / 180
                    let x = cx + r * cos(angle); let y = cy + r * sin(angle)
                    if abs(location.x - x) < 22 && abs(location.y - y) < 22 {
                        withAnimation(.spring) { highlightedConstellation = highlightedConstellation == i ? nil : i }
                        return
                    }
                }
                withAnimation(.spring) { highlightedConstellation = nil }
            }

            if let idx = highlightedConstellation, idx < last7Days().count {
                let d = last7Days()[idx]
                Text("\(d.emoji) \(d.label) — \(d.date.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption).foregroundStyle(Theme.gold).transition(.scale.combined(with: .opacity))
            }
        }
        .padding(20)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Theme.cardBorder, lineWidth: 1))
    }

    private var moodRipplePicker: some View {
        VStack(spacing: 14) {
            Text("Come ti senti ora?")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                ForEach(moodGrid.indices, id: \.self) { i in
                    let (emoji, label, color) = moodGrid[i]
                    MoodButton(emoji: emoji, label: label, color: color, isSelected: selectedMood == emoji) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            selectedMood = emoji; showAffirmation = true
                            addRipple(color: color)
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                            let entry = MoodEntry(moodValue: i + 1, emoji: emoji, label: label, score: (i + 1) * 20)
                            context.insert(entry); try? context.save()
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Theme.cardBorder, lineWidth: 1))
    }

    private var threeWordSnapshot: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Istantanea in 3 parole")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                if !word1.isEmpty || !word2.isEmpty || !word3.isEmpty {
                    Button("Salva") {
                        let words = [word1, word2, word3].filter { !$0.isEmpty }
                        guard !words.isEmpty else { return }
                        context.insert(JournalEntry(prompt: "3-Word Snapshot", content: words.joined(separator: ", ")))
                        try? context.save()
                        word1 = ""; word2 = ""; word3 = ""
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                    .font(.caption.weight(.semibold)).foregroundStyle(Theme.accent)
                }
            }
            HStack(spacing: 8) {
                wordField($word1, placeholder: "parola 1")
                wordField($word2, placeholder: "parola 2")
                wordField($word3, placeholder: "parola 3")
            }
            recentSnapshotCapsules
        }
        .padding(20)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Theme.cardBorder, lineWidth: 1))
    }

    @ViewBuilder
    private var recentSnapshotCapsules: some View {
        let snapshots = recentEntries.filter { $0.prompt == "3-Word Snapshot" }
        if !snapshots.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(snapshots.prefix(5)) { entry in
                        Text(entry.content)
                            .font(.caption2).foregroundStyle(Theme.textSecondary)
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(Theme.accent.opacity(0.08))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Theme.accent.opacity(0.15), lineWidth: 1))
                    }
                }
            }
        }
    }

    private var affirmationCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "quote.opening")
                .font(.title3).foregroundStyle(Theme.gold.opacity(0.4))
            Text(dailyAffirmation)
                .font(.subheadline).italic().foregroundStyle(Theme.text)
                .multilineTextAlignment(.center)
            Image(systemName: "quote.closing")
                .font(.title3).foregroundStyle(Theme.gold.opacity(0.4))
        }
        .padding(20)
        .background(Theme.gold.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Theme.gold.opacity(0.15), lineWidth: 1))
        .transition(.scale.combined(with: .opacity))
    }

    private var wellnessScoreCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().stroke(Theme.cardBorder, lineWidth: 5).frame(width: 52, height: 52)
                Circle()
                    .trim(from: 0, to: Double(wellnessScore) / 100)
                    .stroke(Theme.gradientAccent, style: .init(lineWidth: 5, lineCap: .round))
                    .frame(width: 52, height: 52).rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.2), value: wellnessScore)
                Text("\(wellnessScore)")
                    .font(.callout.weight(.bold)).foregroundStyle(Theme.text)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Punteggio benessere")
                    .font(.caption).foregroundStyle(Theme.muted)
                Text(wellnessLabel)
                    .font(.subheadline.weight(.medium)).foregroundStyle(Theme.text)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption).foregroundStyle(Theme.muted)
        }
        .padding(16)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Theme.cardBorder, lineWidth: 1))
    }

    private var wellnessLabel: String {
        switch wellnessScore {
        case 0..<30: return "Iniziiamo il percorso"
        case 30..<60: return "Buona strada!"
        case 60..<85: return "Stai crescendo"
        default: return "Sei in sintonia"
        }
    }

    private var quickNavHub: some View {
        VStack(spacing: 14) {
            Text("Hub rapido")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                HubCard(icon: "wind", title: "Respiro", subtitle: "Guidato", color: Theme.accent, action: {
                    breathingService.pattern = .simple; breathingService.rounds = 3; breathingService.start()
                })
                HubCard(icon: "waveform", title: "Soundscape", subtitle: "Paesaggio sonoro", color: Theme.accentSecondary, action: { showSoundscape = true })
                HubCard(icon: "book.fill", title: "Diario", subtitle: "Scrivi pensieri", color: Theme.gold, action: {
                    wellnessScore = computeWellnessScore()
                    withAnimation { showAffirmation = true }
                })
                HubCard(icon: "sparkle.magnifyingglass", title: "Esplora", subtitle: "Tutte le funzioni", color: Theme.accentTertiary, action: { showExplore = true })
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
            .background(Theme.bgTop.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.cardBorder, lineWidth: 1))
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

    private func last7Days() -> [(emoji: String, label: String, score: Int, date: Date)] {
        let cal = Calendar.current
        return (0..<7).compactMap { i in
            let d = cal.date(byAdding: .day, value: -i, to: Date())!
            return moodEntries.first { cal.isDate($0.date, inSameDayAs: d) }
                .map { ($0.emoji, $0.label, $0.score, $0.date) }
        }
    }

    private func checkStreak() {
        let today = Self.dateFormatter.string(from: Date())
        if lastActiveDate != today {
            if let last = Self.dateFormatter.date(from: lastActiveDate),
               let diff = Calendar.current.dateComponents([.day], from: last, to: Date()).day {
                streak = diff <= 1 ? streak + 1 : 1
            } else {
                streak = 1
            }
            lastActiveDate = today
        }
    }

    private func computeWellnessScore() -> Int {
        let m = min(moodEntries.count * 10, 30)
        let s = min(streak * 5, 30)
        let j = min(entries.count * 10, 25)
        let b = 0
        return min(m + s + b + j, 100)
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}

private struct MoodButton: View {
    let emoji: String; let label: String; let color: Color; let isSelected: Bool; let action: () -> Void
    var body: some View {
        Button(action: { UIImpactFeedbackGenerator(style: .light).impactOccurred(); action() }) {
            VStack(spacing: 4) {
                Text(emoji).font(.system(size: 32))
                    .scaleEffect(isSelected ? 1.2 : 1)
                    .animation(.spring(response: 0.3), value: isSelected)
                Text(label).font(.caption2.weight(.medium)).foregroundStyle(isSelected ? color : Theme.muted)
            }
            .frame(maxWidth: .infinity).padding(12)
            .background(isSelected ? color.opacity(0.15) : .clear)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? color.opacity(0.4) : Theme.cardBorder, lineWidth: 1)
            )
        }
    }
}

private struct RippleView: View {
    let ripple: Ripple
    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0.6

    var body: some View {
        Circle()
            .fill(ripple.color.opacity(opacity))
            .frame(width: 30, height: 30)
            .scaleEffect(scale)
            .position(ripple.position)
            .onAppear {
                withAnimation(.easeOut(duration: 1.6)) {
                    scale = 8
                    opacity = 0
                }
            }
    }
}

private struct Ripple: Identifiable {
    let id: UUID
    let color: Color
    let position: CGPoint
}

private struct HubCard: View {
    let icon: String; let title: String; let subtitle: String; let color: Color; let action: () -> Void
    @State private var pressed = false
    var body: some View {
        Button(action: { UIImpactFeedbackGenerator(style: .light).impactOccurred(); action() }) {
            VStack(spacing: 6) {
                Image(systemName: icon).font(.title3).foregroundStyle(color)
                Text(title).font(.callout.weight(.semibold)).foregroundStyle(Theme.text)
                Text(subtitle).font(.caption2).foregroundStyle(Theme.textSecondary)
            }
            .frame(maxWidth: .infinity).padding(16)
            .background(color.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(color.opacity(0.2), lineWidth: 1))
        }
        .scaleEffect(pressed ? 0.95 : 1)
        .simultaneousGesture(DragGesture(minimumDistance: 0)
            .onChanged { _ in pressed = true }
            .onEnded { _ in pressed = false }
        )
    }
}
