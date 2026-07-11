import SwiftUI

@Observable
class ChatViewModel {
    var messages: [Message] = []
    var isLoading = false
    var errorMessage: String?

    func send(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let userMsg = Message(role: "user", content: text)
        messages.append(userMsg)
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let reply = try await OpenRouterService.shared.sendMessage(text, history: messages)
                await MainActor.run {
                    messages.append(Message(role: "assistant", content: reply))
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}
