import SwiftUI
import SwiftData

struct CommunityView: View {
    @State private var selectedSection = 0
    @State private var showNewPost = false

    private let sections = ["Gruppi", "Sfide", "Articoli", "Eventi"]

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                VStack(spacing: 0) {
                    Picker("Sezione", selection: $selectedSection) {
                        ForEach(sections.indices, id: \.self) { i in
                            Text(sections[i]).tag(i)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16).padding(.vertical, 8)

                    TabView(selection: $selectedSection) {
                        groupsView.tag(0)
                        challengesView.tag(1)
                        articlesView.tag(2)
                        eventsView.tag(3)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Community")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showNewPost = true
                    } label: {
                        Image(systemName: "square.and.pencil").foregroundStyle(Theme.accent)
                    }
                }
            }
            .sheet(isPresented: $showNewPost) { NewPostView() }
        }
    }

    private var groupsView: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(sampleGroups) { group in
                    NavigationLink(destination: GroupDetailView(group: group)) {
                        communityCard(icon: group.icon, title: group.name, subtitle: group.description, color: group.color, members: group.memberCount)
                    }
                }
            }
            .padding()
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    private var challengesView: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(sampleChallenges) { challenge in
                    challengeCard(challenge)
                }
            }
            .padding()
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    private var articlesView: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(sampleArticles) { article in
                    NavigationLink(destination: ArticleDetailView(article: article)) {
                        articleCard(article)
                    }
                }
            }
            .padding()
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    private var eventsView: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(sampleEvents) { event in
                    eventCard(event)
                }
            }
            .padding()
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    private func communityCard(icon: String, title: String, subtitle: String, color: Color, members: Int) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(color.opacity(0.12)).frame(width: 44, height: 44)
                Image(systemName: icon).font(.subheadline).foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(Theme.text)
                Text(subtitle).font(.caption).foregroundStyle(Theme.muted).lineLimit(2)
            }
            Spacer()
            VStack(spacing: 2) {
                Text("\(members)").font(.caption.weight(.bold)).foregroundStyle(color)
                Text("membri").font(.caption2).foregroundStyle(Theme.muted)
            }
        }
        .padding(14)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.cardBorder, lineWidth: 1))
    }

    private func challengeCard(_ challenge: CommunityChallenge) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: challenge.icon).font(.title3).foregroundStyle(challenge.color)
                Text(challenge.title).font(.subheadline.weight(.semibold)).foregroundStyle(Theme.text)
                Spacer()
                Text("\(challenge.participants) iscritti").font(.caption2).foregroundStyle(Theme.muted)
            }
            Text(challenge.description).font(.caption).foregroundStyle(Theme.textSecondary)
            ProgressView(value: challenge.progress).tint(challenge.color)
            HStack {
                Text("\(Int(challenge.progress * 100))% completato").font(.caption2).foregroundStyle(Theme.muted)
                Spacer()
                Button("Partecipa") {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                .font(.caption.weight(.semibold)).foregroundStyle(Theme.text)
                .padding(.horizontal, 12).padding(.vertical, 4)
                .background(challenge.color.opacity(0.15))
                .clipShape(Capsule())
            }
        }
        .padding(16)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.cardBorder, lineWidth: 1))
    }

    private func articleCard(_ article: CommunityArticle) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12).fill(article.color.opacity(0.12)).frame(width: 48, height: 48)
                Image(systemName: article.icon).font(.title3).foregroundStyle(article.color)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(article.title).font(.subheadline.weight(.semibold)).foregroundStyle(Theme.text)
                Text(article.excerpt).font(.caption).foregroundStyle(Theme.muted).lineLimit(2)
                Text(article.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2).foregroundStyle(Theme.accentSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.caption).foregroundStyle(Theme.muted)
        }
        .padding(14)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.cardBorder, lineWidth: 1))
    }

    private func eventCard(_ event: CommunityEvent) -> some View {
        HStack(spacing: 14) {
            VStack(spacing: 4) {
                Text(event.date.formatted(.dateTime.day())).font(.title3.weight(.bold)).foregroundStyle(event.color)
                Text(event.date.formatted(.dateTime.month(.abbreviated))).font(.caption2).foregroundStyle(Theme.muted)
            }
            .frame(width: 48)
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title).font(.subheadline.weight(.semibold)).foregroundStyle(Theme.text)
                Text(event.description).font(.caption).foregroundStyle(Theme.muted).lineLimit(2)
                Label(event.location, systemImage: "mappin").font(.caption2).foregroundStyle(Theme.accent)
            }
            Spacer()
        }
        .padding(14)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.cardBorder, lineWidth: 1))
    }
}

