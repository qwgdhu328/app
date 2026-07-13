import Foundation
import SwiftLlama

@MainActor
class LocalLLMService {
    static let shared = LocalLLMService()

    private var engine: LlamaEngine?
    private var isPreparing = false

    var isReady: Bool { engine != nil }

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

        guard modelExists else { return false }

        do {
            engine = try LlamaEngine(modelPath: modelURL.path, contextSize: 512)
            return true
        } catch {
            engine = nil
            return false
        }
    }

    func downloadModel() async -> Bool {
        let url = URL(string: "https://huggingface.co/brittlewis12/Gemma-2-2B-it-GGUF/resolve/main/gemma-2-2b-it-Q4_K_M.gguf")!
        guard let (data, _) = try? await URLSession.shared.data(from: url) else { return false }
        try? data.write(to: modelURL)
        return await prepare()
    }

    func generateReply(for text: String, history: [(role: String, content: String)]) async -> String? {
        guard let engine = engine else { return nil }

        var prompt = "<bos><start_of_turn>system\nSei BenessereBot, uno psicologo virtuale empatico. Ascolti attivamente, offri supporto emotivo e consigli pratici. Rispondi sempre in italiano.<end_of_turn>\n"
        for msg in history.suffix(6) {
            prompt += "<start_of_turn>\(msg.role)\n\(msg.content)<end_of_turn>\n"
        }
        prompt += "<start_of_turn>user\n\(text)<end_of_turn>\n<start_of_turn>assistant\n"

        do {
            return try engine.generate(prompt: prompt, maxTokens: 256, temperature: 0.7)
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "<end_of_turn>.*$", with: "", options: .regularExpression)
        } catch {
            return nil
        }
    }

    func unload() {
        engine = nil
    }
}
