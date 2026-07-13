import Foundation
import SwiftLlama

@MainActor
class LocalLLMService: NSObject, URLSessionDownloadDelegate {
    static let shared = LocalLLMService()

    private var service: LlamaService?
    private var isPreparing = false
    var downloadProgress: Float = 0
    var isDownloading = false
    var downloadError: String?

    var isReady: Bool { service != nil }

    private var modelURL: URL {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent("mistral-7b-v03-q4.gguf")
    }

    var modelExists: Bool { FileManager.default.fileExists(atPath: modelURL.path) }

    func prepare() async -> Bool {
        if isReady { return true }
        if isPreparing { return false }
        isPreparing = true
        defer { isPreparing = false }

        let config = LlamaConfig(batchSize: 512, maxTokenCount: 4096, useGPU: true)
        service = LlamaService(modelUrl: modelURL, config: config)
        return true
    }

    func startDownload() async -> Bool {
        guard !modelExists, !isDownloading else { return modelExists }
        isDownloading = true
        downloadProgress = 0
        downloadError = nil

        let url = URL(string: "https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.3-GGUF/resolve/main/mistral-7b-instruct-v0.3.Q4_K_M.gguf")!
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        let task = session.downloadTask(with: url)
        task.resume()
        return true
    }

    nonisolated func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        Task { @MainActor in
            self.downloadProgress = progress
        }
    }

    nonisolated func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        Task { @MainActor in
            defer {
                self.isDownloading = false
                session.invalidateAndCancel()
            }
            guard !FileManager.default.fileExists(atPath: modelURL.path) else { return }
            do {
                try FileManager.default.moveItem(at: location, to: modelURL)
                _ = await prepare()
            } catch {
                self.downloadError = error.localizedDescription
            }
        }
    }

    nonisolated func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error else { return }
        Task { @MainActor in
            self.downloadError = error.localizedDescription
            self.isDownloading = false
            session.invalidateAndCancel()
        }
    }

    func generateReply(for text: String, history: [(role: String, content: String)]) async -> String? {
        guard let service = service else { return nil }

        var messages: [LlamaChatMessage] = [
            LlamaChatMessage(role: .system, content: "Sei BenessereBot, un assistente AI empatico e conversazionale. Ascolti, supporti e rispondi in modo naturale e colloquiale. Rispondi sempre in italiano.")
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
