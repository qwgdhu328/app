import SwiftUI
import UserNotifications

struct SettingsView: View {
    @State private var prefs = ReminderPrefs.stored
    @State private var showTimePicker = false
    @State private var notifGranted = false

    var body: some View {
        Form {
            reminderSection
            dynamicIslandSection
            aboutSection
        }
        .navigationTitle("Impostazioni")
        .task {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()
            notifGranted = settings.authorizationStatus == .authorized
        }
        .onChange(of: prefs.isEnabled) { _, _ in apply() }
        .onChange(of: prefs.hour) { _, _ in apply() }
        .onChange(of: prefs.minute) { _, _ in apply() }
        .onChange(of: prefs.useDynamicIsland) { _, _ in apply() }
        .onChange(of: prefs.message) { _, _ in apply() }
        .onChange(of: prefs.repeatDaily) { _, _ in apply() }
    }

    private var reminderSection: some View {
        Section {
            Toggle("Promemoria giornaliero", isOn: $prefs.isEnabled)

            if prefs.isEnabled {
                HStack {
                    Text("Ora")
                    Spacer()
                    Button(action: { showTimePicker.toggle() }) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundStyle(.tint)
                            Text(String(format: "%02d:%02d", prefs.hour, prefs.minute))
                                .font(.title3.weight(.medium))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.regularMaterial)
                        .clipShape(.rect(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }

                if showTimePicker {
                    DatePicker(
                        "Seleziona ora",
                        selection: Binding(
                            get: {
                                Calendar.current.date(from: DateComponents(hour: prefs.hour, minute: prefs.minute)) ?? Date()
                            },
                            set: { date in
                                let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
                                prefs.hour = comps.hour ?? 9
                                prefs.minute = comps.minute ?? 0
                                showTimePicker = false
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                }

                Toggle("Ripeti ogni giorno", isOn: $prefs.repeatDaily)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Messaggio").font(.subheadline).foregroundStyle(.secondary)
                    TextField("Testo del promemoria", text: $prefs.message)
                        .textFieldStyle(.plain)
                        .padding(10)
                        .background(.regularMaterial)
                        .clipShape(.rect(cornerRadius: 10))
                }
            }

            if !notifGranted && prefs.isEnabled {
                Button("Abilita notifiche") {
                    Task { notifGranted = await ReminderManager.shared.requestPermission() }
                }
                .font(.subheadline)
                .foregroundStyle(.tint)
            }

            Button("Test promemoria") {
                UNUserNotificationCenter.current().add(
                    UNNotificationRequest(
                        identifier: "testReminder",
                        content: {
                            let c = UNMutableNotificationContent()
                            c.title = "BenessereBot"
                            c.body = prefs.message
                            c.sound = .default
                            return c
                        }(),
                        trigger: UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                    )
                )
            }
            .font(.subheadline)
            .foregroundStyle(.tint)
        } header: {
            Label("Promemoria", systemImage: "bell.fill")
        }
    }

    private var dynamicIslandSection: some View {
        Section {
            Toggle("Mostra in Dynamic Island", isOn: $prefs.useDynamicIsland)
                .disabled(!ActivityAuthorizationInfo().areActivitiesEnabled)

            if !ActivityAuthorizationInfo().areActivitiesEnabled {
                Text("Dynamic Island non disponibile su questo dispositivo.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Label("Dynamic Island", systemImage: "iphone.gen3")
        }
    }

    private var aboutSection: some View {
        Section {
            aboutRow("Versione", "2.0.0")
            aboutRow("AI Model", "OpenRouter GPT-4o")
            aboutRow("Piattaforma", "iOS nativo")
            Link(destination: URL(string: "https://github.com/qwgdhu328/app")!) {
                HStack {
                    Text("Codice sorgente")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        } header: {
            Label("Informazioni", systemImage: "info.circle.fill")
        }
    }

    private func aboutRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
    }

    private func apply() {
        ReminderPrefs.stored = prefs
        ReminderManager.shared.schedule()
    }
}

#Preview {
    NavigationStack { SettingsView() }
}
