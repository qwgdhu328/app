import SwiftUI

struct ChatView: View {
    @State private var viewModel = ChatViewModel()
    @State private var inputText = ""
    @State private var showPsychologists = false
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.messages.isEmpty {
                    emptyState
                } else {
                    messageList
                }

                if viewModel.showPsychologists {
                    psychologistBanner
                }

                inputBar
            }
            .background(Color(.systemGroupedBackground))
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
                .foregroundStyle(.tint)
            Text("Parla con BenessereBot")
                .font(.title2.bold())
            Text("Uno psicologo virtuale sempre pronto ad ascoltarti.\nCondividi ciò che senti, senza giudizio.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 40)
            Spacer()
        }
    }

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.messages) { msg in
                        MessageBubble(message: msg)
                            .transition(.opacity.combined(with: .slide))
                    }
                    if viewModel.isLoading {
                        TypingIndicator()
                            .padding(.horizontal)
                    }
                    if let error = viewModel.errorMessage {
                        HStack {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                            Button("Riprova") {
                                viewModel.errorMessage = nil
                            }
                            .font(.caption.bold())
                        }
                        .padding()
                        .background(.red.opacity(0.08))
                        .clipShape(.rect(cornerRadius: 12))
                        .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .onChange(of: viewModel.messages.count) { _, _ in
                withAnimation {
                    proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                }
            }
        }
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
            TextField("Scrivi come ti senti...", text: $inputText)
                .textFieldStyle(.plain)
                .padding(12)
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 20))
                .focused($isFocused)

            Button {
                let text = inputText
                inputText = ""
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                viewModel.send(text)
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.tint)
            }
            .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.regularMaterial)
    }
}

private struct TypingIndicator: View {
    @State private var animate = false

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(Color.secondary.opacity(0.4))
                    .frame(width: 8, height: 8)
                    .offset(y: animate ? -5 : 0)
                    .animation(
                        .easeInOut(duration: 0.5).repeatForever().delay(Double(i) * 0.15),
                        value: animate
                    )
            }
            Text("Sta riflettendo...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.leading, 4)
        }
        .padding(.vertical, 8)
        .onAppear { animate = true }
    }
}

struct MessageBubble: View {
    let message: Message

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.role == "user" {
                Spacer()
                Text(message.content)
                    .padding(14)
                    .background(AppTint.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 18))
                    .padding(.leading, 60)
            } else {
                Image(systemName: "brain.head.profile")
                    .font(.caption)
                    .foregroundStyle(.tint)
                    .frame(width: 28, height: 28)
                    .background(AppTint.opacity(0.1))
                    .clipShape(.circle)

                Text(message.content)
                    .padding(14)
                    .background(.regularMaterial)
                    .clipShape(.rect(cornerRadius: 18))
                    .padding(.trailing, 60)
                Spacer()
            }
        }
    }
}

#Preview {
    ChatView()
}
