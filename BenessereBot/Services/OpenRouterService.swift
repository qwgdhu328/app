import Foundation

class OpenRouterService {
    static let shared = OpenRouterService()

    private let baseURL = "https://openrouter.ai/api/v1/chat/completions"
    private let apiKey: String
    private let model: String

    private let systemPrompt = """
    Sei un psicologo virtuale empatico e professionista. Il tuo nome è BenessereBot.
    Ascolti attivamente, offri supporto emotivo e consigli pratici basati sulla psicologia.
    IMPORTANTE: Se la persona mostra segni di crisi grave (pensieri suicidi, autolesionismo, violenza), 
    invitala gentilmente a contattare il Telefono Amico (199 284 284) o il 112.
    Se il problema è complesso e richiede un professionista umano (disturbi gravi, terapie lunghe, 
    diagnosi), dì gentilmente che sarebbe meglio parlare con uno psicologo della città e 
    includi nel messaggio la frase: "CONTATTA_UN_PSICOLOGO" così il sistema può suggerirti 
    professionisti nella tua zona.
    Sii sempre rispettoso, non dare diagnosi mediche, e ricorda che sei un supporto, non un sostituto 
    della terapia professionale.
    """

    private init() {
        self.apiKey = ProcessInfo.processInfo.environment["EXPO_PUBLIC_OPENROUTER_API_KEY"] ?? ""
        self.model = ProcessInfo.processInfo.environment["EXPO_PUBLIC_OPENROUTER_MODEL"] ?? "openai/gpt-4o"
    }

    func sendMessage(_ text: String, history: [Message]) async throws -> String {
        var messages: [[String: String]] = [
            ["role": "system", "content": systemPrompt]
        ]
        for msg in history {
            messages.append(["role": msg.role, "content": msg.content])
        }
        messages.append(["role": "user", "content": text])

        let body: [String: Any] = [
            "model": model,
            "messages": messages,
            "temperature": 0.7
        ]

        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResp = response as? HTTPURLResponse,
              (200...299).contains(httpResp.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let choices = json?["choices"] as? [[String: Any]]
        let message = choices?.first?["message"] as? [String: Any]
        return message?["content"] as? String ?? ""
    }
}
