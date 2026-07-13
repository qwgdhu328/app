import Foundation
import SwiftLlama

@MainActor
class LocalLLMService {
    static let shared = LocalLLMService()

    private var service: LlamaService?
    private var isPreparing = false

    var isReady: Bool { service != nil }

    private var modelURL: URL {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent("gemma-2-2b-it-Q4_K_M.gguf")
    }

    var modelExists: Bool { FileManager.default.fileExists(atPath: modelURL.path) }

    func prepare() async -> Bool {
        if isReady { return true }
        if isPreparing { return false }
        isPreparing = true
        defer { isPreparing = false }

        let config = LlamaConfig(batchSize: 512, maxTokenCount: 2048, useGPU: true)
        service = LlamaService(modelUrl: modelURL, config: config)
        return true
    }

    func downloadModel() async -> Bool {
        let url = URL(string: "https://huggingface.co/brittlewis12/Gemma-2-2B-it-GGUF/resolve/main/gemma-2-2b-it-Q4_K_M.gguf")!
        guard let (data, _) = try? await URLSession.shared.data(from: url) else { return false }
        try? data.write(to: modelURL)
        return await prepare()
    }

    func generateReply(for text: String, history: [(role: String, content: String)]) async -> String? {
        guard let service = service else { return nil }

        var messages: [LlamaChatMessage] = [
            LlamaChatMessage(role: .system, content: "Sei BenessereBot, uno psicologo virtuale empatico. Ascolti attivamente, offri supporto emotivo e consigli pratici. Rispondi sempre in italiano.")
        ]

        for msg in history.suffix(6) {
            let role: LlamaChatMessage.Role = msg.role == "user" ? .user : .assistant
            messages.append(LlamaChatMessage(role: role, content: msg.content))
        }
        messages.append(LlamaChatMessage(role: .user, content: text))

        let sampling = LlamaSamplingConfig(temperature: 0.7, seed: UInt32.random(in: 0...UInt32.max))

        do {
            return try await service.respond(to: messages, samplingConfig: sampling)
                .trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            return nil
        }
    }

    func unload() {
        service = nil
    }
}