// MARK: - Models

struct CommunityGroup: Identifiable {
    let id = UUID()
    let icon: String; let name: String; let description: String
    let color: Color; let memberCount: Int
}

struct CommunityChallenge: Identifiable {
    let id = UUID()
    let icon: String; let title: String; let description: String
    let color: Color; let participants: Int; let progress: Double
}

struct CommunityArticle: Identifiable {
    let id = UUID()
    let icon: String; let title: String; let excerpt: String
    let color: Color; let date: Date
}

struct CommunityEvent: Identifiable {
    let id = UUID()
    let title: String; let description: String
    let location: String; let color: Color; let date: Date
}

private let sampleGroups = [
    CommunityGroup(icon: "brain.head.profile", name: "Mindfulness Italia", description: "Tecniche di meditazione e consapevolezza", color: Color(red: 0.35, green: 0.70, blue: 0.55), memberCount: 234),
    CommunityGroup(icon: "heart.fill", name: "Supporto Ansia", description: "Condividi esperienze e strategie", color: Color(red: 0.90, green: 0.55, blue: 0.50), memberCount: 189),
    CommunityGroup(icon: "sun.max.fill", name: "Crescita Personale", description: "Obiettivi, abitudini e motivazione", color: Color(red: 0.88, green: 0.70, blue: 0.30), memberCount: 312),
    CommunityGroup(icon: "book.fill", name: "Letture Benessere", description: "Libri e articoli sul benessere mentale", color: Color(red: 0.55, green: 0.45, blue: 0.85), memberCount: 156),
]

private let sampleChallenges = [
    CommunityChallenge(icon: "flame.fill", title: "30 Giorni di Mindfulness", description: "Medita 10 minuti al giorno per 30 giorni consecutivi.", color: Color(red: 0.90, green: 0.55, blue: 0.30), participants: 89, progress: 0.4),
    CommunityChallenge(icon: "heart.fill", title: "Gratitudine Quotidiana", description: "Scrivi 3 cose per cui sei grato ogni giorno.", color: Color(red: 0.94, green: 0.66, blue: 0.60), participants: 145, progress: 0.25),
    CommunityChallenge(icon: "wind", title: "Respiro Consapevole", description: "5 esercizi di respiro al giorno per 2 settimane.", color: Color(red: 0.35, green: 0.70, blue: 0.55), participants: 67, progress: 0.6),
]

private let sampleArticles = [
    CommunityArticle(icon: "brain.head.profile", title: "Come gestire l'ansia quotidiana", excerpt: "Tecniche pratiche di CBT per ridurre l'ansia nella vita di tutti i giorni.", color: Color(red: 0.55, green: 0.45, blue: 0.85), date: Date().addingTimeInterval(-86400 * 2)),
    CommunityArticle(icon: "moon.stars.fill", title: "L'importanza del sonno", excerpt: "Come la qualità del sonno influenza il tuo benessere mentale.", color: Color(red: 0.35, green: 0.45, blue: 0.75), date: Date().addingTimeInterval(-86400 * 5)),
    CommunityArticle(icon: "heart.fill", title: "Autocompassione: la chiave", excerpt: "Impara a trattarti con la stessa gentilezza che riservi agli altri.", color: Color(red: 0.94, green: 0.66, blue: 0.60), date: Date().addingTimeInterval(-86400 * 7)),
]

