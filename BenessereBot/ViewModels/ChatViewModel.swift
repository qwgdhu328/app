import SwiftUI

@Observable
class ChatViewModel {
    var messages: [Message] = []
    var isLoading = false
    var errorMessage: String?
    var showPsychologists = false
    var suggestedCity = "Milano"

    func send(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let userMsg = Message(role: "user", content: text)
        messages.append(userMsg)
        isLoading = true
        errorMessage = nil
        showPsychologists = false

        Task {
            do {
                var reply = try await OpenRouterService.shared.sendMessage(text, history: messages)
                await MainActor.run {
                    if reply.contains("CONTATTA_UN_PSICOLOGO") {
                        reply = reply.replacingOccurrences(of: "CONTATTA_UN_PSICOLOGO", with: "")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                        self.showPsychologists = true
                        self.suggestedCity = extractCity(from: text) ?? "Milano"
                    }
                    self.messages.append(Message(role: "assistant", content: reply))
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    private func extractCity(from text: String) -> String? {
        let candidates = ["Milano", "Roma", "Torino", "Bologna", "Firenze", "Napoli",
                          "Venezia", "Palermo", "Genova", "Catania", "Bari", "Cagliari",
                          "Verona", "Padova", "Trieste", "Brescia", "Parma", "Modena"]
        for city in candidates {
            if text.localizedCaseInsensitiveContains(city) {
                return city
            }
        }
        return nil
    }
}
