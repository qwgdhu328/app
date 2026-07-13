import SwiftUI

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showPsychologists = false
    @Published var suggestedCity = "Milano"
    @AppStorage("aiMode") var aiMode: String = "hybrid"

    func send(_ text: String, persona: AIPersona = .therapist) {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let userMsg = Message(role: "user", content: text)
        messages.append(userMsg)
        isLoading = true
        errorMessage = nil
        showPsychologists = false

        Task {
            if aiMode == "local" || (aiMode == "hybrid" && text.count < 100) {
                if LocalLLMService.shared.isReady {
                    let reply = await LocalLLMService.shared.generateReply(for: text, history: messages.map { (role: $0.role, content: $0.content) })
                    if let reply = reply {
                        await MainActor.run {
                            self.messages.append(Message(role: "assistant", content: reply))
                            self.isLoading = false
                        }
                        return
                    }
                }

                let result = await AppleIntelligenceService.shared.analyze(text)
                switch result {
                case .localReply(let reply):
                    await MainActor.run {
                        self.messages.append(Message(role: "assistant", content: reply))
                        self.isLoading = false
                    }
                    return
                case .needsCloud:
                    if aiMode == "local" {
                        let msg = LocalLLMService.shared.modelExists
                            ? "Il modello locale è in caricamento, riprova tra un momento."
                            : "Attiva il cloud o scarica il modello Gemma 2B da Impostazioni per usare l'AI locale."
                        await MainActor.run {
                            self.messages.append(Message(role: "assistant", content: msg))
                            self.isLoading = false
                        }
                        return
                    }
                }
            }

            do {
                OpenRouterService.shared.systemPrompt = persona.systemPrompt
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
