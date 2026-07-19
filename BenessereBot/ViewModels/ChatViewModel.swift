import SwiftUI
import SwiftData

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showPsychologists = false
    @Published var suggestedCity = "Milano"
    var currentSession: ChatSession?

    private var apiKey: String { Config.openRouterAPIKey }
    private let model = "google/gemini-2.5-flash-lite"

    func loadPersistedMessages(from context: ModelContext, session: ChatSession) {
        let descriptor = FetchDescriptor<StoredMessage>(
            predicate: #Predicate { $0.session?.id == session.id },
            sortBy: [SortDescriptor(\.timestamp)]
        )
        if let stored = try? context.fetch(descriptor) {
            messages = stored.map { Message(role: $0.role, content: $0.content) }
        }
    }

    func send(_ text: String, persona: AIPersona = .therapist, onReply: @escaping (String) -> Void = { _ in }) {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let userMsg = Message(role: "user", content: text)
        messages.append(userMsg)
        isLoading = true
        errorMessage = nil
        showPsychologists = false

        Task {
            let aiMode = UserDefaults.standard.string(forKey: "aiMode") ?? "hybrid"

            if aiMode == "local" || (aiMode == "hybrid" && text.count < 100) {
                if LocalLLMService.shared.isReady {
                    let reply = await LocalLLMService.shared.generateReply(for: text, history: messages.map { (role: $0.role, content: $0.content) })
                    if let reply = reply {
                        await MainActor.run {
                            let msg = Message(role: "assistant", content: reply)
                            self.messages.append(msg)
                            self.isLoading = false
                            onReply(reply)
                        }
                        return
                    }
                }

                let result = AppleIntelligenceService.shared.analyze(text)
                if case .localReply(let reply) = result {
                    await MainActor.run {
                        let msg = Message(role: "assistant", content: reply)
                        self.messages.append(msg)
                        self.isLoading = false
                        onReply(reply)
                    }
                    return
                }
            }

            do {
                var reply = try await sendToOpenRouter(text, persona: persona)
                await MainActor.run {
                    if reply.contains("CONTATTA_UN_PSICOLOGO") {
                        reply = reply.replacingOccurrences(of: "CONTATTA_UN_PSICOLOGO", with: "")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                        self.showPsychologists = true
                        self.suggestedCity = extractCity(from: text) ?? "Milano"
                    }
                    let msg = Message(role: "assistant", content: reply)
                    self.messages.append(msg)
                    self.isLoading = false
                    onReply(reply)
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Impossibile contattare il cloud. Verifica la connessione o usa la modalità Locale."
                    self.isLoading = false
                }
            }
        }
    }

    private func sendToOpenRouter(_ text: String, persona: AIPersona) async throws -> String {
        let url = URL(string: "https://openrouter.ai/api/v1/chat/completions")!
        var messages: [[String: String]] = [
            ["role": "system", "content": persona.systemPrompt]
        ]
        for msg in self.messages.suffix(10) {
            messages.append(["role": msg.role, "content": msg.content])
        }

        let body: [String: Any] = [
            "model": model,
            "messages": messages,
            "temperature": 0.7
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.timeoutInterval = 30

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResp = response as? HTTPURLResponse,
              (200...299).contains(httpResp.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let chatResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
        return chatResponse.choices.first?.message.content ?? ""
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
