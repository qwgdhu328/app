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
                    .padding(.horizontal).padding(.vertical, 6)
                ScrollViewReader { proxy in
                    ScrollView {
                        if viewModel.messages.isEmpty {
                            emptyState
                                .transition(.opacity)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.messages) { msg in
                                    MessageBubble(message: msg)
                                        .id(msg.id)
                                        .transition(.move(edge: .bottom).combined(with: .opacity))
                                }
                                if viewModel.isLoading {
                                    HStack {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                        Text("Sta riflettendo...")
                                            .font(.subheadline)
                                            .foregroundStyle(Theme.muted)
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                }
                                if let error = viewModel.errorMessage {
                                    Text(error)
                                        .font(.caption)
                                        .foregroundStyle(Theme.accent)
                                        .padding()
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }
                    }
                    .scrollDismissesKeyboard(.immediately)
                    .scrollBounceBehavior(.basedOnSize)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.messages.count)
                    .onChange(of: viewModel.messages.count) { _, _ in
                        withAnimation {
                            proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                        }
                    }
                }

                if viewModel.showPsychologists {
                    psychologistBanner
                }

                inputBar
            }
            .background(AppBackground())
            .navigationTitle("BenessereBot")
            .sheet(isPresented: $showPsychologists) {
                PsychologistsListView(city: viewModel.suggestedCity)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "brain.head.profile")
                .font(.system(size: 60))
                .foregroundStyle(Theme.breathing)
                .symbolEffect(.bounce, options: .repeat(3))
            Text("Parla con BenessereBot")
                .font(.title2.bold())
            Text("Uno psicologo virtuale sempre pronto ad ascoltarti.\nCondividi ciò che senti, senza giudizio.")
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.muted)
                .padding(.horizontal, 40)
            Spacer()
        }
        .transition(.opacity)
    }

    private var psychologistBanner: some View {
        Button {
            showPsychologists = true
        } label: {
            HStack {
                Image(systemName: "person.2.fill")
                Text("Parlare con uno psicologo umano?")
                    .font(.subheadline.weight(.medium))
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding(12)
            .background(Theme.accent.opacity(0.1))
            .clipShape(.rect(cornerRadius: 12))
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    private var inputBar: some View {
        HStack(spacing: 8) {
            Button {
                handleMicTap()
            } label: {
                Image(systemName: speechRecognizer?.isListening == true ? "mic.fill" : "mic")
                    .font(.title2)
                    .foregroundStyle(speechRecognizer?.isListening == true ? Theme.accent : Theme.muted)
            }

            TextField("Scrivi come ti senti...", text: $inputText)
                .textFieldStyle(.plain)
                .padding(12)
                .background(Theme.card)
                .clipShape(.rect(cornerRadius: 20))
                .foregroundStyle(Theme.text)
                .focused($isFocused)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Chiudi") { isFocused = false }
                            .foregroundStyle(Theme.accent)
                    }
                }

            Button {
                let text = inputText
                inputText = ""
                viewModel.send(text, persona: aiPersona)
                let sm = StoredMessage(role: "user", content: text)
                context.insert(sm)
                try? context.save()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(Theme.breathing)
            }
            .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Theme.card)
    }

    private func handleMicTap() {
        if let sr = speechRecognizer, sr.isListening {
            sr.stop()
            return
        }

        let sr = SpeechRecognizer()
        speechRecognizer = sr

        Task {
            guard await sr.requestAuthorization() else { return }
            sr.start { text in
                Task { @MainActor in
                    guard !text.isEmpty else { return }
                    self.inputText = text
                    self.viewModel.send(text, persona: aiPersona)
                }
            }
        }
    }
}

struct MessageBubble: View {
    let message: Message

    var body: some View {
        HStack {
            if message.role == "user" {
                Spacer()
                Text(message.content)
                    .padding(14)
                    .foregroundStyle(.white)
                    .background(Theme.breathing.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .padding(.leading, 60)
            } else {
                Text(message.content)
                    .padding(14)
                    .foregroundStyle(Theme.text)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .padding(.trailing, 60)
                Spacer()
            }
        }
    }
}

#Preview {
    ChatView()
}
