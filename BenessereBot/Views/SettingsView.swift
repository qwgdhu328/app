import SwiftUI
import UserNotifications
import SwiftData

struct SettingsView: View {
    @State private var prefs = ReminderPrefs.stored
    @State private var showTimePicker = false
    @State private var notifGranted = false
    @State private var showDeleteConfirmation = false
    @Environment(\.modelContext) var context

    var body: some View {
        Form {
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
        for model in try? context.fetch(FetchDescriptor<StoredMessage>()) ?? [] { context.delete(model) }
        for model in try? context.fetch(FetchDescriptor<MoodEntry>()) ?? [] { context.delete(model) }
        for model in try? context.fetch(FetchDescriptor<BreathingSession>()) ?? [] { context.delete(model) }
        for model in try? context.fetch(FetchDescriptor<JournalEntry>()) ?? [] { context.delete(model) }
        for model in try? context.fetch(FetchDescriptor<Goal>()) ?? [] { context.delete(model) }
        for model in try? context.fetch(FetchDescriptor<Habit>()) ?? [] { context.delete(model) }
        for model in try? context.fetch(FetchDescriptor<Achievement>()) ?? [] { context.delete(model) }
        for model in try? context.fetch(FetchDescriptor<ChatSession>()) ?? [] { context.delete(model) }
        try? context.save()
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
}
