import Foundation
import llama

@MainActor
class LocalLLMService {
    static let shared = LocalLLMService()

    private var model: OpaquePointer?
    private var context: OpaquePointer?
    private var loadedModelPath: String?

    var isReady: Bool { model != nil && context != nil }

    private var modelURL: URL {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent("gemma-2-2b-it-Q4_K_M.gguf")
    }

    var modelExists: Bool { FileManager.default.fileExists(atPath: modelURL.path) }

    func prepare() async -> Bool {
        if isReady { return true }
        guard FileManager.default.fileExists(atPath: modelURL.path) else { return false }
        return loadModel(modelURL.path)
    }

    func downloadModel() async -> Bool {
        let url = URL(string: "https://huggingface.co/brittlewis12/Gemma-2-2B-it-GGUF/resolve/main/gemma-2-2b-it-Q4_K_M.gguf")!
        guard let (data, _) = try? await URLSession.shared.data(from: url) else { return false }
        try? data.write(to: modelURL)
        return loadModel(modelURL.path)
    }

    private func loadModel(_ path: String) -> Bool {
        var modelParams = llama_model_default_params()
        modelParams.n_gpu_layers = 99

        guard let m = llama_load_model_from_file(path, modelParams) else { return false }
        model = m

        var ctxParams = llama_context_default_params()
        ctxParams.n_ctx = 512
        ctxParams.n_threads = Int32(ProcessInfo.processInfo.processorCount)
        ctxParams.n_threads_batch = Int32(ProcessInfo.processInfo.processorCount)

        guard let ctx = llama_new_context_with_model(m, ctxParams) else {
            llama_free_model(m)
            model = nil
            return false
        }
        context = ctx
        loadedModelPath = path
        return true
    }

    func generateReply(for text: String, history: [(role: String, content: String)]) async -> String? {
        guard let model = model, let context = context else { return nil }

        var prompt = "<bos><start_of_turn>system\nSei BenessereBot, uno psicologo virtuale empatico. Ascolti attivamente, offri supporto emotivo e consigli pratici. Rispondi sempre in italiano.<end_of_turn>\n"
        for msg in history.suffix(6) {
            prompt += "<start_of_turn>\(msg.role)\n\(msg.content)<end_of_turn>\n"
        }
        prompt += "<start_of_turn>user\n\(text)<end_of_turn>\n<start_of_turn>assistant\n"

        let nThreads = Int32(ProcessInfo.processInfo.processorCount)
        var tokens = [llama_token](repeating: 0, count: 512)
        var nTokens = llama_tokenize(model, prompt, Int32(prompt.utf8.count), &tokens, Int32(tokens.count), true, false)
        if nTokens < 0 {
            tokens = [llama_token](repeating: 0, count: Int(-nTokens))
            nTokens = llama_tokenize(model, prompt, Int32(prompt.utf8.count), &tokens, Int32(tokens.count), true, false)
        }
        guard nTokens > 0 else { return nil }

        llama_kv_cache_seq_rm(context, -1, -1, -1)
        llama_kv_cache_clear(context)
        llama_batch_clear(context)

        var output = ""
        let maxTokens = 256
        let eosId: llama_token = 1

        for pos in 0..<maxTokens {
            let batch = llama_batch_get_one(&tokens, Int32(nTokens))
            if llama_decode(context, batch) != 0 { break }

            var newTokenId: llama_token = eosId
            let nVocab = llama_n_vocab(model)
            let logits = llama_get_logits_ith(context, llama_batch_size(batch) - 1)

            let candidates = llama_token_data_array(
                data: nil,
                size: 0,
                sorted: false
            )

            var bestScore: Float = -Float.infinity
            for i in 0..<nVocab {
                let score = logits![Int(i)]
                if score > bestScore {
                    bestScore = score
                    newTokenId = i
                }
            }

            if newTokenId == eosId { break }

            var buf = [CChar](repeating: 0, count: 16)
            let n = llama_token_to_piece(model, newTokenId, &buf, Int32(buf.count), pos == 0, false)
            if n > 0 {
                buf[Int(n)] = 0
                output += String(cString: buf)
            }

            tokens[0] = newTokenId
            nTokens = 1
        }

        return output.isEmpty ? nil : output
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "<end_of_turn>.*$", with: "", options: .regularExpression)
    }

    func unload() {
        if let ctx = context { llama_free(ctx); context = nil }
        if let m = model { llama_free_model(m); model = nil }
        loadedModelPath = nil
    }

    deinit { unload() }
}
