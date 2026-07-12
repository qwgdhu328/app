import SwiftUI
import SwiftData

struct ChatView: View {
    @State private var viewModel = ChatViewModel()
    @State private var inputText = ""
    @State private var showPsychologists = false
    @State private var speechRecognizer: SpeechRecognizer?
    @State private var aiPersona: AIPersona = .therapist
    @FocusState private var isFocused: Bool
    @Environment(\.modelContext) var context

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                PersonaPickerView(selected: $aiPersona)
                    .padding(.horizontal).padding(.vertical, 8)
                ScrollViewReader { proxy in
                    ScrollView {
                        if viewModel.messages.isEmpty {
                            emptyState
                        } else {
                            LazyVStack(spacing: 0) {
                                ForEach(Array(viewModel.messages.enumerated()), id: \.element.id) { i, msg in
                                    VStack(spacing: 0) {
                                        if shouldShowDateDivider(at: i) { dateDivider(msg.timestamp) }
                                        MessageBubble(message: msg)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 4)
                                            .id(msg.id)
                                            .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
                                    }
                                }
                                if viewModel.isLoading { typingIndicator.padding(.horizontal, 16).padding(.vertical, 8) }
                                if let error = viewModel.errorMessage { errorBanner(error) }
                            }
                            .padding(.top, 8)
                        }
                    }
                    .scrollDismissesKeyboard(.immediately)
                    .scrollBounceBehavior(.basedOnSize)
                    .onChange(of: viewModel.messages.count) { _, _ in
                        withAnimation { proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom) }
                    }
                }
                if viewModel.showPsychologists { psychologistBanner }
                inputBar
            }
            .background(AppBackground())
            .navigationTitle("")
            .toolbarBackground(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 8) }
            .sheet(isPresented: $showPsychologists) { PsychologistsListView(city: viewModel.suggestedCity) }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 100)
            Image(systemName: "brain.head.profile").font(.system(size: 64)).foregroundStyle(Theme.accent.opacity(0.5))
            Text("Parla con BenessereBot").font(.title2.weight(.bold)).foregroundStyle(Theme.text)
            Text("Uno psicologo virtuale sempre pronto ad ascoltarti.\nCondividi ciò che senti, senza giudizio.")
                .multilineTextAlignment(.center).foregroundStyle(Theme.textSecondary).padding(.horizontal, 40)
            Spacer()
        }
    }

    private var psychologistBanner: some View {
        Button { showPsychologists = true } label: {
            HStack {
                Image(systemName: "person.2.fill").foregroundStyle(Theme.accent)
                Text("Parlare con uno psicologo umano?").font(.subheadline.weight(.medium)).foregroundStyle(Theme.text)
                Spacer()
                Image(systemName: "chevron.right").font(.caption).foregroundStyle(Theme.muted)
            }
            .padding(12).padding(.horizontal, 4)
            .glassEffect(.regular, in: .rect(cornerRadius: 14))
            .padding(.horizontal, 16).padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            Button { handleMicTap() } label: {
                Image(systemName: speechRecognizer?.isListening == true ? "mic.fill" : "mic")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(speechRecognizer?.isListening == true ? Theme.accent : Theme.muted)
                    .frame(width: 36, height: 36)
                    .background(speechRecognizer?.isListening == true ? Theme.accent.opacity(0.15) : Color.clear)
                    .clipShape(.circle)
            }
            TextField("Scrivi come ti senti...", text: $inputText)
                .textFieldStyle(.plain)
                .padding(14)
                .glassEffect(.regular, in: .rect(cornerRadius: 20))
                .foregroundStyle(Theme.text)
                .focused($isFocused)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Chiudi") { isFocused = false }.foregroundStyle(Theme.accent)
                    }
                }
            Button {
                let text = inputText; inputText = ""
                viewModel.send(text, persona: aiPersona)
                context.insert(StoredMessage(role: "user", content: text)); try? context.save()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32)).foregroundStyle(Theme.accent)
            }
            .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
        .glassEffect(.regular, in: .rect(cornerRadius: 0))
    }

    private var typingIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<3) { i in
                Circle().fill(Theme.textSecondary).frame(width: 6, height: 6)
                    .opacity(viewModel.isLoading ? 1 : 0.3)
            }
            Text("Sta riflettendo...").font(.caption).foregroundStyle(Theme.muted).padding(.leading, 4)
        }
    }

    private func errorBanner(_ msg: String) -> some View {
        Text(msg).font(.caption).foregroundStyle(Theme.accentSecondary).padding(.vertical, 8).padding(.horizontal, 16)
    }

    private func shouldShowDateDivider(at i: Int) -> Bool {
        guard i > 0 else { return true }
        let prev = viewModel.messages[i - 1].timestamp, curr = viewModel.messages[i].timestamp
        return !Calendar.current.isDate(prev, inSameDayAs: curr)
    }

    private func dateDivider(_ date: Date) -> some View {
        HStack {
            Rectangle().fill(Theme.cardBorder).frame(height: 1)
            Text(date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption2).foregroundStyle(Theme.muted).padding(.horizontal, 8)
            Rectangle().fill(Theme.cardBorder).frame(height: 1)
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
    }

    private func handleMicTap() {
        if let sr = speechRecognizer, sr.isListening { sr.stop(); return }
        let sr = SpeechRecognizer(); speechRecognizer = sr
        Task {
            guard await sr.requestAuthorization() else { return }
            sr.start { text in Task { @MainActor in guard !text.isEmpty else { return }; self.inputText = text; self.viewModel.send(text, persona: aiPersona) } }
        }
    }
}

struct MessageBubble: View {
    let message: Message
    @State private var appear = false
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.role == "user" {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content).padding(14)
                        .foregroundStyle(Theme.text)
                        .background(Theme.accent.opacity(0.15))
                        .clipShape(.rect(cornerRadius: 18))
                    Text(message.timestamp.formatted(date: .omitted, time: .shortened)).font(.caption2).foregroundStyle(Theme.muted)
                }
                .padding(.leading, 60)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.content).padding(14)
                        .foregroundStyle(Theme.text)
                        .glassEffect(.regular, in: .rect(cornerRadius: 18))
                    Text(message.timestamp.formatted(date: .omitted, time: .shortened)).font(.caption2).foregroundStyle(Theme.muted)
                }
                .padding(.trailing, 60)
                Spacer()
            }
        }
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 10)
        .onAppear { withAnimation(.spring.delay(0.05)) { appear = true } }
    }
}
