import SwiftUI
import SwiftData

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var inputText = ""
    @State private var showPsychologists = false
    @State private var speechRecognizer: SpeechRecognizer?
    @State private var aiPersona: AIPersona = .therapist
    @FocusState private var isFocused: Bool
    @State private var currentSession: ChatSession?
    @Environment(\.modelContext) var context
    @Query private var sessions: [ChatSession]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                personaHeader
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
            .sheet(isPresented: Binding(
                get: { showPsychologists || viewModel.showPsychologists },
                set: { showPsychologists = $0; if !$0 { viewModel.showPsychologists = false } }
            )) {
                PsychologistsListView(city: viewModel.suggestedCity)
            }
            .onAppear {
                if currentSession == nil {
                    currentSession = sessions.first ?? { let s = ChatSession(); context.insert(s); return s }()
                }
                viewModel.currentSession = currentSession
                viewModel.loadPersistedMessages(from: context, session: currentSession!)
            }
        }
    }

    private var personaHeader: some View {
        HStack {
            ForEach(AIPersona.allCases, id: \.self) { p in
                Button {
                    withAnimation(.spring) { aiPersona = p }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: p.icon)
                            .font(.system(size: 16))
                        Text(p.rawValue)
                            .font(.caption2.weight(.medium))
                    }
                    .foregroundStyle(aiPersona == p ? Theme.accent : Theme.muted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(aiPersona == p ? Theme.accent.opacity(0.12) : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 6)
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 80)
            ZStack {
                Circle().fill(Theme.gradientAccent.opacity(0.1)).frame(width: 80, height: 80)
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 36)).foregroundStyle(Theme.accent)
            }
            Text("Parla con BenessereBot")
                .font(.title2.weight(.bold)).foregroundStyle(Theme.text)
            Text("Condividi ciò che senti, senza giudizio.\nSono qui per ascoltarti.")
                .multilineTextAlignment(.center).foregroundStyle(Theme.textSecondary).padding(.horizontal, 40)
            Spacer()
        }
    }

    private var psychologistBanner: some View {
        Button {
            showPsychologists = true
            viewModel.showPsychologists = false
        } label: {
            HStack {
                Image(systemName: "person.2.fill").foregroundStyle(Theme.accent)
                Text("Parlare con uno psicologo umano?")
                    .font(.subheadline.weight(.medium)).foregroundStyle(Theme.text)
                Spacer()
                Image(systemName: "chevron.right").font(.caption).foregroundStyle(Theme.muted)
            }
            .padding(12).padding(.horizontal, 4)
            .background(Theme.accent.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.accent.opacity(0.15), lineWidth: 1))
            .padding(.horizontal, 16).padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                handleMicTap()
            } label: {
                Image(systemName: speechRecognizer?.isListening == true ? "mic.fill" : "mic")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(speechRecognizer?.isListening == true ? Theme.accent : Theme.muted)
                    .frame(width: 34, height: 34)
                    .background(speechRecognizer?.isListening == true ? Theme.accent.opacity(0.15) : Color.clear)
                    .clipShape(.circle)
            }

            TextField("Scrivi come ti senti...", text: $inputText)
                .textFieldStyle(.plain)
                .padding(12)
                .background(Theme.bgTop.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.cardBorder, lineWidth: 1))
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
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                let userMsg = StoredMessage(role: "user", content: text, session: currentSession)
                context.insert(userMsg); try? context.save()
                viewModel.send(text, persona: aiPersona) { reply in
                    let botMsg = StoredMessage(role: "assistant", content: reply, session: currentSession)
                    context.insert(botMsg); try? context.save()
                }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 30)).foregroundStyle(Theme.accent)
            }
            .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
        .background(Theme.surface)
    }

    private var typingIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<3) { i in
                Circle().fill(Theme.muted).frame(width: 6, height: 6)
                    .opacity(viewModel.isLoading ? 1 : 0.3)
            }
            Text("Sta riflettendo...").font(.caption).foregroundStyle(Theme.textSecondary).padding(.leading, 4)
        }
    }

    private func errorBanner(_ msg: String) -> some View {
        Text(msg).font(.caption).foregroundStyle(Theme.gold).padding(.vertical, 8).padding(.horizontal, 16)
    }

    private func shouldShowDateDivider(at i: Int) -> Bool {
        guard i > 0 else { return true }
        let prev = viewModel.messages[i - 1].timestamp
        let curr = viewModel.messages[i].timestamp
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
        if let sr = speechRecognizer, sr.isListening {
            sr.stop()
            return
        }
        if speechRecognizer == nil {
            speechRecognizer = SpeechRecognizer()
        }
        guard let sr = speechRecognizer else { return }
        Task {
            guard await sr.requestAuthorization() else { return }
            sr.start { text in
                Task { @MainActor in
                    guard !text.isEmpty else { return }
                    self.inputText = text
                    let userMsg = StoredMessage(role: "user", content: text, session: self.currentSession)
                    self.context.insert(userMsg); try? self.context.save()
                    self.viewModel.send(text, persona: self.aiPersona) { reply in
                        let botMsg = StoredMessage(role: "assistant", content: reply, session: self.currentSession)
                        self.context.insert(botMsg); try? self.context.save()
                    }
                }
            }
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
                    Text(message.content)
                        .padding(14)
                        .foregroundStyle(.white)
                        .background(Theme.gradientAccent.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                        .font(.caption2).foregroundStyle(Theme.muted)
                }
                .padding(.leading, 60)
            } else {
                HStack(alignment: .bottom, spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .font(.caption)
                        .foregroundStyle(Theme.accent)
                        .frame(width: 24, height: 24)
                        .background(Theme.accent.opacity(0.1))
                        .clipShape(.circle)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(message.content)
                            .padding(14)
                            .foregroundStyle(Theme.text)
                            .background(Theme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                            .font(.caption2).foregroundStyle(Theme.muted)
                    }
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
