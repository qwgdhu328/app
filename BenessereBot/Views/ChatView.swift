import SwiftUI

struct ChatView: View {
    @State private var viewModel = ChatViewModel()
    @State private var inputText = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { msg in
                                MessageBubble(message: msg)
                            }
                            if viewModel.isLoading {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Sta scrivendo...")
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
                    .onChange(of: viewModel.messages.count) { _, _ in
                        withAnimation {
                            proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                        }
                    }
                }

                HStack(spacing: 8) {
                    TextField("Scrivi un messaggio...", text: $inputText)
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
                            .foregroundStyle(.primary)
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(.regularMaterial)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Chat")
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
                    .background(Color.primary.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 18))
                    .padding(.leading, 60)
            } else {
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