private let sampleEvents = [
    CommunityEvent(title: "Workshop: Respirare la Calma", description: "Esercizi di respiro guidati in gruppo.", location: "Online — Zoom", color: Color(red: 0.35, green: 0.70, blue: 0.55), date: Date().addingTimeInterval(86400 * 3)),
    CommunityEvent(title: "Gruppo di Supporto", description: "Incontro settimanale per condividere esperienze.", location: "Milano, Via Roma 12", color: Color(red: 0.90, green: 0.55, blue: 0.50), date: Date().addingTimeInterval(86400 * 5)),
    CommunityEvent(title: "Meditazione di Gruppo", description: "Sessione di meditazione guidata di 30 minuti.", location: "Online — Google Meet", color: Color(red: 0.55, green: 0.45, blue: 0.85), date: Date().addingTimeInterval(86400 * 7)),
]

// MARK: - Detail Views

struct GroupDetailView: View {
    let group: CommunityGroup
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            AppBackground()
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    ZStack {
                        Circle().fill(group.color.opacity(0.12)).frame(width: 80, height: 80)
                        Image(systemName: group.icon).font(.system(size: 40)).foregroundStyle(group.color)
                    }
                    Text(group.name).font(.title2.weight(.bold)).foregroundStyle(Theme.text)
                    Text(group.description).font(.subheadline).foregroundStyle(Theme.textSecondary).multilineTextAlignment(.center)
                    Text("\(group.memberCount) membri").font(.caption).foregroundStyle(Theme.muted)
                }
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Label("Unisciti al gruppo", systemImage: "person.badge.plus")
                        .font(.headline.weight(.semibold)).foregroundStyle(.white)
                        .padding(.horizontal, 32).padding(.vertical, 14)
                        .background(group.color)
                        .clipShape(Capsule())
                }
                Spacer()
            }
            .padding()
        }
        .navigationTitle(group.name)
    }
}

struct ArticleDetailView: View {
    let article: CommunityArticle

    var body: some View {
        ZStack {
            AppBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20).fill(article.color.opacity(0.08)).frame(height: 120)
                        Image(systemName: article.icon).font(.system(size: 56)).foregroundStyle(article.color.opacity(0.4))
                    }
                    Text(article.title).font(.title2.weight(.bold)).foregroundStyle(Theme.text)
                    Text(article.date.formatted(date: .long, time: .omitted)).font(.caption).foregroundStyle(Theme.muted)
                    Text(bodyText).font(.body).foregroundStyle(Theme.textSecondary).lineSpacing(6)
                }
                .padding()
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .navigationTitle(article.title)
    }

    private var bodyText: String {
        "Questo è un articolo sul benessere mentale. " +
        "La ricerca mostra che prendersi cura della propria salute mentale è fondamentale " +
        "per una vita equilibrata e soddisfacente. " +
        "Pratiche come la mindfulness, la meditazione e la terapia cognitivo-comportamentale " +
        "hanno dimostrato efficacia nel migliorare il benessere psicologico.\n\n" +
        "Ricorda: chiedere aiuto è un segno di forza, non di debolezza. " +
        "Se stai attraversando un momento difficile, parlane con un professionista."
    }
}

struct NewPostView: View {
    @Environment(\.dismiss) var dismiss
    @State private var content = ""
    @State private var selectedSection = 0
    private let sections = ["Gruppi", "Sfide", "Domanda"]

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                VStack(spacing: 16) {
                    Picker("Sezione", selection: $selectedSection) {
                        ForEach(sections.indices, id: \.self) { i in
                            Text(sections[i]).tag(i)
                        }
                    }
                    .pickerStyle(.segmented)

                    TextEditor(text: $content)
                        .scrollContentBackground(.hidden)
                        .padding(14)
                        .background(Theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .foregroundStyle(Theme.text)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.cardBorder, lineWidth: 1))

                    HStack {
                        Button("Annulla") { dismiss() }
                            .foregroundStyle(Theme.muted)
                        Spacer()
                        Button("Pubblica") {
                            dismiss()
                        }
                        .foregroundStyle(Theme.accent)
                        .fontWeight(.semibold)
                        .disabled(content.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
                .padding()
            }
            .navigationTitle("Nuovo post")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") { dismiss() }.foregroundStyle(Theme.muted)
                }
            }
        }
    }
}
