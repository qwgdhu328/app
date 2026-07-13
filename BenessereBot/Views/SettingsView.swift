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
    @State private var isDownloading = false

    var body: some View {
        Form {
            aiSection
            modelSection
            reminderSection
            privacySection
            aboutSection
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

    private var aiSection: some View {
        Section {
            Picker("Modalità AI", selection: $aiMode) {
                Label("Cloud (GPT-4o)", systemImage: "cloud.fill").tag("cloud")
                Label("Ibrido", systemImage: "arrow.triangle.2.circlepath").tag("hybrid")
                Label("Locale (Apple Intelligence)", systemImage: "apple.logo").tag("local")
            }
            .pickerStyle(.menu)
            .onChange(of: aiMode) { _, _ in UIImpactFeedbackGenerator(style: .light).impactOccurred() }

            if aiMode == "local" {
                VStack(alignment: .leading, spacing: 6) {
                    Label("AI 100% Offline", systemImage: "lock.shield.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.accent)
                    Text("Nessun dato lascia il telefono. Apple Intelligence elabora tutto localmente usando NaturalLanguage framework. Per conversazioni complesse, passa alla modalità Cloud o Ibrida.")
                        .font(.caption)
                        .foregroundStyle(Theme.muted)
                }
            } else if aiMode == "hybrid" {
                VStack(alignment: .leading, spacing: 6) {
                    Label("Privacy + Potenza", systemImage: "arrow.triangle.2.circlepath")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.accent)
                    Text("Le risposte semplici sono generate localmente da Apple Intelligence. Le conversazioni complesse usano il cloud GPT-4o. Migliore equilibrio tra privacy e qualità.")
                        .font(.caption)
                        .foregroundStyle(Theme.muted)
                }
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Label("Massima potenza", systemImage: "cloud.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.accent)
                    Text("Tutte le conversazioni sono elaborate da GPT-4o via cloud. Risposte più ricche ma richiede connessione internet.")
                        .font(.caption)
                        .foregroundStyle(Theme.muted)
                }
            }
        } header: { Label("Apple Intelligence", systemImage: "apple.logo") }
    }

    private var modelSection: some View {
        Section {
            HStack {
                Label("Gemma 2B", systemImage: "cpu.fill")
                Spacer()
                if isDownloading {
                    ProgressView().scaleEffect(0.8)
                } else {
                    Text(modelStatus).font(.caption).foregroundStyle(Theme.muted)
                }
            }
            if !modelStatus.isEmpty && !isDownloading {
                Button("Scarica modello locale (1.5 GB)") {
                    isDownloading = true
                    modelStatus = "Scaricamento..."
                    Task {
                        let ok = await LocalLLMService.shared.downloadModel()
                        await MainActor.run {
                            isDownloading = false
                            modelStatus = ok ? "Pronto" : "Errore download"
                        }
                    }
                }
                .disabled(isDownloading)
                .font(.subheadline)
            }
        } header: { Label("Modello AI Locale", systemImage: "tray.full.fill") }
        .task {
            modelStatus = LocalLLMService.shared.modelExists ? "Pronto" : "Non scaricato"
        }
    }

    private var reminderSection: some View {
        Section {
            Toggle("Promemoria giornaliero", isOn: $prefs.isEnabled)

            if prefs.isEnabled {
                HStack {
                    Text("Ora")
                    Spacer()
                    Button(action: { UIImpactFeedbackGenerator(style: .light).impactOccurred(); showTimePicker.toggle() }) {
                        HStack {
                            Image(systemName: "clock.fill").foregroundStyle(.tint)
                            Text(String(format: "%02d:%02d", prefs.hour, prefs.minute))
                                .font(.title3.weight(.medium))
                        }
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Theme.card).clipShape(.rect(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }

                if showTimePicker {
                    DatePicker("Seleziona ora",
                        selection: Binding(
                            get: { Calendar.current.date(from: DateComponents(hour: prefs.hour, minute: prefs.minute)) ?? Date() },
                            set: { let c = Calendar.current.dateComponents([.hour, .minute], from: $0); prefs.hour = c.hour ?? 9; prefs.minute = c.minute ?? 0; showTimePicker = false }
                        ),
                        displayedComponents: .hourAndMinute
                    ).datePickerStyle(.wheel)
                }

                Toggle("Ripeti ogni giorno", isOn: $prefs.repeatDaily)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Messaggio").font(.subheadline).foregroundStyle(Theme.muted)
                    TextField("Testo del promemoria", text: $prefs.message)
                        .textFieldStyle(.plain).padding(10)
                        .background(Theme.card).clipShape(.rect(cornerRadius: 10))
                }
            }

            if !notifGranted && prefs.isEnabled {
                Button("Abilita notifiche") {
                    Task { notifGranted = await ReminderManager.shared.requestPermission() }
                }.font(.subheadline).foregroundStyle(.tint)
            }

            Button("Test promemoria") {
                let c = UNMutableNotificationContent(); c.title = "BenessereBot"; c.body = prefs.message; c.sound = .default
                UNUserNotificationCenter.current().add(
                    UNNotificationRequest(identifier: "testReminder", content: c, trigger: UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false))
                )
            }.font(.subheadline).foregroundStyle(.tint)
        } header: { Label("Promemoria", systemImage: "bell.fill") }
    }

    private var privacySection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Label("Privacy-by-Design", systemImage: "lock.shield.fill")
                    .font(.subheadline.weight(.semibold))
                Text("I tuoi dati sono crittografati e non lasciano mai il telefono. Nessun dato viene raccolto o condiviso.")
                    .font(.caption)
                    .foregroundStyle(Theme.muted)
            }
            Button(role: .destructive) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                showDeleteConfirmation = true
            } label: {
                Label("Cancella tutti i dati", systemImage: "trash.fill")
            }
        } header: { Label("Privacy", systemImage: "hand.raised.fill") }
    }

    private var aboutSection: some View {
        Section {
            aboutRow("Versione", "2.0.0")
            aboutRow("AI Model", "OpenRouter GPT-4o")
            aboutRow("Piattaforma", "iOS nativo")
            Link(destination: URL(string: "https://github.com/qwgdhu328/app")!) {
                HStack { Text("Codice sorgente"); Spacer(); Image(systemName: "arrow.up.right").font(.caption).foregroundStyle(.tertiary) }
            }
        } header: { Label("Informazioni", systemImage: "info.circle.fill") }
    }

    private func aboutRow(_ label: String, _ value: String) -> some View {
        HStack { Text(label).foregroundStyle(Theme.muted); Spacer(); Text(value) }
    }

    private func apply() {
        ReminderPrefs.stored = prefs
        ReminderManager.shared.schedule()
    }

    private func deleteAllData() {
        if let items = try? context.fetch(FetchDescriptor<StoredMessage>()) {
            for item in items { context.delete(item) }
        }
        if let items = try? context.fetch(FetchDescriptor<MoodEntry>()) {
            for item in items { context.delete(item) }
        }
        if let items = try? context.fetch(FetchDescriptor<BreathingSession>()) {
            for item in items { context.delete(item) }
        }
        if let items = try? context.fetch(FetchDescriptor<JournalEntry>()) {
            for item in items { context.delete(item) }
        }
        if let items = try? context.fetch(FetchDescriptor<Goal>()) {
            for item in items { context.delete(item) }
        }
        if let items = try? context.fetch(FetchDescriptor<Habit>()) {
            for item in items { context.delete(item) }
        }
        if let items = try? context.fetch(FetchDescriptor<Achievement>()) {
            for item in items { context.delete(item) }
        }
        if let items = try? context.fetch(FetchDescriptor<ChatSession>()) {
            for item in items { context.delete(item) }
        }
        try? context.save()
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
}
