import SwiftUI
import UserNotifications
import SwiftData

struct SettingsView: View {
    @State private var prefs = ReminderPrefs.stored
    @State private var showTimePicker = false
    @State private var notifGranted = false
    @State private var showDeleteConfirmation = false
    @Environment(\.modelContext) var context
    @AppStorage("aiMode") private var aiMode: String = "hybrid"
    @State private var modelStatus: String = ""

    var body: some View {
        ZStack {
            AppBackground()
            ScrollView {
                VStack(spacing: 16) {
                    aiSection
                    modelSection
                    reminderSection
                    privacySection
                    aboutSection
                }
                .padding()
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .navigationTitle("Impostazioni")
        .task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            notifGranted = settings.authorizationStatus == .authorized
        }
        .onChange(of: prefs.isEnabled) { _, _ in UIImpactFeedbackGenerator(style: .light).impactOccurred(); apply() }
        .onChange(of: prefs.hour) { _, _ in apply() }
        .onChange(of: prefs.minute) { _, _ in apply() }
        .onChange(of: prefs.message) { _, _ in apply() }
        .onChange(of: prefs.repeatDaily) { _, _ in apply() }
        .alert("Cancellare tutti i dati?", isPresented: $showDeleteConfirmation) {
            Button("Annulla", role: .cancel) {}
            Button("Cancella tutto", role: .destructive) { deleteAllData() }
        } message: {
            Text("Questa azione rimuove tutti i messaggi, gli umori, i respiri e i dati del diario. Non può essere annullata.")
        }
    }

    private func sectionCard<Content: View>(icon: String, title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: icon).font(.subheadline).foregroundStyle(Theme.accent)
                Text(title).font(.headline.weight(.semibold)).foregroundStyle(Theme.text)
                Spacer()
            }
            .padding(.bottom, 12)
            content()
        }
        .padding(16)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.cardBorder, lineWidth: 1))
    }

    private var aiSection: some View {
        sectionCard(icon: "apple.logo", title: "Intelligenza") {
            VStack(spacing: 12) {
                Picker("Modalità AI", selection: $aiMode) {
                    Label("Cloud (GPT-4o)", systemImage: "cloud.fill").tag("cloud")
                    Label("Ibrido", systemImage: "arrow.triangle.2.circlepath").tag("hybrid")
                    Label("Locale (Apple Intelligence)", systemImage: "apple.logo").tag("local")
                }
                .pickerStyle(.segmented)
                .onChange(of: aiMode) { _, _ in UIImpactFeedbackGenerator(style: .light).impactOccurred() }

                if aiMode == "local" {
                    HStack {
                        Image(systemName: "lock.shield.fill").foregroundStyle(Theme.accentTertiary)
                        Text("AI 100% offline. Nessun dato lascia il telefono.")
                            .font(.caption).foregroundStyle(Theme.muted)
                    }
                } else if aiMode == "hybrid" {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath").foregroundStyle(Theme.gold)
                        Text("Risposte semplici in locale, complesse via cloud.")
                            .font(.caption).foregroundStyle(Theme.muted)
                    }
                } else {
                    HStack {
                        Image(systemName: "cloud.fill").foregroundStyle(Theme.accentSecondary)
                        Text("Massima potenza, richiede connessione internet.")
                            .font(.caption).foregroundStyle(Theme.muted)
                    }
                }
            }
        }
    }

    private var modelSection: some View {
        sectionCard(icon: "tray.full.fill", title: "Modello AI Locale") {
            VStack(spacing: 10) {
                HStack {
                    Image(systemName: "cpu.fill").foregroundStyle(Theme.accentSecondary)
                    Text("Mistral 7B")
                    Spacer()
                    Text(modelStatus).font(.caption).foregroundStyle(Theme.muted)
                }
                if LocalLLMService.shared.isDownloading {
                    ProgressView(value: LocalLLMService.shared.downloadProgress)
                        .progressViewStyle(.linear).tint(Theme.accent)
                }
                if LocalLLMService.shared.downloadError != nil {
                    Button("Riprova download") {
                        Task { await LocalLLMService.shared.startDownload() }
                    }.font(.subheadline).foregroundStyle(Theme.accent)
                }
            }
        }
        .task {
            modelStatus = LocalLLMService.shared.modelExists
                ? (LocalLLMService.shared.isReady ? "Pronto" : "In caricamento...")
                : (LocalLLMService.shared.isDownloading ? "Scaricamento..." : "In attesa...")
        }
    }

    private var reminderSection: some View {
        sectionCard(icon: "bell.fill", title: "Promemoria") {
            VStack(spacing: 12) {
                Toggle("Promemoria giornaliero", isOn: $prefs.isEnabled)
                    .tint(Theme.accent)

                if prefs.isEnabled {
                    HStack {
                        Text("Ora")
                        Spacer()
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation { showTimePicker.toggle() }
                        }) {
                            HStack {
                                Image(systemName: "clock.fill").foregroundStyle(Theme.accent)
                                Text(String(format: "%02d:%02d", prefs.hour, prefs.minute))
                                    .font(.title3.weight(.medium)).foregroundStyle(Theme.text)
                            }
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(Theme.bgTop.opacity(0.5))
                            .clipShape(.rect(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.cardBorder, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }

                    if showTimePicker {
                        DatePicker("Seleziona ora",
                            selection: Binding(
                                get: { Calendar.current.date(from: DateComponents(hour: prefs.hour, minute: prefs.minute)) ?? Date() },
                                set: {
                                    let c = Calendar.current.dateComponents([.hour, .minute], from: $0)
                                    prefs.hour = c.hour ?? 9; prefs.minute = c.minute ?? 0
                                    withAnimation { showTimePicker = false }
                                }
                            ),
                            displayedComponents: .hourAndMinute
                        ).datePickerStyle(.wheel)
                    }

                    Toggle("Ripeti ogni giorno", isOn: $prefs.repeatDaily).tint(Theme.accent)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Messaggio").font(.subheadline).foregroundStyle(Theme.muted)
                        TextField("Testo del promemoria", text: $prefs.message)
                            .textFieldStyle(.plain).padding(10)
                            .background(Theme.bgTop.opacity(0.5))
                            .clipShape(.rect(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.cardBorder, lineWidth: 1))
                    }
                }

                if !notifGranted && prefs.isEnabled {
                    Button("Abilita notifiche") {
                        Task { notifGranted = await ReminderManager.shared.requestPermission() }
                    }.font(.subheadline).foregroundStyle(Theme.accent)
                }

                Button("Test promemoria") {
                    let c = UNMutableNotificationContent()
                    c.title = "BenessereBot"; c.body = prefs.message; c.sound = .default
                    UNUserNotificationCenter.current().add(
                        UNNotificationRequest(identifier: UUID().uuidString, content: c,
                            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false))
                    )
                }.font(.subheadline).foregroundStyle(Theme.accent)
            }
        }
    }

    private var privacySection: some View {
        sectionCard(icon: "hand.raised.fill", title: "Privacy") {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "lock.shield.fill").foregroundStyle(Theme.accentTertiary)
                    Text("Privacy-by-Design")
                        .font(.subheadline.weight(.semibold)).foregroundStyle(Theme.text)
                }
                Text("I tuoi dati sono crittografati e non lasciano mai il telefono. Nessun dato viene raccolto o condiviso.")
                    .font(.caption).foregroundStyle(Theme.muted)
                Button(role: .destructive) {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    showDeleteConfirmation = true
                } label: {
                    Label("Cancella tutti i dati", systemImage: "trash.fill")
                        .font(.subheadline)
                }
            }
        }
    }

    private var aboutSection: some View {
        sectionCard(icon: "info.circle.fill", title: "Informazioni") {
            VStack(spacing: 8) {
                aboutRow("Versione", "2.0.0")
                aboutRow("AI Model", "Gemini 2.5 Flash Lite")
                aboutRow("Piattaforma", "iOS nativo")
                Link(destination: URL(string: "https://github.com/qwgdhu328/app")!) {
                    HStack {
                        Text("Codice sorgente")
                        Spacer()
                        Image(systemName: "arrow.up.right").font(.caption).foregroundStyle(.tertiary)
                    }
                }
            }
        }
    }

    private func aboutRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(Theme.muted)
            Spacer()
            Text(value).foregroundStyle(Theme.text)
        }
        .font(.subheadline)
    }

    private func apply() {
        ReminderPrefs.stored = prefs
        ReminderManager.shared.schedule()
    }

    private func deleteAllData() {
        deleteType(StoredMessage.self)
        deleteType(MoodEntry.self)
        deleteType(BreathingSession.self)
        deleteType(JournalEntry.self)
        deleteType(Goal.self)
        deleteType(Habit.self)
        deleteType(Achievement.self)
        deleteType(ChatSession.self)
        try? context.save()
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    private func deleteType<T: PersistentModel>(_ type: T.Type) {
        guard let items = try? context.fetch(FetchDescriptor<T>()) else { return }
        for item in items { context.delete(item) }
    }
}
