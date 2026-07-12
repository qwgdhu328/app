import SwiftUI

struct ChatView: View {
    @State private var viewModel = ChatViewModel()
    @State private var inputText = ""
    @State private var showPsychologists = false
    @State private var speechRecognizer: SpeechRecognizer?
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
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
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                }
                                if let error = viewModel.errorMessage {
                                    Text(error)
                                        .font(.caption)
                                        .foregroundStyle(.red)
                                        .padding()
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }
                    }
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
                .foregroundStyle(AppTint)
                .symbolEffect(.bounce, options: .repeat(3))
            Text("Parla con BenessereBot")
                .font(.title2.bold())
            Text("Uno psicologo virtuale sempre pronto ad ascoltarti.\nCondividi ciò che senti, senza giudizio.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
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
            .background(.blue.opacity(0.1))
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
                    .foregroundStyle(speechRecognizer?.isListening == true ? .red : .secondary)
            }

            TextField("Scrivi come ti senti...", text: $inputText)
                .textFieldStyle(.plain)
                .padding(12)
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 20))
                .focused($isFocused)

            Button {
                let text = inputText
                inputText = ""
                viewModel.send(text)
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(AppTint)
            }
            .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.regularMaterial)
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
                    self.viewModel.send(text)
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
                    .background(AppTint.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 18, style: .continuous))
                    .padding(.leading, 60)
            } else {
                Text(message.content)
                    .padding(14)
                    .background(.regularMaterial)
                    .clipShape(.rect(cornerRadius: 18, style: .continuous))
                    .padding(.trailing, 60)
                Spacer()
            }
        }
    }
}

#Preview {
    ChatView()
}
