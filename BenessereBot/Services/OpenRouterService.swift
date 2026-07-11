import Foundation

class OpenRouterService {
    static let shared = OpenRouterService()

    private let baseURL = "https://openrouter.ai/api/v1/chat/completions"
    private let apiKey: String
    private let model: String

    private init() {
        self.apiKey = ProcessInfo.processInfo.environment["EXPO_PUBLIC_OPENROUTER_API_KEY"] ?? ""
        self.model = ProcessInfo.processInfo.environment["EXPO_PUBLIC_OPENROUTER_MODEL"] ?? "openai/gpt-4o"
    }

    func sendMessage(_ text: String, history: [Message]) async throws -> String {
        var messages = history.map { ChatMessage(role: $0.role, content: $0.content) }
        messages.append(ChatMessage(role: "user", content: text))

        let requestBody = ChatRequest(model: model, messages: messages)
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(ChatResponse.self, from: data)
        return response.choices.first?.message.content ?? ""
    }
}
